--- TypeScript LSP helpers shared by tsgo and ts_ls.

local settings = require("plugin.lsp.tsgo.settings")

local M = {}

M.kinds = {
	organize_imports = "source.organizeImports",
	organize_imports_ts = "source.organizeImports.ts",
	remove_unused_imports = "source.removeUnusedImports",
	remove_unused_ts = "source.removeUnused.ts",
	sort_imports = "source.sortImports",
	sort_imports_ts = "source.sortImports.ts",
	fix_all = "source.fixAll",
	quickfix = "quickfix",
	add_missing_imports = "source.addMissingImports",
	add_missing_imports_ts = "source.addMissingImports.ts",
}

local client_names = { "tsgo", "ts_ls" }

--- Session preference: "off" | "args" | "all". New TS buffers inherit this; <leader>ti cycles it.
M.inlay_hints_mode = "args"

local next_inlay_mode = { off = "args", args = "all", all = "off" }
local inlay_mode_label = { off = "off", args = "arguments only", all = "all" }

local function inlay_hints_for_mode(mode)
	if mode == "all" then
		return settings.inlay_hints_all
	end
	return settings.inlay_hints_args
end

local function apply_inlay_hints_settings()
	local hints = inlay_hints_for_mode(M.inlay_hints_mode)
	for _, name in ipairs(client_names) do
		for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
			local cfg = client.config.settings or {}
			for _, lang in ipairs({ "typescript", "javascript" }) do
				cfg[lang] = cfg[lang] or {}
				cfg[lang].inlayHints = hints
			end
			client.config.settings = cfg
			client:notify("workspace/didChangeConfiguration", { settings = cfg })
		end
	end
end

local function apply_inlay_hints(bufnr, refresh)
	local enabled = M.inlay_hints_mode ~= "off"
	if refresh and enabled and vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }) then
		vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
	end
	vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
end

local function apply_inlay_hints_to_attached_buffers(refresh)
	for _, name in ipairs(client_names) do
		for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
			for bufnr in pairs(client.attached_buffers) do
				apply_inlay_hints(bufnr, refresh)
			end
		end
	end
end

function M.toggle_inlay_hints()
	local prev = M.inlay_hints_mode
	M.inlay_hints_mode = next_inlay_mode[prev] or "args"
	if M.inlay_hints_mode ~= "off" then
		apply_inlay_hints_settings()
	end
	-- Refresh when switching args ↔ all so the server settings take effect.
	local refresh = prev ~= "off" and M.inlay_hints_mode ~= "off"
	apply_inlay_hints_to_attached_buffers(refresh)
	vim.notify("Inlay hints: " .. inlay_mode_label[M.inlay_hints_mode], vim.log.levels.INFO)
end

---@param opts? { bufnr?: integer }
---@return vim.lsp.Client?
function M.get_client(opts)
	opts = opts or {}
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	for _, name in ipairs(client_names) do
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = name })) do
			return client
		end
	end
end

---@param opts? { bufnr?: integer, only?: string[], apply?: boolean, silent?: boolean }
function M.code_action(opts)
	opts = vim.tbl_extend("force", {
		bufnr = vim.api.nvim_get_current_buf(),
		apply = true,
		silent = false,
	}, opts or {})

	if not M.get_client({ bufnr = opts.bufnr }) then
		if not opts.silent then
			vim.notify("TypeScript LSP is not attached to this buffer", vim.log.levels.WARN)
		end
		return false
	end

	vim.lsp.buf.code_action({
		bufnr = opts.bufnr,
		apply = opts.apply,
		context = {
			diagnostics = {},
			only = opts.only,
		},
	})

	return true
end

function M.organize_imports(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, {
		only = { M.kinds.organize_imports, M.kinds.organize_imports_ts },
	}))
end

function M.remove_unused_imports(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, {
		only = { M.kinds.remove_unused_imports, M.kinds.remove_unused_ts },
	}))
end

function M.sort_imports(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, {
		only = { M.kinds.sort_imports, M.kinds.sort_imports_ts },
	}))
end

function M.fix_all(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, { only = { M.kinds.fix_all } }))
end

