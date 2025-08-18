local undotree = require("undotree")

undotree.setup({
	float_diff = true, -- using float window previews diff, set this `true` will disable layout option
	layout = "left_bottom", -- "left_bottom", "left_left_bottom"
	position = "left", -- "right", "bottom"
	ignore_filetype = { "undotree", "undotreeDiff", "qf", "TelescopePrompt", "spectre_panel", "tsplayground" },
	window = {
		winblend = 30,
	},
	keymaps = {
		["k"] = "move_next",
		["i"] = "move_prev",
		["gp"] = "move2parent",
		["K"] = "move_change_next",
		["I"] = "move_change_prev",
		["<cr>"] = "action_enter",
		["d"] = "enter_diffbuf",
		["q"] = "quit",
	},
})
