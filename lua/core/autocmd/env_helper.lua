-- Add dotenv variants that are not covered by the built-in detector.
vim.filetype.add({
	filename = {
		[".env"] = "sh",
	},
	pattern = {
		[".*%.env"] = { "sh", { priority = 100 } },
		["%.env%..*"] = { "sh", { priority = 100 } },
	},
})
