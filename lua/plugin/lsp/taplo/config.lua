--- taplo server config for vim.lsp.enable("taplo").
--- tmux-manager config uses ~/.config/tmux-manager/taplo.toml (installed by install.sh).

local function taplo_cmd()
	local mason = vim.fs.joinpath(vim.fn.stdpath("data"), "mason/bin/taplo")
	if vim.fn.executable(mason) == 1 then
		return { mason, "lsp", "stdio" }
	end
	return { "taplo", "lsp", "stdio" }
end

---@type vim.lsp.Config
return {
	cmd = taplo_cmd(),
	filetypes = { "toml" },
	single_file_support = true,
	workspace_required = false,
	root_markers = { "taplo.toml", ".taplo.toml", "config.schema.json", ".git" },
	root_dir = function(bufnr, on_dir)
		local name = vim.api.nvim_buf_get_name(bufnr)
		if name == "" then
			return
		end
		local dir = vim.fs.dirname(name)
		local root = vim.fs.root(dir, {
			"taplo.toml",
			".taplo.toml",
			"config.schema.json",
			".git",
		})
		on_dir(root or dir)
	end,
}
