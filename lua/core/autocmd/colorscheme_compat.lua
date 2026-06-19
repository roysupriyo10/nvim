local highlights = require("core.highlights")

vim.api.nvim_create_augroup("CoreColorSchemeCompat", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = "CoreColorSchemeCompat",
	desc = "Re-apply core highlight overrides and foldcolumn after colorscheme change",
	callback = function()
		highlights.apply()
		-- Some colorschemes conflict with nvim-ufo and hide the fold gutter.
		vim.schedule(function()
			vim.opt.foldcolumn = "1"
		end)
	end,
})
