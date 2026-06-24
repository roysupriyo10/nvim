--- taplo TOML language server (validation + completions).
--- mason installs the binary; this plugin owns enable + root_dir (not mason-lspconfig).

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugin/lsp/taplo",
	name = "taplo-lsp",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		local cfg = require("plugin.lsp.taplo.config")
		if vim.fn.executable(cfg.cmd[1]) == 0 then
			return
		end
		vim.lsp.config("taplo", cfg)
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("taplo_lsp", { clear = true }),
			pattern = "toml",
			callback = function(ev)
				vim.lsp.enable("taplo", true, { bufnr = ev.buf })
			end,
		})
	end,
}
