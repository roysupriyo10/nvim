return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		flavour = "mocha",
		transparent_background = true,
		float = {
			transparent = true,
			solid = false,
		},
		auto_integrations = true,
		show_end_of_buffer = true,
		term_colors = true,
		dim_inactive = { enabled = false },
		styles = {
			strings = { "bold" },
			numbers = { "bold" },
			operators = { "bold" },
			properties = { "italic" },
			functions = { "italic" },
			keywords = { "italic" },
		},
	},
}
