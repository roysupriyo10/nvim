-- Over SSH, nvim's default + register uses remote pbcopy/xclip — not your local
-- kitty clipboard. OSC 52 routes yanks through the terminal instead.
if not (vim.env.SSH_CONNECTION or vim.env.SSH_TTY) then
	return
end

local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
if not ok then
	vim.notify("clipboard: vim.ui.clipboard.osc52 unavailable (need Neovim 0.10+)", vim.log.levels.WARN)
	return
end

vim.g.clipboard = {
	name = "OSC52",
	copy = {
		["+"] = osc52.copy,
		["*"] = osc52.copy,
	},
	paste = {
		["+"] = osc52.paste,
		["*"] = osc52.paste,
	},
}
