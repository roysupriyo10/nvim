-- Add dotenv variants that are not covered by the built-in detector.
vim.filetype.add({
	filename = {
		[".env"] = "sh",
	},
	extension = {
		-- marksman + prettier mdx parser expect this compound filetype
		mdx = "markdown.mdx",
	},
	pattern = {
		[".*%.env"] = { "sh", { priority = 100 } },
		["%.env%..*"] = { "sh", { priority = 100 } },
	},
})

-- reuse markdown treesitter for MDX buffers
vim.treesitter.language.register("markdown", "markdown.mdx")
