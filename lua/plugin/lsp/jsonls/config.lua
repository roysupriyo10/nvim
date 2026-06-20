--- jsonls server config for vim.lsp.enable("jsonls").
--- Entry point: lsp/jsonls.lua delegates here.
--- Schemas: plugin/lsp/jsonls/schemas.lua (cache under stdpath("cache")).

local schemas = require("plugin.lsp.jsonls.schemas")

---@type vim.lsp.Config
return {
	filetypes = { "json", "jsonc" },
	settings = {
		json = {
			schemaDownload = { enable = false },
			schemas = schemas.lsp_settings(),
		},
	},
}
