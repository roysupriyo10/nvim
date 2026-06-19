local M = {}

function M.apply()
	if vim.uv.os_uname().sysname ~= "Darwin" then
		return
	end

	local caps = vim.lsp.protocol.make_client_capabilities()
	-- nil (not dynamicRegistration=false): still advertises watchers; eslint/tailwindcss EMFILE on macOS.
	caps.workspace.didChangeWatchedFiles = nil
	vim.lsp.config("*", { capabilities = caps })

	-- lspconfig registers some servers with watcher caps (e.g. tailwindcss),
	-- which overrides the "*" default. Re-apply to every known server once lspconfig is loaded.
	local override = {
		capabilities = { workspace = { didChangeWatchedFiles = nil } },
	}
	local ok, configs = pcall(require, "lspconfig.configs")
	if ok and type(configs) == "table" then
		for name in pairs(configs) do
			vim.lsp.config(name, override)
		end
	end
end

return M
