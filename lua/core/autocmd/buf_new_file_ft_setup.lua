-- this for lsp detection in new buffers netrw
vim.api.nvim_create_augroup("BufNewFileFiletype", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
	group = "BufNewFileFiletype",
	desc = "Trigger filetype detection after buffer setup",
	callback = function()
		vim.schedule(function()
			vim.cmd("filetype detect")
		end)
	end,
})
