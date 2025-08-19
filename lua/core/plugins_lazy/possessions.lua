local M = {}

local ggu = function() return require("_before.general_utils") end
local USE_CWD_IF_NO_PROJECT = false
local DEBUG = false -- Set to true for debug messages
local original_location = vim.fn.stdpath("data") .. "/sessions"
local session_dir = original_location
local session_name = vim.g["current_session"] or "default"

-- --------------------------
-- Utility functions
-- --------------------------

local function set_session_dir_flattened()
	local project_root = ggu().find_project_root(false)
	if not project_root then
		ggu().print_custom("❌ No project root found; session will use default location")
		return original_location
	end
	local flat_path = project_root:gsub("/", "___")
	session_dir = vim.fn.stdpath("data") .. "/sessions/" .. flat_path .. "/"
	vim.fn.mkdir(session_dir, "p")
	ggu().print_custom("✅ (set_session_dir_flattened: Session directory set to: " .. session_dir)
	return session_dir
end

-- --------------------------
-- Tab names management
-- --------------------------

local function get_tab_name(tabnr)
	local ok, name = pcall(vim.api.nvim_tabpage_get_var, tabnr, "name")
	return ok and name or tabnr
end

local function get_all_tab_names()
	local tab_names = {}
	for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
		table.insert(tab_names, get_tab_name(tabnr))
	end
	return tab_names
end

local function save_tab_names()
	if not session_dir or not session_name then
		return
	end
	local file = session_dir .. "zzz_" .. session_name .. "-tab-names.json"
	vim.fn.writefile({ vim.fn.json_encode(get_all_tab_names()) }, file)
	ggu().print_custom("💾 Tab names saved to: " .. file)
end

local function load_tab_names()
	if not session_dir or not session_name then
		return
	end
	local file = session_dir .. "zzz_" .. session_name .. "-tab-names.json"
	if vim.fn.filereadable(file) == 0 then
		return
	end
	local data = vim.fn.json_decode(vim.fn.readfile(file)[1])
	for i, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
		if data[i] then
			vim.api.nvim_tabpage_set_var(tabnr, "name", data[i])
		end
	end
	ggu().print_custom("✅ Tab names loaded from: " .. file)
end

-- --------------------------
-- Config function (lazy-safe)
-- --------------------------

function M.config()
	local nvim_possession = require("nvim-possession") -- require inside config
	local lsp_helper = require("lsps.helper.lsp_config_helper")

	nvim_possession.setup({
		sessions = {
			sessions_path = set_session_dir_flattened(),
			sessions_variable = "current_session",
			sessions_icon = "󰀚 ",
			sessions_prompt = "📌 Select Session >",
		},
		autoload = false,
		autosave = true,
		autoswitch = {
			enable = true,
			exclude_ft = { "NvimTree", "neo-tree", "TelescopePrompt" },
		},
		post_hook = function()
			vim.cmd([[ScopeLoadState]])
			load_tab_names()
			vim.cmd([[AttachAllLSPs]])
			vim.cmd("doautocmd User PossessionSessionLoaded")
		end,
		save_hook = function()
			vim.cmd([[ScopeSaveState]])
			save_tab_names()
		end,
		sort = require("nvim-possession.sorting").time_sort,
	})

	local session_file = session_dir .. session_name .. ".vim"
	ggu().print_custom("user_config: session file is " .. vim.inspect(session_file))
	if vim.fn.filereadable(session_file) == 0 then
		nvim_possession.create(session_name)
	end

	-- Keymaps
	local keymap = vim.keymap
	local function opts(desc) return { noremap = true, silent = true, desc = desc } end
	keymap.set("n", "<leader>pl", function() require("nvim-possession").list() end, opts("📌list sessions"))
	keymap.set("n", "<leader>pc", function() require("nvim-possession").new() end, opts("📌create new session"))
	keymap.set("n", "<leader>pu", function() require("nvim-possession").update() end, opts("📌update current session"))
	keymap.set("n", "<leader>pD", function() require("nvim_possession").wipe_all_sessions() end, opts("📌wipe all session files"))
end

-- --------------------------
-- Return lazy.nvim plugin spec
-- --------------------------

return {
	"PoutineSyropErable/nvim-possession", --- TODO, make my own
	branch = "main",
	dependencies = {
		"ibhagwan/fzf-lua",
		{
			"tiagovla/scope.nvim",
			lazy = false,
			config = true,
		},
	},
	config = M.config,
	lazy = true,
	keys = {
		{ "<leader>pl", function() require("nvim-possession").list() end, desc = "📌 list sessions" },
		{ "<leader>pc", function() require("nvim-possession").new() end, desc = "📌 create new session" },
		{ "<leader>pu", function() require("nvim-possession").update() end, desc = "📌 update current session" },
		{ "<leader>pD", function() require("nvim-possession").wipe_all_sessions() end, desc = "📌 wipe all session files" },
	},
}
