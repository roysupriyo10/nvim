--- On macOS, vim.lsp._watchfiles picks vim._watch.watch (libuv/kqueue), which
--- can EMFILE on large trees. Kill that backend and refuse all registrations
--- so no server (tailwind, etc.) can turn watching back on.

local M = {}

local APPLIED = false

function M.apply()
	if vim.uv.os_uname().sysname ~= "Darwin" or APPLIED then
		return
	end
	APPLIED = true

	local watchfiles = vim.lsp._watchfiles

	-- runtime/lua/vim/lsp/_watchfiles.lua:
	--   if win32 or mac then M._watchfunc = watch.watch
	watchfiles._watchfunc = function()
		return function() end
	end

	function watchfiles.register()
		return
	end
end

return M
