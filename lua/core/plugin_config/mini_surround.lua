-- config/mini-surround.lua
require("mini.surround").setup({
	-- Add custom surroundings to be used on top of builtin ones. For more
	-- information with examples, see `:h MiniSurround.config`.
	custom_surroundings = {
		-- Standard Colors
		["r"] = { output = { left = "\27[31m", right = "\27[0m" } }, -- Red
		["g"] = { output = { left = "\27[32m", right = "\27[0m" } }, -- Green
		["y"] = { output = { left = "\27[33m", right = "\27[0m" } }, -- Yellow
		["b"] = { output = { left = "\27[34m", right = "\27[0m" } }, -- Blue
		["m"] = { output = { left = "\27[35m", right = "\27[0m" } }, -- Magenta
		["c"] = { output = { left = "\27[36m", right = "\27[0m" } }, -- Cyan
		["w"] = { output = { left = "\27[37m", right = "\27[0m" } }, -- White
		["k"] = { output = { left = "\27[30m", right = "\27[0m" } }, -- Black

		-- Bright Colors
		["R"] = { output = { left = "\27[91m", right = "\27[0m" } }, -- Bright Red
		["G"] = { output = { left = "\27[92m", right = "\27[0m" } }, -- Bright Green
		["Y"] = { output = { left = "\27[93m", right = "\27[0m" } }, -- Bright Yellow
		["B"] = { output = { left = "\27[94m", right = "\27[0m" } }, -- Bright Blue
		["M"] = { output = { left = "\27[95m", right = "\27[0m" } }, -- Bright Magenta
		["C"] = { output = { left = "\27[96m", right = "\27[0m" } }, -- Bright Cyan
		["W"] = { output = { left = "\27[97m", right = "\27[0m" } }, -- Bright White

		-- Styles
		["i"] = { output = { left = "\27[3m", right = "\27[0m" } }, -- Italic
		["u"] = { output = { left = "\27[4m", right = "\27[0m" } }, -- Underline
		["s"] = { output = { left = "\27[9m", right = "\27[0m" } }, -- Strikethrough
		["o"] = { output = { left = "\27[1m", right = "\27[0m" } }, -- Bold
		["d"] = { output = { left = "\27[2m", right = "\27[0m" } }, -- Dim
		["h"] = { output = { left = "\27[7m", right = "\27[0m" } }, -- Inverted (Highlight)
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
