--- Shared typescript/javascript language settings for tsgo and ts_ls.

--- Argument names + parameter types (default). Other hint kinds stay off.
local inlay_hints_args = {
	parameterNames = {
		enabled = "literals",
		suppressWhenArgumentMatchesName = true,
	},
	parameterTypes = { enabled = true },
	variableTypes = { enabled = false },
	propertyDeclarationTypes = { enabled = false },
	functionLikeReturnTypes = { enabled = false },
	enumMemberValues = { enabled = false },
}

--- Full inlay hint set for the "all" toggle mode.
local inlay_hints_all = {
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

local language = {
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
	inlayHints = inlay_hints_args,
	format = { enable = false },
}

return {
	language = language,
	inlay_hints_args = inlay_hints_args,
	inlay_hints_all = inlay_hints_all,
	lsp = {
		typescript = language,
		javascript = language,
	},
}
