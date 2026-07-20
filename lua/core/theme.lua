local M = {}

-- Load the owning plugin explicitly before :colorscheme. This also handles
-- names that collide with Neovim's built-in schemes (notably catppuccin).
local THEME_PLUGINS = {
	["catppuccin"] = "catppuccin",
	["catppuccin-frappe"] = "catppuccin",
	["catppuccin-latte"] = "catppuccin",
	["catppuccin-macchiato"] = "catppuccin",
	["catppuccin-mocha"] = "catppuccin",
	["catppuccin-nvim"] = "catppuccin",
	["cyberdream"] = "cyberdream",
	["cyberdream-light"] = "cyberdream",
	["gruvbox"] = "gruvbox",
	["kanagawa"] = "kanagawa",
	["kanagawa-dragon"] = "kanagawa",
	["kanagawa-lotus"] = "kanagawa",
	["kanagawa-wave"] = "kanagawa",
	["nordic"] = "nordic.nvim",
	["onedark"] = "onedarkpro",
	["onedark_dark"] = "onedarkpro",
	["onedark_vivid"] = "onedarkpro",
	["onelight"] = "onedarkpro",
	["vaporwave"] = "onedarkpro",
	["rose-pine"] = "rose-pine",
	["rose-pine-dawn"] = "rose-pine",
	["rose-pine-main"] = "rose-pine",
	["rose-pine-moon"] = "rose-pine",
	["tokyonight"] = "tokyonight.nvim",
	["tokyonight-day"] = "tokyonight.nvim",
	["tokyonight-moon"] = "tokyonight.nvim",
	["tokyonight-night"] = "tokyonight.nvim",
	["tokyonight-storm"] = "tokyonight.nvim",
}

function M.apply(theme)
	local plugin = THEME_PLUGINS[theme]
	if plugin then
		require("lazy").load({ plugins = { plugin } })
	end

	vim.cmd.colorscheme(theme)
end

return M
