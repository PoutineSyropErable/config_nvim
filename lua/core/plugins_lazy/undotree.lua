return {
	{
		"jiaoshijie/undotree",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = { {
			"<leader>u",
			function() require("undotree").toggle() end,
			desc = "Toggle undo tree",
		} },
		config = function()
			local undotree = require("undotree")
			undotree.setup({
				float_diff = true,
				layout = "left_bottom",
				position = "left",
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
		end,
	},
}
