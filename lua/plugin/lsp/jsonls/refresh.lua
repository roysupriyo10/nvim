--- background job

local schemas = require("plugin.lsp.jsonls.schema")
local M = {}
local refreshing = false
local function notify_jsonls(uris)
	if #uris == 0 then
		return
	end

	for _, client in ipairs(vim.lsp.get_clients({ name = "jsonls" })) do
		for _, uri in ipairs(uris) do
			client:notify("json/schemaContent", uri)
		end
	end
end

local function files_equal(a, b)
	local fa = io.open(a, "rb")

	if not fa then
		return false
	end

	local fb = io.open(b, "rb")
	if not fb then
		fa:close()
		return false
	end

	local ca, cb = fa:read("*a"), fb:read("*a")
	fa:close()
	fb:close()

	return ca == cb
end
---@param entry table
---@param on_done fun(changed: boolean, uri: string)
local function refresh_one(entry, on_done)
	local dest = schemas.path(entry.file)

	local tmp = dest .. ".tmp"
	local uri = schemas.uri(entry.file)
	vim.uv.fs_mkdir(schemas.cache_dir(), 511)
	vim.system({
		"curl",
		"-fsSL",
		entry.remote,
		"-o",
		tmp,
	}, {}, function(obj)
		vim.schedule(function()
			if obj.code ~= 0 then
				vim.fn.delete(tmp, "f")
				on_done(false, uri)
				return
			end
			local changed = not vim.uv.fs_stat(dest) or not files_equal(tmp, dest)
			if changed then
				vim.fn.rename(tmp, dest)
			else
				vim.fn.delete(tmp, "f")
			end
			on_done(changed, uri)
		end)
	end)
end

---@param opts? {force: boolean}
function M.run(opts)
	if refreshing then
		return
	end

	refreshing = true

	local pending = #schemas.entries
	local changed_uris = {}
	if pending == 0 then
		refreshing = false
		return
	end

	for _, entry in ipairs(schemas.entries) do
		refresh_one(entry, function(changed, uri)
			if changed then
				changed_uris[#changed_uris + 1] = uri
			end
			pending = pending - 1
			if pending == 0 then
				notify_jsonls(changed_uris)
				refreshing = false
			end
		end)
	end
end

function M.setup()
	vim.api.nvim_create_user_command("JsonSchemasRefresh", function()
		M.run()
	end, { desc = "Refresh cached JSON schemas for jsonls" })
	if vim.g.jsonls_schema_refresh_done then
		return
	end
	vim.g.jsonls_schema_refresh_done = true
	vim.defer_fn(function()
		M.run()
	end, 1500)
end
return M
