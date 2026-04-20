-- this is because some colorschemes conflict against nvim-ufo
vim.api.nvim_create_autocmd("ColorScheme", {
	desc = "Force foldcolumn redraw after colorscheme change",
	callback = function()
		vim.schedule(function()
			vim.opt.foldcolumn = "1"
		end)
	end,
})
