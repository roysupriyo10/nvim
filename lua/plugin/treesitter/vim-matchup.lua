return {
	"andymass/vim-matchup",
	event = { "BufReadPost", "BufNewFile" },
	---@type matchup.Config
	opts = {
		treesitter = {
			stopline = 500,
		},
	},
}
