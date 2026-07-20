return {
	"kevinhwang91/nvim-ufo",
	lazy = false,
	dependencies = { "kevinhwang91/promise-async" },
	keys = {
		{
			"zR",
			function()
				require("ufo").openAllFolds()
			end,
			desc = "Open all folds",
		},
		{
			"zM",
			function()
				require("ufo").closeAllFolds()
			end,
			desc = "Close all folds",
		},
		{
			"zK",
			function()
				require("ufo").peekFoldedLinesUnderCursor(true)
			end,
			desc = "Peek fold and focus preview",
		},
		{
			"zA",
			"zO",
			mode = "x",
			desc = "Open all folds in selection",
		},
	},
	opts = {
		provider_selector = function()
			return { "treesitter", "indent" }
		end,
	},
	config = function(_, opts)
		local ufo = require("ufo")
		ufo.setup(opts)

		local group = vim.api.nvim_create_augroup("UfoInitialFoldRefresh", { clear = true })
		vim.api.nvim_create_autocmd("BufWinEnter", {
			group = group,
			desc = "Apply asynchronous UFO ranges after the buffer enters a window",
			callback = function(args)
				if vim.b[args.buf].ufo_initial_fold_refresh then
					return
				end
				vim.b[args.buf].ufo_initial_fold_refresh = true

				local attempts = 0
				local function refresh()
					if not vim.api.nvim_buf_is_valid(args.buf) then
						return
					end
					if not vim.api.nvim_buf_is_loaded(args.buf) then
						vim.b[args.buf].ufo_initial_fold_refresh = false
						return
					end

					if vim.fn.bufwinid(args.buf) == -1 then
						vim.b[args.buf].ufo_initial_fold_refresh = false
						return
					end

					if vim.api.nvim_get_mode().mode ~= "n" then
						attempts = attempts + 1
						if attempts < 20 then
							vim.defer_fn(refresh, 25)
						else
							vim.b[args.buf].ufo_initial_fold_refresh = false
						end
						return
					end

					if ufo.hasAttached(args.buf) then
						ufo.enableFold(args.buf)
					else
						vim.b[args.buf].ufo_initial_fold_refresh = false
					end
				end

				vim.defer_fn(refresh, 200)
			end,
		})
	end,
}
