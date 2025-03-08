--  Store session directory once when Neovim starts
local session_dir
local session_name = "default" -- Default session name
local nvim_possession = require("nvim-possession")

-- This doesnt work cause we need one without user input
local function set_session_dir()
	-- Get the absolute path of the current buffer
	local buffer_path = vim.fn.expand("%:p")

	-- Fallback if the buffer is empty
	if buffer_path == "" then
		buffer_path = vim.fn.getcwd()
	end

	-- Call the external script and capture the output
	local find_project_root_script = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")
	local project_root = vim.fn.system(find_project_root_script .. " " .. vim.fn.shellescape(buffer_path))

	-- Trim whitespace/newlines
	project_root = project_root:gsub("%s+$", "")

	-- Use the detected project root or fallback to CWD
	session_dir = project_root .. "/.nvim-session/"

	-- Ensure session directory exists (The script takes care of it), hence redundant
	vim.fn.mkdir(session_dir, "p")

	-- Debug message
	print("💾 Session directory set to:", session_dir)
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
	post_hook = function()
		local session_file = session_dir .. "/" .. session_name .. ".vim"
		if vim.fn.filereadable(session_file) == 0 and not require("nvim-possession").status() then
			require("nvim-possession").new(session_name) -- Save session with "default" name
			-- print("📂 Auto-created new session:", session_file)
		else
			print("📂 Loaded session:", session_file)
		end

		vim.cmd([[ScopeLoadState]]) -- Restore Scope.nvim tab states
	end,

	-- ✅ Hook: Save Scope.nvim state when saving a session
	save_hook = function()
		local session_file = session_dir .. "/" .. session_name .. ".vim"
		print("💾 Auto-saved session:", session_file)
		vim.cmd([[ScopeSaveState]]) -- Save Scope.nvim tab states
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
