--- Resolve a native TypeScript LSP binary (tsc v7+ or tsgo).
--- Project node_modules first, then global PATH. Nil → ts_ls.

local M = {}

---@class plugin.lsp.tsgo.ResolveResult
---@field cmd string
---@field kind "tsc" | "tsgo"

local version_cache = {}

---@param cmd string
---@return boolean
local function tsc_is_v7(cmd)
	if version_cache[cmd] ~= nil then
		return version_cache[cmd]
	end

	if vim.fn.executable(cmd) ~= 1 then
		version_cache[cmd] = false
		return false
	end

	local out = vim.fn.system({ cmd, "-v" })
	local major = tonumber(out:match("Version%s+(%d+)"))
	local ok = major ~= nil and major >= 7
	version_cache[cmd] = ok
	return ok
end

---@param cmd string
---@return plugin.lsp.tsgo.ResolveResult?
local function try_tsc(cmd)
	if tsc_is_v7(cmd) then
		return { cmd = cmd, kind = "tsc" }
	end
end

---@param cmd string
---@return plugin.lsp.tsgo.ResolveResult?
local function try_tsgo(cmd)
	if vim.fn.executable(cmd) == 1 then
		return { cmd = cmd, kind = "tsgo" }
	end
end

---@param bin_dir string
---@return plugin.lsp.tsgo.ResolveResult?
local function resolve_in_bin_dir(bin_dir)
	return try_tsc(vim.fs.joinpath(bin_dir, "tsc")) or try_tsgo(vim.fs.joinpath(bin_dir, "tsgo"))
end

---@param opts? { root_dir?: string }
---@return plugin.lsp.tsgo.ResolveResult?
function M.resolve(opts)
	opts = opts or {}

	if opts.root_dir then
		local local_result = resolve_in_bin_dir(vim.fs.joinpath(opts.root_dir, "node_modules/.bin"))
		if local_result then
			return local_result
		end
	end

	return try_tsc("tsc") or try_tsgo("tsgo")
end

---@param opts? { root_dir?: string }
---@return boolean
function M.available(opts)
	return M.resolve(opts) ~= nil
end

return M
