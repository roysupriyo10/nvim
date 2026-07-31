return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format({ async = false })
			end,
			desc = "Format buffer",
		},
	},
	opts = {
		default_format_opts = {
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			javascript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			html = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			jsonc = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
			python = { "ruff_format", "black", stop_after_first = true },
			go = { "gofmt", "goimports" },
			rust = { "rustfmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			lua = { "stylua" },
			sh = { "shfmt" },
			toml = { "taplo" },
		},
		formatters = {
			-- prettierd infers from the .mdx filename; prettier needs an explicit parser
			prettier = {
				options = {
					ft_parsers = {
						["markdown.mdx"] = "mdx",
					},
				},
			},
		},
		format_on_save = {
			timeout_ms = 500,
		},
	},
}
