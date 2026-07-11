--- Shared typescript/javascript language settings for tsgo and ts_ls.

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
	inlayHints = inlay_hints,
	format = { enable = false },
}

return {
	language = language,
	lsp = {
		typescript = language,
		javascript = language,
	},
}
