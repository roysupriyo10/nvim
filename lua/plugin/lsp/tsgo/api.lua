--- tsgo LSP helpers (typescript-go native preview).

local M = {}

M.kinds = {
	organize_imports = "source.organizeImports",
	remove_unused_imports = "source.removeUnusedImports",
	sort_imports = "source.sortImports",
	fix_all = "source.fixAll",
	quickfix = "quickfix",
	add_missing_imports = "source.addMissingImports",
	add_missing_imports_ts = "source.addMissingImports.ts",
}

---@param opts? { bufnr?: integer }
---@return vim.lsp.Client?
function M.get_client(opts)
	opts = opts or {}
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "tsgo" })) do
		return client
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
			vim.notify("tsgo is not attached to this buffer", vim.log.levels.WARN)
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
	return M.code_action(vim.tbl_extend("force", opts or {}, { only = { M.kinds.organize_imports } }))
end

function M.remove_unused_imports(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, { only = { M.kinds.remove_unused_imports } }))
end

function M.sort_imports(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, { only = { M.kinds.sort_imports } }))
end

function M.fix_all(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, { only = { M.kinds.fix_all } }))
end

function M.add_missing_imports(opts)
	local tried = M.code_action(vim.tbl_extend("force", opts or {}, {
		only = { M.kinds.add_missing_imports, M.kinds.add_missing_imports_ts },
		silent = true,
	}))
	if tried then
		return true
	end

	if not (opts and opts.silent) then
		vim.notify(
			"tsgo: add-missing-imports is not implemented yet. Use completion or quickfix at the symbol.",
			vim.log.levels.INFO
		)
	end
	return false
end

function M.source_action_menu(opts)
	return M.code_action(vim.tbl_extend("force", opts or {}, {
		only = {
			M.kinds.organize_imports,
			M.kinds.remove_unused_imports,
			M.kinds.sort_imports,
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
		vim.notify("tsgo is not attached to this buffer", vim.log.levels.WARN)
		return
	end

	local win = vim.fn.bufwinid(opts.bufnr)
	if win <= 0 then
		win = vim.api.nvim_get_current_win()
	end

	local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
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
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	map("n", "<leader>ia", function()
		M.add_missing_imports({ bufnr = bufnr })
	end, "Add all missing imports (tsgo)")
	map("n", "<leader>io", function()
		M.organize_imports({ bufnr = bufnr })
	end, "Organize imports (tsgo)")
	map("n", "<leader>iu", function()
		M.remove_unused_imports({ bufnr = bufnr })
	end, "Remove unused imports (tsgo)")
	map("n", "<leader>is", function()
		M.sort_imports({ bufnr = bufnr })
	end, "Sort imports (tsgo)")
	map("n", "gS", function()
		M.source_definition({ bufnr = bufnr })
	end, "Source definition (tsgo)")

	vim.api.nvim_buf_create_user_command(bufnr, "LspTypescriptSourceAction", function()
		M.source_action_menu({ bufnr = bufnr })
	end, { desc = "TypeScript file-level source actions (tsgo)" })

	vim.api.nvim_buf_create_user_command(bufnr, "LspTypescriptGoToSourceDefinition", function()
		M.source_definition({ bufnr = bufnr, focus = true })
	end, { desc = "Go to source definition (tsgo)" })
end

return M
