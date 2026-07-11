--- Prefer native TypeScript (tsc v7+ or tsgo); fall back to mason ts_ls otherwise.
--- <leader>tlsp toggles preference for the session (default: native).

local resolve = require("plugin.lsp.tsgo.resolve")

local M = {}

--- When true and native is available, use tsgo. Toggle with M.toggle().
M.prefer_native = true

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
---@return "tsgo"|"ts_ls"
function M.active_name(bufnr)
	if M.prefer_native and M.native_available(bufnr) then
		return "tsgo"
	end
	return "ts_ls"
end

---@param bufnr? integer
function M.enable(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if M.active_name(bufnr) == "tsgo" then
		vim.lsp.enable("ts_ls", false)
		vim.lsp.enable("tsgo")
	else
		vim.lsp.enable("tsgo", false)
		vim.lsp.enable("ts_ls")
	end
end

function M.toggle()
	M.prefer_native = not M.prefer_native
	M.enable()

	local name = M.active_name()
	if M.prefer_native and name == "ts_ls" then
		vim.notify("TypeScript LSP: ts_ls (native unavailable)", vim.log.levels.WARN)
	else
		vim.notify("TypeScript LSP: " .. name, vim.log.levels.INFO)
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

	vim.keymap.set("n", "<leader>tlsp", function()
		M.toggle()
	end, { desc = "Toggle TypeScript LSP (tsgo ↔ ts_ls)" })

	local buf = vim.api.nvim_get_current_buf()
	if vim.tbl_contains(M.filetypes, vim.bo[buf].filetype) then
		M.enable(buf)
	end
end

return M