function M.add_missing_imports(opts)
	opts = opts or {}
	local client = M.get_client({ bufnr = opts.bufnr })
	if not client then
		if not opts.silent then
			vim.notify("TypeScript LSP is not attached to this buffer", vim.log.levels.WARN)
		end
		return false
	end

	if client.name == "tsgo" then
		if not opts.silent then
			vim.notify(
				"tsgo: add-missing-imports is not implemented yet. Use completion or quickfix at the symbol.",
				vim.log.levels.INFO
			)
		end
		return false
	end

	return M.code_action(vim.tbl_extend("force", opts, {
		only = { M.kinds.add_missing_imports_ts, M.kinds.add_missing_imports },
	}))
end

function M.source_action_menu(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, {
		only = {
			M.kinds.organize_imports,
			M.kinds.organize_imports_ts,
			M.kinds.remove_unused_imports,
			M.kinds.remove_unused_ts,
			M.kinds.sort_imports,
			M.kinds.sort_imports_ts,
			M.kinds.fix_all,
		},
		apply = false,
	}))
end

---@param opts? { bufnr?: integer, focus?: boolean }
function M.source_definition(opts)
	opts = vim.tbl_extend("force", {
		bufnr = vim.api.nvim_get_current_buf(),
		focus = true,
	}, opts or {})

	local client = M.get_client({ bufnr = opts.bufnr })
	if not client then
		vim.notify("TypeScript LSP is not attached to this buffer", vim.log.levels.WARN)
		return
	end

	local win = vim.fn.bufwinid(opts.bufnr)
	if win <= 0 then
		win = vim.api.nvim_get_current_win()
	end

	local params = vim.lsp.util.make_position_params(win, client.offset_encoding)

	if client.name == "ts_ls" then
		client:exec_cmd({
			title = "Go to source definition",
			command = "typescript.goToSourceDefinition",
			arguments = {
				vim.uri_from_bufnr(opts.bufnr),
				params.position,
			},
		}, { bufnr = opts.bufnr })
		return
	end

	client:request("custom/textDocument/sourceDefinition", params, function(err, result)
		if err then
			vim.notify("Go to source definition failed: " .. err.message, vim.log.levels.ERROR)
			return
		end

		if not result or vim.tbl_isempty(result) then
			vim.notify("No source definition found", vim.log.levels.INFO)
			return
		end

		local location = vim.islist(result) and result[1] or result
		vim.lsp.util.show_document(location, client.offset_encoding, { focus = opts.focus })
	end, opts.bufnr)
end

function M.on_attach(client, bufnr)
	if client:supports_method("textDocument/inlayHint") then
		apply_inlay_hints(bufnr)
	end

	local tag = client.name
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	map("n", "<leader>ia", function()
		M.add_missing_imports({ bufnr = bufnr })
	end, "Add all missing imports (" .. tag .. ")")
	map("n", "<leader>io", function()
		M.organize_imports({ bufnr = bufnr })
	end, "Organize imports (" .. tag .. ")")
	map("n", "<leader>iu", function()
		M.remove_unused_imports({ bufnr = bufnr })
	end, "Remove unused imports (" .. tag .. ")")
	map("n", "<leader>is", function()
		M.sort_imports({ bufnr = bufnr })
	end, "Sort imports (" .. tag .. ")")
	map("n", "<leader>ti", function()
		M.toggle_inlay_hints()
	end, "Cycle inlay hints: off / args / all (" .. tag .. ")")
	map("n", "gK", function()
		M.source_definition({ bufnr = bufnr })
	end, "Source definition (" .. tag .. ")")

	vim.api.nvim_buf_create_user_command(bufnr, "LspTypescriptSourceAction", function()
		M.source_action_menu({ bufnr = bufnr })
	end, { desc = "TypeScript file-level source actions (" .. tag .. ")" })

	vim.api.nvim_buf_create_user_command(bufnr, "LspTypescriptGoToSourceDefinition", function()
		M.source_definition({ bufnr = bufnr, focus = true })
	end, { desc = "Go to source definition (" .. tag .. ")" })
end

return M
