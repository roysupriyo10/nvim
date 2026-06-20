--- jsonls schema cache (background refresh, not stored in dotfiles)

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugin/lsp/jsonls",
	name = "jsonls-schemas",
	ft = { "json", "jsonc" },
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	config = function()
		vim.lsp.config("jsonls", require("plugin.lsp.jsonls.config"))
		require("plugin.lsp.jsonls.refresh").setup()
	end,
}
