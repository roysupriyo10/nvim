-- markdown-only wiring for user comments aimed at coding agents.
-- The feature module is required lazily so it stays off the startup path.
vim.api.nvim_create_augroup("UserComment", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "UserComment",
	pattern = { "markdown", "markdown.mdx" },
	desc = "Attach user comment mappings to markdown buffers",
	callback = function(args)
		require("core.markdown.user_comment").attach(args.buf)
	end,
})
