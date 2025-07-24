local M = {}

local gu = require("_before.general_utils")

M.use_project_root = false

local function telescope_cwd()
	if M.use_project_root then
		return gu.get_lsp_project_root()
		-- return gu.find_project_root(true)
	else
		return vim.fn.getcwd()
	end
end

function M.toggle_find_files()
	M.use_project_root = not M.use_project_root
	print("toggled . " .. vim.inspect(M.use_project_root))
end

function M.find_files()
	local builtin = require("telescope.builtin")
	builtin.find_files({ cwd = telescope_cwd() })
end

function M.live_grep()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ cwd = telescope_cwd() })
end

function M.live_grep_current_word()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ default_text = vim.fn.expand("<cword>"), cwd = telescope_cwd() })
end

local all_symbols = {
	"File",
	"Module",
	"Namespace",
	"Package",
	"Class",
	"Method",
	"Property",
	"Field",
	"Constructor",
	"Enum",
	"Interface",
	"Function",
	"Variable",
	"Constant",
	"String",
	"Number",
	"Boolean",
	"Array",
	"Object",
	"Key",
	"Null",
	"EnumMember",
	"Struct",
	"Event",
	"Operator",
	"TypeParameter",
}

function M.all_document_symbols()
	local builtin = require("telescope.builtin")
	builtin.lsp_document_symbols({
		symbols = all_symbols,
	})
end

-- Function for all symbols across the workspace
function M.all_workspace_symbols()
	local builtin = require("telescope.builtin")
	builtin.lsp_workspace_symbols({
		symbols = all_symbols,
	})
end

return M
