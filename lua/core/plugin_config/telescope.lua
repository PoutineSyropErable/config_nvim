require("telescope").setup({ file_ignore_patterns = { "node%_modules/.*" } })
local builtin = require("telescope.builtin")

require("telescope").load_extension("neoclip")
--require("telescope").load_extension("fzf")

require("telescope").load_extension("ui-select")
vim.g.zoxide_use_select = true

--require("telescope").load_extension("undo")

--require("telescope").load_extension("advanced_git_search")

--require("telescope").load_extension("live_grep_args")

-- require("telescope").load_extension("colors")

-- require("telescope").load_extension("noice")
