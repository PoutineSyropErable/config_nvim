local telescope = require("telescope")
local builtin = require("telescope.builtin")

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
		},
	},
	extensions = {
		-- ui-select extension configuration (custom dropdown style)
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- Add extra ui-select options here if needed
			}),
		},
	},
})

-- Load extensions
telescope.load_extension("neoclip")
telescope.load_extension("fzf") -- Ensure fzf-native is compiled if used
telescope.load_extension("ui-select")

-- Uncomment and load additional extensions if needed
-- telescope.load_extension("undo")
-- telescope.load_extension("advanced_git_search")
-- telescope.load_extension("live_grep_args")
-- telescope.load_extension("colors")
-- telescope.load_extension("noice")

-- Enable zoxide integration (for directory navigation)
vim.g.zoxide_use_select = true
