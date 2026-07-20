return {
	"ibhagwan/fzf-lua",
	lazy = true,
	cmd = "FzfLua",
	opts = {
		fzf_opts = {
			["--cycle"] = true,
		},
		winopts = {
			on_close = function()
				-- fzf-lua previews with folding disabled. If the preview buffer is
				-- selected, UFO can retain computed ranges in a pending state.
				vim.defer_fn(function()
					if vim.api.nvim_get_mode().mode ~= "n" then
						return
					end

					local ok, ufo = pcall(require, "ufo")
					if ok and ufo.hasAttached() then
						ufo.enableFold()
					end
				end, 200)
			end,
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
