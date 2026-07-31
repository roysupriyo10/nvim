--- Deno LSP (denols) config.

local api = require("plugin.lsp.tsgo.api")

local function deno_root_dir(bufnr, on_dir)
	local root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
	if root then
		on_dir(root)
	end
end

---@type vim.lsp.Config
return {
	cmd = { "deno", "lsp" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_dir = deno_root_dir,
	on_attach = api.on_attach,
	settings = {
		deno = {
			enable = true,
			suggest = {
				imports = {
					hosts = {
						["https://deno.land"] = true,
					},
				},
			},
		},
	},
}
