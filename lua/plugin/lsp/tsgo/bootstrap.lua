--- Prefer native TypeScript (tsc v7+ or tsgo); fall back to mason ts_ls otherwise.

local resolve = require("plugin.lsp.tsgo.resolve")

local M = {}

M.filetypes = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
}

local function project_root(bufnr)
	local root_markers = {
		"package-lock.json",
		"yarn.lock",
		"pnpm-lock.yaml",
		"bun.lockb",
		"bun.lock",
		".git",
	}
	return vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
end

---@param bufnr? integer
function M.native_available(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return resolve.available({ root_dir = project_root(bufnr) })
end

---@param bufnr? integer
function M.enable(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if M.native_available(bufnr) then
		vim.lsp.enable("ts_ls", false)
		vim.lsp.enable("tsgo")
	else
		vim.lsp.enable("tsgo", false)
		vim.lsp.enable("ts_ls")
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("TypescriptLsp", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = M.filetypes,
		callback = function(args)
			M.enable(args.buf)
		end,
	})

	local buf = vim.api.nvim_get_current_buf()
	if vim.tbl_contains(M.filetypes, vim.bo[buf].filetype) then
		M.enable(buf)
	end
end

return M
