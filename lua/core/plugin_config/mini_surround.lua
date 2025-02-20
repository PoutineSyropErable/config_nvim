-- config/mini-surround.lua
require("mini.surround").setup({
	-- Add custom surroundings to be used on top of builtin ones. For more
	-- information with examples, see `:h MiniSurround.config`.
	custom_surroundings = {
		["r"] = {
			output = { left = "\27[31m", right = "\27[0m" }, -- Red ANSI
		},
		["g"] = {
			output = { left = "\27[32m", right = "\27[0m" }, -- Green ANSI
		},
		["b"] = {
			output = { left = "\27[34m", right = "\27[0m" }, -- Blue ANSI
		},
	},

	-- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
	highlight_duration = 500,
	-- Module mappings. Use `''` (empty string) to disable one.
	mappings = {
		add = "<leader>Sa", -- Add surrounding in Normal and Visual modes
		delete = "<leader>Sd", -- Delete surrounding
		find = "<leader>Sf", -- Find surrounding (to the right)
		find_left = "<leader>SF", -- Find surrounding (to the left)
		highlight = "<leader>Sh", -- Highlight surrounding
		replace = "<leader>Sr", -- Replace surrounding
		update_n_lines = "<leader>Sn", -- Update `n_lines`

		suffix_last = "l", -- Suffix to search with "prev" method
		suffix_next = "n", -- Suffix to search with "next" method
	},

	-- Number of lines within which surrounding is searched
	n_lines = 20,

	-- Whether to respect selection type:
	-- - Place surroundings on separate lines in linewise mode.
	-- - Place surroundings on each line in blockwise mode.
	respect_selection_type = false,

	-- How to search for surrounding (first inside current line, then inside
	-- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
	-- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
	-- see `:h MiniSurround.config`.
	search_method = "cover",

	-- Whether to disable showing non-error feedback
	silent = false,
})
