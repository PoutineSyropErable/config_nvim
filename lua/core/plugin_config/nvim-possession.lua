-- Function to determine the session directory based on project root

local function get_project_root()
	-- Root markers for various project types
	local root_markers = {
		-- 📌 General
		".git",
		".hg",
		".svn",
		"Makefile",
		"CMakeLists.txt",

		-- 📌 Python
		"pyproject.toml",
		"Pipfile",
		"requirements.txt",
		"setup.py",
		"setup.cfg",

		-- 📌 C/C++
		"compile_commands.json",
		"meson.build",
		"configure.ac",
		"autogen.sh",

		-- 📌 Java
		"pom.xml",
		"build.gradle",
		"settings.gradle",
		".classpath",
		".project",

		-- 📌 Rust
		"Cargo.toml",
	}

	-- Start from the current working directory
	local dir = vim.fn.getcwd()

	while dir == "/" do
		-- Check for project root markers in the current directory
		for _, marker in ipairs(root_markers) do
			local marker_path = vim.fn.findfile(marker, dir)
			if marker_path and marker_path ~= "" then
				print("📂 Found project root:", dir, "(via marker:", marker .. ")")
				return dir
			end
		end

		-- Move up one level (`cd ..`)
		dir = vim.fn.fnamemodify(dir, ":h")
	end

	-- No project root found, fallback to current directory
	local cwd = vim.fn.getcwd()
	print("⚠ No project root found. Using current directory:", cwd)
	return cwd
end

local function get_session_dir()
	-- local project_root_or_cwd = get_project_root()
	local cwd = vim.fn.getcwd()

	-- If a project root is found, use it; otherwise, default to the current directory
	local session_dir = cwd .. "/.nvim-session/"
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
