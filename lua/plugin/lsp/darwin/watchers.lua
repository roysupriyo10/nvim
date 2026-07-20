--- Disable LSP file watchers on macOS (EMFILE from vim._watch / libuv).
--- Uses the public Neovim 0.12 capability configuration instead of resolving
--- and wrapping every lsp/*.lua config during startup.

local M = {}

local APPLIED = false

-- These nvim-lspconfig configs explicitly advertise watcher support, which
-- has higher merge priority than the wildcard config below. A named user
-- override has the highest priority and keeps them disabled without loading
-- or evaluating the underlying server configs.
local WATCHER_CAPABILITY_OVERRIDES = {
	"helm_ls",
	"sourcekit",
	"tailwindcss",
}

function M.apply()
	if vim.uv.os_uname().sysname ~= "Darwin" or APPLIED then
		return
	end
	APPLIED = true

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	if capabilities.workspace then
		capabilities.workspace.didChangeWatchedFiles = nil
	end

	vim.lsp.config("*", {
		capabilities = capabilities,
	})

	for _, name in ipairs(WATCHER_CAPABILITY_OVERRIDES) do
		vim.lsp.config(name, {
			capabilities = {
				workspace = {
					didChangeWatchedFiles = {
						dynamicRegistration = false,
					},
				},
			},
		})
	end
end

return M
