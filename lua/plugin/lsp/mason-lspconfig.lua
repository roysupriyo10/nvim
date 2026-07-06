return {
	"mason-org/mason-lspconfig.nvim",
	dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		ensure_installed = {
			"bashls",
			"clangd",
			"cssls",
			"dockerls",
			"eslint",
			"gopls",
			"html",
			"jsonls",
			"lua_ls",
			"pyright",
			"rust_analyzer",
			"taplo",
			"tailwindcss",
			"ts_ls",
			"yamlls",
			"emmet_language_server",
			"marksman",
		},
		-- ts_ls is enabled by plugin/lsp/tsgo.lua when native TypeScript is unavailable.
		-- jsonls schemas: plugin/lsp/jsonls.lua (cache + :JsonSchemasRefresh).
		-- taplo: plugin/lsp/taplo.lua; workspace + schema local to ~/.config/tmux-manager/.
		automatic_enable = {
			exclude = {
				"taplo",
				"ts_ls",
				"remark_ls",
				"markdown_oxide",
				"ltex",
				"ltex_plus",
				"harper_ls",
				"prosemd_lsp",
				"vale_ls",
				"grammarly",
				"mpls",
				"rumdl",
				"panache",
			},
		},
	},
}
