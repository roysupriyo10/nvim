local M = {}

--- Highlight overrides that must survive `:colorscheme`.
--- Add a group here when a theme leaves it undefined or unreadable.
local OVERRIDES = {
	MatchParen = { bg = "#5a5878", bold = true },
}

function M.apply()
	for group, spec in pairs(OVERRIDES) do
		vim.api.nvim_set_hl(0, group, spec)
	end
end

return M
