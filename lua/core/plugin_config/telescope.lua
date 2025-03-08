local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function create_new_file(prompt_bufnr)
	-- Get the current text from Telescope's prompt
	local new_file = action_state.get_current_line()
	-- Close Telescope picker
	actions.close(prompt_bufnr)
	-- Open the new file in the current buffer
	vim.cmd("edit " .. new_file)
end

-- Setup Telescope with defaults and picker configurations
telescope.setup({
	defaults = {
		-- Ignore node_modules directory
		file_ignore_patterns = { "node_modules/.*" }, -- Ignore node_modules
	},
	pickers = {
		find_files = {
			hidden = true, -- Show hidden files
			no_ignore = true, -- Show git-ignored files
			follow = true, -- Follow symbolic links
			attach_mappings = function(_, map)
				map("i", "<C-n>", create_new_file)
				return true
			end,
		},
	},
	extensions = {
		-- ui-select extension configuration (custom dropdown style)
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- Add extra ui-select options here if needed
			}),
		},
		file_browser = {
			hijack_netrw = true,
		},
		fzf = {
			fuzzy = true, -- Enables fuzzy matching
			override_generic_sorter = true, -- Improves sorting performance
			override_file_sorter = true, -- Faster file sorting
			case_mode = "smart_case", -- Case-insensitive unless input has uppercase
		},
	},
})

-- Load extensions
telescope.load_extension("neoclip")
telescope.load_extension("fzf") -- Ensure fzf-native is compiled if used
telescope.load_extension("ui-select")
telescope.load_extension("file_browser")
telescope.load_extension("scope")

-- Uncomment and load additional extensions if needed
-- telescope.load_extension("undo")
-- telescope.load_extension("advanced_git_search")
-- telescope.load_extension("live_grep_args")
-- telescope.load_extension("colors")
-- telescope.load_extension("noice")

-- Enable zoxide integration (for directory navigation)
vim.g.zoxide_use_select = true
