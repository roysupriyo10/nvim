--- Native TypeScript server config for vim.lsp.enable("tsgo").
--- Entry point: lsp/tsgo.lua delegates here.

local api = require("plugin.lsp.tsgo.api")
local resolve = require("plugin.lsp.tsgo.resolve")

local function ts_root_dir(bufnr, on_dir)
	local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
	root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
		or vim.list_extend(root_markers, { ".git" })

	local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
	local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })
	local project_root = vim.fs.root(bufnr, root_markers)

	if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
		return
	end
	if deno_root and (not project_root or #deno_root >= #project_root) then
		return
	end

	on_dir(project_root or vim.fn.getcwd())
end

local inlay_hints = {
	parameterNames = {
		enabled = "literals",
		suppressWhenArgumentMatchesName = true,
	},
	parameterTypes = { enabled = true },
	variableTypes = { enabled = true },
	propertyDeclarationTypes = { enabled = true },
	functionLikeReturnTypes = { enabled = true },
	enumMemberValues = { enabled = true },
}

local language_settings = {
	updateImportsOnFileMove = { enabled = "always" },
	updateImportsOnPaste = { enabled = true },
	suggest = {
		completeFunctionCalls = true,
		includeAutomaticOptionalChainCompletions = true,
		includeCompletionsForImportStatements = true,
	},
	preferences = {
		importModuleSpecifier = "shortest",
		importModuleSpecifierEnding = "auto",
		includePackageJsonAutoImports = "auto",
		quoteStyle = "single",
	},
	inlayHints = inlay_hints,
	format = { enable = false },
}

---@type vim.lsp.Config
return {
	cmd = function(dispatchers, config)
		local result = resolve.resolve({ root_dir = (config or {}).root_dir })
		if not result then
			vim.notify(
				"Native TypeScript not found. Install typescript@rc or @typescript/native-preview, or rely on mason ts_ls.",
				vim.log.levels.ERROR
			)
			return
		end
		return vim.lsp.rpc.start({ result.cmd, "--lsp", "--stdio" }, dispatchers)
	end,
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_dir = ts_root_dir,
	settings = {
		typescript = language_settings,
		javascript = language_settings,
	},
	on_attach = api.on_attach,
}
