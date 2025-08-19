--  Store session directory once when Neovim starts

local gu = require("_before.general_utils")
local ggu = function() return require("_before.general_utils") end

-- maybe make it so that it requires lsp helper only if there's filename with extension filetype...
local lsp_helper = require("lsps.helper.lsp_config_helper")
-- Define the command to attach all LSPs

local original_location = vim.fn.stdpath("data") .. "/sessions" -- ~/.local/share/nvim/sessions/
local session_dir = original_location
local session_name = vim.g["current_session"] or "default"

-- local bufferline = require("bufferline")
-- local tabpage = require("bufferline.tabpages") -- Ensure it exists
local nvim_possession = require("nvim-possession")

local DEBUG = false -- Set to `true` to enable debug logs

local function get_tab_name(tabnr)
	local ok, name = pcall(vim.api.nvim_tabpage_get_var, tabnr, "name")
	return ok and name or tabnr -- Fallback if name is missing
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
		gu.print_custom("❌ No valid session directory or name")
		return
	end

	local tab_names_file = session_dir .. "/" .. "zzz_" .. session_name .. "-tab-names.json"
	local tab_names = get_all_tab_names()
	local json_data = vim.fn.json_encode(tab_names)

	vim.fn.writefile({ json_data }, tab_names_file)
	if DEBUG then
		gu.print_custom("💾 Tab names saved to: " .. tab_names_file)
	end
end

local function load_tab_names()
	if not session_dir or not session_name then
		if DEBUG then
			gu.print_custom("❌ No valid session directory or name")
		end
		return
	end

	local tab_names_file = session_dir .. "/" .. "zzz_" .. session_name .. "-tab-names.json"

	if vim.fn.filereadable(tab_names_file) == 0 then
		if DEBUG then
			gu.print_custom("❌ No saved tab names found.")
		end
		return
	end

	local json_data = vim.fn.readfile(tab_names_file)[1]
	local tab_names = vim.fn.json_decode(json_data)

	-- Apply the tab names
	for i, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
		if tab_names[i] then
			vim.api.nvim_tabpage_set_var(tabnr, "name", tab_names[i])
		end
	end

	if DEBUG then
		gu.print_custom("✅ Tab names loaded from: " .. tab_names_file)
	end
end

-- This doesnt work cause we need one without user input
local function set_session_dir()
	gu.print_custom("Set session dir is called")
	local project_root = gu.find_project_root(false)
	-- gu.print_custom("setting session dir")
	if project_root == nil then
		-- gu.print_custom("is nill")
		session_dir = original_location
		return original_location
	end
	-- gu.print_custom("project_root = " .. vim.inspect(project_root))

	session_dir = project_root .. "/.nvim-session/"
	if DEBUG then
		gu.print_custom("session dir is : " .. session_dir)
	end
	vim.fn.mkdir(session_dir, "p")
	return session_dir
end

-- Ensure session_dir is available in `nvim-possession`
nvim_possession.setup({
	sessions = {
		sessions_path = set_session_dir(), -- Use stored session_dir
		sessions_variable = "current_session", -- Global variable to track active session
		sessions_icon = "󰀚 ", -- Icon for session names in statusline/UI
		sessions_prompt = "📌 Select Session >", -- Prompt when listing sessions
	},

	-- ✅ Disable automatic session loading (use fzf prompt)
	autoload = false,

	-- ✅ Automatically save session when switching
	autosave = true,

	-- ✅ Automatically switch sessions when navigating projects
	autoswitch = {
		enable = true, -- Enable auto-switching
		exclude_ft = { "NvimTree", "neo-tree", "TelescopePrompt" }, -- Exclude specific filetypes
	},

	-- ✅ Hook: Load Scope.nvim state after loading a session
	post_hook = function()
		local session_file = session_dir .. "/" .. session_name .. ".vim"
		if DEBUG then
			gu.print_custom("📂 Loaded session:", session_file)
		end

		-- vim.cmd([[ScopeLoadState]]) -- Restore Scope.nvim tab states

		-- load_tab_names()
		-- vim.cmd([[AttachAllLSPs]])
	end,

	-- ✅ Hook: Save Scope.nvim state when saving a session
	save_hook = function()
		local session_file = session_dir .. "/" .. session_name .. ".vim"
		-- general_utils_franck.send_notification("auto saving")

		if DEBUG then
			gu.print_custom("💾 Auto-saved session:", session_file)
		end
		vim.cmd([[ScopeSaveState]]) -- Save Scope.nvim tab states
		save_tab_names()
	end,

	-- ✅ Highlighting for session list UI
	fzf_hls = {
		normal = "Normal",
		preview_normal = "Normal",
		border = "Todo",
		preview_border = "Constant",
	},

	-- ✅ Window options for session picker
	fzf_winopts = {
		width = 0.5, -- Set UI width
		preview = {
			vertical = "right:30%", -- Show session preview on right
		},
	},

	-- ✅ Sort sessions by last used time
	sort = require("nvim-possession.sorting").time_sort,
})

local function ensure_session_exists()
	if session_dir == original_location then
		return
	end
	local session_file = session_dir .. session_name .. ".vim"
	gu.print_custom("session file = " .. session_file)
	--
	-- If no session exists, create "default" session
	if vim.fn.filereadable(session_file) == 0 then
		nvim_possession.create(session_name) -- Save session with name "default"
	end
end

-- ensure_session_exists()
gu.print_custom("possession loaded")

local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

keymap.set("n", "<leader>pl", function() require("nvim-possession").list() end, opts("📌list sessions"))
keymap.set("n", "<leader>pc", function() require("nvim-possession").new() end, opts("📌create new session"))
keymap.set("n", "<leader>pu", function() require("nvim-possession").update() end, opts("📌update current session"))
keymap.set("n", "<leader>pm", ":ScopeMoveBuf", opts("move current buffer to the tab nbr"))

local function rename_tab()
	local new_buffer_name = vim.fn.input("Enter new tab name: ")
	if new_buffer_name ~= "" then
		require("bufferline").rename_tab({ new_buffer_name }) -- Pass as a table/array
	else
		gu.print_custom("❌ Tab rename canceled (empty input)")
	end
end
keymap.set("n", "<leader>.r", rename_tab, opts("Rename current tab"))
