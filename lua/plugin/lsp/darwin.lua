--- macOS: disable LSP workspace file watchers to avoid EMFILE in large repos.

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugin/lsp/darwin",
	name = "darwin-lsp-watchers",
	lazy = false,
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		require("plugin.lsp.darwin.watchers").apply()
	end,
}
