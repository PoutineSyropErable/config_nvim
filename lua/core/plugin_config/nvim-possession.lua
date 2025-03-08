-- Function to determine the session directory based on project root

local function get_session_dir()
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
	local session_dir = project_root .. "/.nvim-session/"
	print("💾 Using session directory:", session_dir) -- Debugging message

	return session_dir
end

require("nvim-possession").setup({
	sessions = {
		sessions_path = get_session_dir(),
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
		local cwd = vim.fn.getcwd()
		local session_dir = cwd .. "/.nvim-session/"

		-- ✅ Ensure directory exists
		if vim.fn.isdirectory(session_dir) == 0 then
			vim.fn.mkdir(session_dir, "p") -- Create directory recursively
			print("📁 Created session directory:", session_dir)
		end

		-- ✅ Only create a new session if none exist **AND** no session was loaded
		local session_file = session_dir .. "/session.vim"
		if vim.fn.filereadable(session_file) == 0 and not require("nvim-possession").status() then
			require("nvim-possession").update() -- Save session **without asking for a name**
			print("📂 Auto-created new session for:", cwd)
		else
			print("📂 Loaded session from:", session_file)
		end

		vim.cmd([[ScopeLoadState]]) -- Restore Scope.nvim tab states
	end,

	-- ✅ Hook: Save Scope.nvim state when saving a session
	save_hook = function()
		local cwd = vim.fn.getcwd()
		local session_dir = cwd .. "/.nvim-session"

		-- ✅ Ensure directory exists before saving
		if vim.fn.isdirectory(session_dir) == 0 then
			vim.fn.mkdir(session_dir, "p") -- Create directory recursively
			print("📁 Created session directory before saving:", session_dir)
		end

		print("💾 Auto-saved session in:", session_dir .. "/session.vim")
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
