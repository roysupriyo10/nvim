-- trim trailing whitespace for files without formatter
vim.api.nvim_create_augroup("TrimWhitespace", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "TrimWhitespace",
	pattern = "*",
	callback = function(args)
		local ok, conform = pcall(require, "conform")
		if ok then
			local formatters, uses_lsp = conform.list_formatters_to_run(args.buf)
			if #formatters > 0 or uses_lsp then
				return
			end
		end

		local view = vim.fn.winsaveview()
		vim.cmd([[silent keepjumps keeppatterns %s/\s\+$//e]])
		vim.fn.winrestview(view)
	end,
})
