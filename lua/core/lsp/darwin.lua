local M = {}

function M.apply()
	if vim.uv.os_uname().sysname ~= "Darwin" then
		return
	end

	local w = { dynamicRegistration = false }
	local caps = vim.lsp.protocol.make_client_capabilities()
	caps.workspace.didChangeWatchedFiles = w
	vim.lsp.config("*", { capabilities = caps })

	-- lspconfig registers some servers with dynamicRegistration = true (e.g. tailwindcss),
	-- which overrides the "*" default. Re-apply to every known server once lspconfig is loaded.
	local override = {
		capabilities = { workspace = { didChangeWatchedFiles = w } },
	}
	local ok, configs = pcall(require, "lspconfig.configs")
	if ok and type(configs) == "table" then
		for name in pairs(configs) do
			vim.lsp.config(name, override)
		end
	end
end

return M
