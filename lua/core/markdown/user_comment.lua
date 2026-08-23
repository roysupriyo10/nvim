-- Inline user comments for markdown notes that coding agents read.
--
-- The marker is an HTML comment so it is invisible in every markdown renderer
-- and survives prettier untouched. Journal templates already use bare
-- `<!-- ... -->`, so the USER COMMENT marker is what separates a human note
-- from template scaffolding:
--
--   converts **13 canvases** <!-- USER COMMENT resolved:[ ] which 13? --> into ...
--
-- Comments sit inline, pinned to the exact phrase they are about. The format
-- deliberately carries no `|`, which would otherwise be read as a cell
-- delimiter and split a markdown table row. The box is the handshake: the
-- user opens a comment with `[ ]`, the agent flips it to `[x]` once
-- addressed. Grep open ones with `grep -rn "USER COMMENT resolved:\[ \]"`.

local M = {}

local MARKER = "USER COMMENT"
local PREFIX = "<!-- " .. MARKER .. " resolved:[ ] "
local SUFFIX = " -->"

-- one whole comment, non-greedy so adjacent comments on a line stay distinct
local SPAN_PATTERN = "<!%-%-%s*" .. MARKER .. ".-%-%->"
-- the resolved box, split so it can be rewritten in place
local BOX_PATTERN = "(resolved:%s*%[)([^%]]*)(%])"

local function get_line(buf, row)
	return vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
end

--- Byte ranges (1-indexed, inclusive) of every comment on `line`.
--- @return { s: integer, e: integer }[]
local function spans_in(line)
	local spans, init = {}, 1
	while line do
		local s, e = line:find(SPAN_PATTERN, init)
		if not s then
			break
		end
		spans[#spans + 1] = { s = s, e = e }
		init = e + 1
	end
	return spans
end

local function span_resolved(text)
	local _, state = text:match(BOX_PATTERN)
	return state ~= nil and (state:gsub("%s", "")) ~= ""
end

--- True when the line carries at least one comment still marked `[ ]`.
local function has_unresolved(buf, row)
	local line = get_line(buf, row)
	for _, span in ipairs(spans_in(line)) do
		if not span_resolved(line:sub(span.s, span.e)) then
			return true
		end
	end
	return false
end

--- Splice an empty comment into `row` at byte offset `col`, spacing it off the
--- surrounding prose, and drop into insert mode on the text slot.
local function insert_inline(row, col)
	local buf = vim.api.nvim_get_current_buf()
	local line = get_line(buf, row) or ""
	local before, after = line:sub(1, col), line:sub(col + 1)

	local lead = (before ~= "" and not before:match("%s$")) and " " or ""
	local trail = (after ~= "" and not after:match("^%s")) and " " or ""

	vim.api.nvim_buf_set_text(buf, row - 1, col, row - 1, col, { lead .. PREFIX .. SUFFIX .. trail })
	vim.api.nvim_win_set_cursor(0, { row, col + #lead + #PREFIX })
	vim.cmd("startinsert")
end

--- Comment on the current line, parked at its end so a word is never split.
function M.insert()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	insert_inline(row, #(get_line(vim.api.nvim_get_current_buf(), row) or ""))
end

--- Comment pinned directly after the visual selection -- select the phrase,
--- comment on it. Called while the selection is still active.
function M.insert_after_selection()
	-- getregionpos resolves the real byte extent, multibyte characters included
	local region = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), {
		type = vim.fn.mode(),
	})
	local last = region[#region][2]
	local row, col = last[2], last[3]
	vim.cmd("normal! \27")

	local line = get_line(vim.api.nvim_get_current_buf(), row) or ""
	insert_inline(row, math.min(col, #line))
end

--- Insert a standalone comment on its own line below the cursor, blank-line
--- padded so it forms its own markdown block.
function M.insert_block()
	local buf = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local lines, offset = {}, nil

	local current = get_line(buf, row)
	if current and current:match("%S") then
		lines[#lines + 1] = ""
	end

	lines[#lines + 1] = PREFIX .. SUFFIX
	offset = #lines

	local following = get_line(buf, row + 1)
	if following and following:match("%S") then
		lines[#lines + 1] = ""
	end

	vim.api.nvim_buf_set_lines(buf, row, row, false, lines)
	vim.api.nvim_win_set_cursor(0, { row + offset, #PREFIX })
	vim.cmd("startinsert")
end

--- The comment the cursor is inside, else the last one starting before it,
--- else the first on the line.
local function span_at_cursor(line, col)
	local spans = spans_in(line)
	local fallback
	for _, span in ipairs(spans) do
		if col >= span.s and col <= span.e then
			return span
		elseif span.e < col then
			fallback = span
		end
	end
	return fallback or spans[1]
end

--- Flip the resolved box on the comment at the cursor, else the nearest one
--- above it -- the usual position after reading a comment.
function M.toggle()
	local buf = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, span = cursor[1], nil

	span = span_at_cursor(get_line(buf, row) or "", cursor[2] + 1)
	while not span and row > 1 do
		row = row - 1
		span = span_at_cursor(get_line(buf, row) or "", 1)
	end

	if not span then
		vim.notify("no user comment at or above the cursor", vim.log.levels.WARN)
		return
	end

	local line = get_line(buf, row)
	local updated, count = line:sub(span.s, span.e):gsub(BOX_PATTERN, function(open, state, close)
		return open .. (((state:gsub("%s", "")) ~= "") and " " or "x") .. close
	end, 1)

	if count == 0 then
		vim.notify("user comment on line " .. row .. " has no resolved box", vim.log.levels.WARN)
		return
	end

	vim.api.nvim_buf_set_text(buf, row - 1, span.s - 1, row - 1, span.e, { updated })
end

--- Jump to the next (`step = 1`) or previous (`step = -1`) line holding an
--- unresolved comment. Deliberately does not wrap.
function M.goto_unresolved(step)
	local buf = vim.api.nvim_get_current_buf()
	local total = vim.api.nvim_buf_line_count(buf)
	local row = vim.api.nvim_win_get_cursor(0)[1] + step

	while row >= 1 and row <= total do
		if has_unresolved(buf, row) then
			local span = spans_in(get_line(buf, row))[1]
			vim.api.nvim_win_set_cursor(0, { row, span.s - 1 })
			vim.cmd("normal! zz")
			return
		end
		row = row + step
	end

	vim.notify("no more unresolved user comments", vim.log.levels.INFO)
end

--- Buffer-local wiring. Nothing here is global; the mappings and commands
--- exist only in the markdown buffers the FileType autocmd matched.
function M.attach(buf)
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
	end

	map("n", "<leader>mc", M.insert, "User comment on this line")
	map("x", "<leader>mc", M.insert_after_selection, "User comment on selection")
	map("n", "<leader>mC", M.insert_block, "User comment as its own block")
	map("n", "<leader>mr", M.toggle, "Toggle user comment resolved")
	map("n", "]u", function()
		M.goto_unresolved(1)
	end, "Next unresolved user comment")
	map("n", "[u", function()
		M.goto_unresolved(-1)
	end, "Previous unresolved user comment")

	vim.api.nvim_buf_create_user_command(buf, "UserComment", M.insert, {
		desc = "Comment inline on the current line",
	})
	vim.api.nvim_buf_create_user_command(buf, "UserCommentBlock", M.insert_block, {
		desc = "Insert a standalone user comment block",
	})
	vim.api.nvim_buf_create_user_command(buf, "UserCommentResolve", M.toggle, {
		desc = "Toggle the resolved box on the nearest user comment",
	})
end

return M
