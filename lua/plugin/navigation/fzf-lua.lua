return {
	"ibhagwan/fzf-lua",
	lazy = false,
	opts = {
		fzf_opts = {
			["--cycle"] = true,
		},
		preview = {
			"wrap",
		},
	},
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		fzf.register_ui_select()
	end,
}
