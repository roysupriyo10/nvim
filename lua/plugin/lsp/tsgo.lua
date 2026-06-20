--- Native TypeScript LSP (tsc v7+ or tsgo). Falls back to mason ts_ls when unavailable.
--- Install: pnpm add -g typescript@rc  (or @typescript/native-preview for tsgo)

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugin/lsp/tsgo",
	name = "tsgo-lsp",
	ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		-- lspconfig ships its own tsgo cmd (hardcoded "tsgo"); override after it loads.
		vim.lsp.config("tsgo", require("plugin.lsp.tsgo.config"))
		require("plugin.lsp.tsgo.bootstrap").setup()
	end,
}
