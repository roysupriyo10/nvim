return {
	"tpope/vim-fugitive",
	cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" },
	keys = {
		{ "<leader>gs", vim.cmd.Git, desc = "Git status (fugitive)" },
	},
}
