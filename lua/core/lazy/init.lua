local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local specs = { { import = "plugin" } }

-- auto-import plugin subdirectories (lazy doesn't recurse)
local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugin"
for _, entry in ipairs(vim.fn.readdir(plugin_dir)) do
	if vim.fn.isdirectory(plugin_dir .. "/" .. entry) == 1 then
		specs[#specs + 1] = { import = "plugin." .. entry }
	end
end

-- fetch current user for loading specific plugins
local username = os.getenv("USER")
if not username then
	error("$USER environment variable is not set")
end

local user_plugins_path = vim.fn.stdpath("config") .. "/lua/profiles/" .. username .. "/plugins"
if vim.fn.isdirectory(user_plugins_path) == 1 then
	specs[#specs + 1] = {
		import = "profiles." .. username .. ".plugins",
	}
end

require("lazy").setup(specs, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
