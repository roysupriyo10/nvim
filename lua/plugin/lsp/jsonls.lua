--- jsonls with cached JSON schemas (stdpath cache, not in dotfiles).
--- Update: :JsonSchemasRefresh

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugin/lsp/jsonls",
	name = "jsonls-lsp",
	ft = { "json", "jsonc" },
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		-- lspconfig ships its own jsonls settings; re-apply ours after it loads.
		vim.lsp.config("jsonls", require("plugin.lsp.jsonls.config"))
		require("plugin.lsp.jsonls.refresh").setup()
	end,
}
