local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	defaults = {
		file_ignore_patterns = { "node%_modules/.*" }, -- Ignore node_modules
	},
	pickers = {
		find_files = {
			hidden = true, -- Show hidden files
			no_ignore = true, -- Show git-ignored files
			follow = true, -- Follow symbolic links
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- Add extra ui-select options here if needed
			}),
		},
	},
})

-- Load extensions
telescope.load_extension("neoclip")
telescope.load_extension("fzf")
telescope.load_extension("ui-select")

-- Uncomment these if you plan to use them
-- telescope.load_extension("undo")
-- telescope.load_extension("advanced_git_search")
-- telescope.load_extension("live_grep_args")
-- telescope.load_extension("colors")
-- telescope.load_extension("noice")

-- Enable zoxide select
vim.g.zoxide_use_select = true
