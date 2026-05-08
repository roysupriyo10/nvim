return {
	"andymass/vim-matchup",
	event = { "BufReadPost", "BufNewFile" },
	init = function()
		local function set_match_highlight()
			vim.api.nvim_set_hl(0, "MatchParen", {
				bg = "#5a5878",
				bold = true,
			})
		end
		set_match_highlight()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("MatchupHighlight", { clear = true }),
			callback = set_match_highlight,
		})
	end,
	---@type matchup.Config
	opts = {
		treesitter = {
			stopline = 500,
		},
	},
}
