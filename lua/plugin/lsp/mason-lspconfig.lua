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
			"tailwindcss",
			-- "ts_ls", -- disabled while trialing tsgo; re-enable to switch back
			"yamlls",
			"tailwindcss",
			"emmet_language_server",
		},
		-- Automatically call vim.lsp.enable() for installed servers.
		-- ts_ls is excluded — replaced by tsgo, see plugin/lsp/tsgo.lua.
		-- markdown: zk only (plugin/lsp/zk.lua); block other markdown LSPs from auto-enable.
		automatic_enable = {
			exclude = {
				"ts_ls",
				"marksman",
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
