return {
	"OXY2DEV/markview.nvim",
	ft = { "markdown", "markdown.mdx", "tex", "latex" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		preview = {
			filetypes = { "markdown", "markdown.mdx", "quarto", "rmd", "typst", "asciidoc" },
		},
	},
}
