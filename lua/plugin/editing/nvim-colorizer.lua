return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		user_default_options = {
			names = false,
			tailwind = true,
			css = true,
			mode = "background",
		},
	},
}
