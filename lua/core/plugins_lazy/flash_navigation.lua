return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				char = {
					enabled = true,
					jump_labels = true,
					multi_line = true,
					highlight = {
						matches = true,
						backdrop = false,
					},
					label = { after = { 0, 1 } },
				},
			},
		},
		keys = {
			{
				"rj",
				mode = { "n", "x", "o" },
				function() require("flash").jump() end,
				desc = "Flash jump",
			},
			{
				"rT",
				mode = "n",
				function() require("flash").toggle() end,
				desc = "Toggle Flash Search",
			},
			{
				"rt",
				mode = { "n", "x", "o" },
				function() require("flash").treesitter() end,
				desc = "Flash Treesitter",
			},
			{
				"ro",
				mode = "o",
				function() require("flash").remote() end,
				desc = "Remote Flash",
			},
			{
				"rs",
				mode = { "o", "x" },
				function() require("flash").treesitter_search() end,
				desc = "Treesitter Search",
			},
		},
	},
}
