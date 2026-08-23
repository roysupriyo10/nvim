-- Keep 'background' in sync with the system appearance.
--
-- Source of truth is ~/.local/bin/appearance (dark|light), the same script
-- every other follower uses — not the terminal's OSC 11 reply, which races
-- startup and is unreliable through tmux. Setting 'background' re-applies the
-- active colorscheme, so 'background'-driven schemes (gruvbox, rose-pine
-- variant="auto") switch live.
--
-- appearance-sync sends SIGUSR1 to every nvim after the terminal theme
-- changes; this is the receiving end. Also applied once at startup, before
-- the colorscheme is chosen (core/init.lua requires this module early).
local M = {}

local function system_mode()
	if vim.fn.executable("appearance") ~= 1 then
		return nil
	end
	local out = vim.fn.system("appearance")
	if vim.v.shell_error ~= 0 then
		return nil
	end
	out = out:gsub("%s+$", "")
	if out == "dark" or out == "light" then
		return out
	end
	return nil
end

function M.apply()
	local mode = system_mode()
	if mode and vim.o.background ~= mode then
		vim.o.background = mode
	end
end

vim.api.nvim_create_augroup("CoreBackgroundSync", { clear = true })

vim.api.nvim_create_autocmd("Signal", {
	group = "CoreBackgroundSync",
	pattern = "SIGUSR1",
	desc = "Sync 'background' to the system appearance",
	callback = M.apply,
})

M.apply()

return M
