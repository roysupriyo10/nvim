--- Disable LSP file watchers on macOS (EMFILE from vim._watch / libuv).
--- Strip didChangeWatchedFiles before initialize: lua nil omits the field; vim.NIL sends null (breaks Go tsc).
---
--- Why not only vim.lsp.config("*")?
--- Resolved configs merge: "*" < rtp lsp/*.lua < user overrides.
--- eslint/tailwind ship their own before_init, which replaces "*" (no chaining).
--- tailwind also sets didChangeWatchedFiles.dynamicRegistration = true in capabilities.

local M = {}

local APPLIED = false

local function strip_watched_files(params)
	local workspace = params.capabilities and params.capabilities.workspace
	if workspace then
		workspace.didChangeWatchedFiles = nil
	end
end

local function config_names()
	local names = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
		:map(function(path)
			local file = path:match("[^/]*%.lua$")
			return file and file:sub(1, #file - 4)
		end)
		:totable()

	vim.list_extend(names, vim.tbl_keys(vim.lsp.config._configs or {}))

	return vim.iter(names)
		:filter(function(name)
			return name ~= "*"
		end)
		:unique()
		:totable()
end

local function wrap_before_init(name)
	local cfg = vim.lsp.config[name]
	if not cfg then
		return
	end

	local orig = cfg.before_init
	vim.lsp.config(name, {
		before_init = function(params, config)
			strip_watched_files(params)
			if orig then
				orig(params, config)
			end
		end,
	})
end

local function disable_watch_register()
	local watchfiles = vim.lsp._watchfiles
	if watchfiles._darwin_disabled then
		return
	end
	watchfiles._darwin_disabled = true

	function watchfiles.register(_reg, _client_id)
		return
	end
end

function M.apply()
	if vim.uv.os_uname().sysname ~= "Darwin" or APPLIED then
		return
	end
	APPLIED = true

	-- Servers without a per-server before_init (e.g. tsgo) inherit this.
	vim.lsp.config("*", {
		before_init = function(params)
			strip_watched_files(params)
		end,
	})

	for _, name in ipairs(config_names()) do
		wrap_before_init(name)
	end

	disable_watch_register()
end

return M
