require("core.autocmd")
require("core.option")
require("core.lazy")
require("core.keymap")

local theme_loader = require("core.theme")
local f = io.open(vim.fn.stdpath("data") .. "/colorscheme.txt", "r")
if f then
	local theme = f:read("*l")
	f:close()
	if not pcall(theme_loader.apply, theme) then
		theme_loader.apply("catppuccin")
	end
else
	theme_loader.apply("catppuccin")
end
