require("core.autocmd")
require("core.lazy")
require("core.keymap")
require("core.option")

local f = io.open(vim.fn.stdpath("data") .. "/colorscheme.txt", "r")
if f then
	local theme = f:read("*l")
	f:close()
	pcall(vim.cmd.colorscheme, theme)
else
	vim.cmd.colorscheme("catppuccin")
end
