return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = "nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	branch = "main",
	init = function()
		vim.g.no_plugin_maps = true
	end,
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = { query = "@function.outer", desc = "Around function" },
					["if"] = { query = "@function.inner", desc = "Inside function" },
					["ac"] = { query = "@class.outer", desc = "Around class" },
					["ic"] = { query = "@class.inner", desc = "Inside class" },
					["aa"] = { query = "@parameter.outer", desc = "Around argument" },
					["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]f"] = { query = "@function.outer", desc = "Next function start" },
					["]c"] = { query = "@class.outer", desc = "Next class start" },
					["]a"] = { query = "@parameter.inner", desc = "Next argument" },
				},
				goto_previous_start = {
					["[f"] = { query = "@function.outer", desc = "Prev function start" },
					["[c"] = { query = "@class.outer", desc = "Prev class start" },
					["[a"] = { query = "@parameter.inner", desc = "Prev argument" },
				},
			},
			swap = {
				enable = true,
				swap_next = { ["<leader>sa"] = { query = "@parameter.inner", desc = "Swap with next arg" } },
				swap_previous = { ["<leader>sA"] = { query = "@parameter.inner", desc = "Swap with prev arg" } },
			},
		})
	end,
}
