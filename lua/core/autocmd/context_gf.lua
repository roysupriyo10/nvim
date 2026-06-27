-- resolve @journal/ aliases in @context tags for gf navigation
vim.api.nvim_create_augroup("ContextGf", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "ContextGf",
	pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
	callback = function()
		vim.opt_local.includeexpr = "v:lua.string.gsub(v:fname, '^@journal/', 'journal/architecture/')"
		vim.opt_local.path:append(vim.fn.getcwd())
	end,
})
