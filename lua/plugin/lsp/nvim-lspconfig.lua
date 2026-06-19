return {
	"neovim/nvim-lspconfig",
	lazy = false,
	config = function()
		require("core.lsp.darwin").apply()
	end,
}
