--- Classic tsserver (mason ts_ls) config. Same language settings + buffer maps as tsgo.

local api = require("plugin.lsp.tsgo.api")
local settings = require("plugin.lsp.tsgo.settings")

---@type vim.lsp.Config
return {
	settings = settings.lsp,
	on_attach = api.on_attach,
}
