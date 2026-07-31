--- Prefer denols in Deno roots, native TypeScript (tsgo) otherwise; fall back to ts_ls.
--- <leader>tlsp cycles between auto, tsgo, ts_ls, denols.

local resolve = require("plugin.lsp.tsgo.resolve")

local M = {}

--- Mode for the session ("auto", "tsgo", "ts_ls", "denols")
M.mode = "auto"

M.filetypes = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
}

local function project_root(bufnr)
	local root_markers = {
		"package-lock.json",
		"yarn.lock",
		"pnpm-lock.yaml",
		"bun.lockb",
		"bun.lock",
		".git",
	}
	return vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
end

---@param bufnr? integer
function M.native_available(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return resolve.available({ root_dir = project_root(bufnr) })
end

---@param bufnr? integer
---@return "tsgo"|"ts_ls"|"denols"
function M.active_name(bufnr)
	if M.mode ~= "auto" then
		return M.mode
	end

	local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
	if deno_root then
		return "denols"
	end

	if M.native_available(bufnr) then
		return "tsgo"
	end
	return "ts_ls"
end

---@param bufnr? integer
function M.enable(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local active = M.active_name(bufnr)
	for _, name in ipairs({ "tsgo", "ts_ls", "denols" }) do
		if name == active then
			vim.lsp.enable(name)
		else
			vim.lsp.enable(name, false)
		end
	end
end

function M.toggle()
	local cycle = { auto = "tsgo", tsgo = "ts_ls", ts_ls = "denols", denols = "auto" }
	M.mode = cycle[M.mode] or "auto"
	M.enable()

	local name = M.active_name()
	if M.mode == "auto" then
		vim.notify("LSP mode: auto (active: " .. name .. ")", vim.log.levels.INFO)
	else
		if name == "tsgo" and not M.native_available() then
			vim.notify("LSP mode: " .. M.mode .. " (native unavailable)", vim.log.levels.WARN)
		else
			vim.notify("LSP mode: " .. M.mode, vim.log.levels.INFO)
		end
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("TypescriptLsp", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = M.filetypes,
		callback = function(args)
			M.enable(args.buf)
		end,
	})

	vim.keymap.set("n", "<leader>tlsp", function()
		M.toggle()
	end, { desc = "Cycle TS/Deno LSP (auto → tsgo → ts_ls → denols)" })

	local buf = vim.api.nvim_get_current_buf()
	if vim.tbl_contains(M.filetypes, vim.bo[buf].filetype) then
		M.enable(buf)
	end
end

return M
