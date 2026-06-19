--- Local tsgo integration (typescript-go native preview).
--- Install: pnpm add -g @typescript/native-preview

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugin/lsp/tsgo",
	name = "tsgo-lsp",
	ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		require("plugin.lsp.tsgo.bootstrap").setup()
	end,
}
