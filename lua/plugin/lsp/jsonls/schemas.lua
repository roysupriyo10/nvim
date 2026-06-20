--- JSON schema manifest for jsonls (remote URLs; bodies live in stdpath cache).

local M = {}

M.entries = {
	{
		file = "package.json",
		fileMatch = { "package.json" },
		remote = "https://json.schemastore.org/package.json",
	},
	{
		file = "tsconfig.json",
		fileMatch = { "tsconfig*.json" },
		remote = "https://json.schemastore.org/tsconfig.json",
	},
	{
		file = "eslintrc.json",
		fileMatch = { ".eslintrc.json", ".eslintrc" },
		remote = "https://json.schemastore.org/eslintrc.json",
	},
	{
		file = "prettierrc.json",
		fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
		remote = "https://json.schemastore.org/prettierrc.json",
	},
	{
		file = "babelrc.json",
		fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
		remote = "https://json.schemastore.org/babelrc.json",
	},
	{
		file = "now.json",
		fileMatch = { "now.json", "vercel.json" },
		remote = "https://json.schemastore.org/now.json",
	},
	{
		file = "stylelintrc.json",
		fileMatch = { ".stylelintrc", ".stylelintrc.json", "stylelint.config.json" },
		remote = "https://json.schemastore.org/stylelintrc.json",
	},
}

function M.cache_dir()
	return vim.fs.joinpath(vim.fn.stdpath("cache"), "jsonls-schemas")
end

---@param file string
function M.path(file)
	return vim.fs.joinpath(M.cache_dir(), file)
end

---@param file string
function M.uri(file)
	return vim.uri_from_fname(M.path(file))
end

---@return table[]
function M.lsp_settings()
	local out = {}
	for _, entry in ipairs(M.entries) do
		out[#out + 1] = {
			fileMatch = entry.fileMatch,
			url = M.uri(entry.file),
		}
	end
	return out
end

return M
