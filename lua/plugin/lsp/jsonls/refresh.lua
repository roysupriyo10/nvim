--- Populate stdpath cache from schemastore; notify jsonls when files change.

local schemas = require("plugin.lsp.jsonls.schemas")

local M = {}

local refreshing = false

local function unlink(path)
	pcall(vim.uv.fs_unlink, path)
end

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
	local same = fa:read("*a") == fb:read("*a")
	fa:close()
	fb:close()
	return same
end

---@param entry table
---@param on_done fun(changed: boolean, uri: string)
local function refresh_one(entry, on_done)
	local dest = schemas.path(entry.file)
	local tmp = dest .. ".tmp"
	local uri = schemas.uri(entry.file)

	vim.system({ "curl", "-fsSL", entry.remote, "-o", tmp }, {}, function(obj)
		vim.schedule(function()
			if obj.code ~= 0 then
				unlink(tmp)
				on_done(false, uri)
				return
			end

			local changed = not vim.uv.fs_stat(dest) or not files_equal(tmp, dest)
			if changed then
				vim.fn.rename(tmp, dest)
			else
				unlink(tmp)
			end
			on_done(changed, uri)
		end)
	end)
end

function M.cache_missing()
	for _, entry in ipairs(schemas.entries) do
		if not vim.uv.fs_stat(schemas.path(entry.file)) then
			return true
		end
	end
	return false
end

function M.run()
	if refreshing then
		return
	end
	refreshing = true
	vim.uv.fs_mkdir(schemas.cache_dir(), 511)

	local pending = #schemas.entries
	local changed_uris = {}

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
	end, { desc = "Download/update JSON schemas for jsonls" })

	if M.cache_missing() then
		M.run()
	end
end

return M
