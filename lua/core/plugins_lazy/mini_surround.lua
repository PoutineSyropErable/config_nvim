return {
	{
		"echasnovski/mini.surround",
		version = false,
		event = "VeryLazy", -- or "BufReadPre" if you want it slightly earlier
		opts = {
			custom_surroundings = {
				-- Standard Colors
				["r"] = { output = { left = "\27[31m", right = "\27[0m" } },
				["g"] = { output = { left = "\27[32m", right = "\27[0m" } },
				["y"] = { output = { left = "\27[33m", right = "\27[0m" } },
				["b"] = { output = { left = "\27[34m", right = "\27[0m" } },
				["m"] = { output = { left = "\27[35m", right = "\27[0m" } },
				["c"] = { output = { left = "\27[36m", right = "\27[0m" } },
				["w"] = { output = { left = "\27[37m", right = "\27[0m" } },
				["k"] = { output = { left = "\27[30m", right = "\27[0m" } },

				-- Bright Colors
				["R"] = { output = { left = "\27[91m", right = "\27[0m" } },
				["G"] = { output = { left = "\27[92m", right = "\27[0m" } },
				["Y"] = { output = { left = "\27[93m", right = "\27[0m" } },
				["B"] = { output = { left = "\27[94m", right = "\27[0m" } },
				["M"] = { output = { left = "\27[95m", right = "\27[0m" } },
				["C"] = { output = { left = "\27[96m", right = "\27[0m" } },
				["W"] = { output = { left = "\27[97m", right = "\27[0m" } },

				-- Styles
				["i"] = { output = { left = "\27[3m", right = "\27[0m" } },
				["u"] = { output = { left = "\27[4m", right = "\27[0m" } },
				["s"] = { output = { left = "\27[9m", right = "\27[0m" } },
				["o"] = { output = { left = "\27[1m", right = "\27[0m" } },
				["d"] = { output = { left = "\27[2m", right = "\27[0m" } },
				["h"] = { output = { left = "\27[7m", right = "\27[0m" } },
			},
			highlight_duration = 500,
			mappings = {
				add = "<leader>Sa",
				delete = "<leader>Sd",
				find = "<leader>Sf",
				find_left = "<leader>SF",
				highlight = "<leader>Sh",
				replace = "<leader>Sr",
				update_n_lines = "<leader>Sn",
				suffix_last = "l",
				suffix_next = "n",
			},
			n_lines = 20,
			respect_selection_type = false,
			search_method = "cover",
			silent = false,
		},
	},
}
