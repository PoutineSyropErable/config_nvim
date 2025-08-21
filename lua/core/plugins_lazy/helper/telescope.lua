local M = {}

local ggu = function() return require("_before.general_utils") end
local get_root = function() return ggu().find_project_root() or vim.fn.getcwd() end

function M.find_files()
	local builtin = require("telescope.builtin")
	builtin.find_files({ cwd = vim.fn.getcwd() })
end

function M.find_files_in_project()
	local builtin = require("telescope.builtin")
	builtin.find_files({ cwd = get_root() })
end

function M.live_grep()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ cwd = vim.fn.getcwd() })
end

function M.live_grep_in_project()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ cwd = get_root() })
end

function M.live_grep_current_word()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ default_text = vim.fn.expand("<cword>"), cwd = vim.fn.getcwd() })
end

function M.live_grep_current_word_in_project()
	local builtin = require("telescope.builtin")
	builtin.live_grep({ default_text = vim.fn.expand("<cword>"), cwd = get_root() })
end

function M.grep_current_big_word()
	local builtin = require("telescope.builtin")
	builtin.grep_string({ search = vim.fn.expand("<cword>"), cwd = vim.fn.getcwd() })
end

function M.grep_current_big_word_in_project()
	local builtin = require("telescope.builtin")
	builtin.grep_string({ search = vim.fn.expand("<cword>"), cwd = get_root() })
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
