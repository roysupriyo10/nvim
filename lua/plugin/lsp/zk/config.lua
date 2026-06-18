--- zk server config for vim.lsp.enable("zk").
--- Requires a zk notebook (directory containing .zk/).
--- Install: https://github.com/zk-org/zk

local api = require("plugin.lsp.zk.api")

---@type vim.lsp.Config
return {
	cmd = { "zk", "lsp" },
	filetypes = { "markdown" },
	root_markers = { ".zk" },
	workspace_required = true,
	on_attach = api.on_attach,
}
