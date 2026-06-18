--- Local zk integration (markdown notes in a .zk notebook).
--- Install: https://github.com/zk-org/zk

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugin/lsp/zk",
	name = "zk-lsp",
	ft = { "markdown" },
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		if vim.fn.executable("zk") == 0 then
			vim.notify("zk not found in PATH", vim.log.levels.WARN)
			return
		end
		vim.lsp.enable("zk")
	end,
}
