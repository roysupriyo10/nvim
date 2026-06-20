--- jsonls server config

local schemas = require("plugin.lsp.jsonls.schema")
---@type vim.lsp.Config
return {
	filetypes = {
		"json",
		"jsonc",
	},
	settings = {
		json = {
			schemaDownload = { enable = false },
			schemas = schemas.lsp_settings(),
		},
	},
}
