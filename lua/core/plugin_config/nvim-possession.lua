--  Store session directory once when Neovim starts
local session_dir
local session_name = vim.g["current_session"] or "default"
local nvim_possession = require("nvim-possession")
local bufferline = require("bufferline")
local tabpage = require("bufferline.tabpages") -- Ensure it exists

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
		print("❌ No valid session directory or name")
		return
	end

	local tab_names_file = session_dir .. "/" .. "zzz_" .. session_name .. "-tab-names.json"
	local tab_names = get_all_tab_names()
	local json_data = vim.fn.json_encode(tab_names)

	vim.fn.writefile({ json_data }, tab_names_file)
	if DEBUG then
		print("💾 Tab names saved to: " .. tab_names_file)
	end
end

local function load_tab_names()
	if not session_dir or not session_name then
		if DEBUG then
			print("❌ No valid session directory or name")
		end
		return
	end

	local tab_names_file = session_dir .. "/" .. "zzz_" .. session_name .. "-tab-names.json"

	if vim.fn.filereadable(tab_names_file) == 0 then
		if DEBUG then
			print("❌ No saved tab names found.")
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
		print("✅ Tab names loaded from: " .. tab_names_file)
	end
end

-- This doesnt work cause we need one without user input
local function set_session_dir()
	-- Get the absolute path of the current buffer
	local buffer_path = vim.fn.expand("%:p")

	-- Fallback if the buffer is empty
	if buffer_path == "" then
		buffer_path = vim.fn.getcwd()
	end

	local buffer_dir = vim.fn.expand("%:p:h") -- `%:p:h` extracts the directory of the current file
	-- Call the external script and capture the output
	local find_project_root_script = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

	local project_root = vim.fn.system(find_project_root_script .. " " .. vim.fn.shellescape(buffer_dir))
	-- Trim whitespace and newlines
	project_root = project_root:gsub("%s+$", "")

	-- 🚨 **Validation Checks**
	if project_root == "" then
		print("❌ Error: `find_project_root` returned an empty string!")
		return nil
	end

	if #project_root > 256 then
		print("❌ Error: Project root path too long (> 256 chars)!")
		print("\nproject root was: \n(" .. project_root .. ")\n\n")
		return nil
	end

	if project_root:find("[\n\r]") then
		print("❌ Error: Project root contains unexpected newlines!")
		return nil
	end

	if not vim.fn.isdirectory(project_root) then
		print("❌ Error: `find_project_root` did not return a valid directory!")
		return nil
	end

	-- Use the detected project root or fallback to CWD
	session_dir = project_root .. "/.nvim-session/"

	-- Ensure session directory exists (The script takes care of it), hence redundant
	vim.fn.mkdir(session_dir, "p")

	-- Debug message
	-- print("💾 Session directory set to:", session_dir)
	-- ^^this doesn't work
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
	post_hook = function(session_data)
		local session_file = session_dir .. "/" .. session_name .. ".vim"
		if vim.fn.filereadable(session_file) == 0 and not require("nvim-possession").status() then
			require("nvim-possession").new(session_name) -- Save session with "default" name
			-- print("📂 Auto-created new session:", session_file)
		else
			if DEBUG then
				print("📂 Loaded session:", session_file)
			end
		end

		vim.cmd([[ScopeLoadState]]) -- Restore Scope.nvim tab states
		load_tab_names()
	end,

	-- ✅ Hook: Save Scope.nvim state when saving a session
	save_hook = function()
		local session_file = session_dir .. "/" .. session_name .. ".vim"

		if DEBUG then
			print("💾 Auto-saved session:", session_file)
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
	local session_file = session_dir .. session_name .. ".vim"

	-- If no session exists, create "default" session
	if vim.fn.filereadable(session_file) == 0 then
		nvim_possession.create(session_name) -- Save session with name "default"
		-- print("📂 Auto-created session:", session_file)
	end
end

ensure_session_exists()
