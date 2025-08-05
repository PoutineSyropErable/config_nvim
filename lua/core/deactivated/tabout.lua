local tabout_keys = {
	forward = "<C-l>", -- Tab out forward
	backward = "<C-k>", -- Tab out backward
}

-- it sucks
-- ( {   }  )

return {
	{
		"abecodes/tabout.nvim",
		lazy = true,
		keys = {
			{
				tabout_keys.forward,
				mode = "i",
				function() require("tabout").tabout() end,
				desc = "Tab out of pairs",
			},
			{
				tabout_keys.backward,
				mode = "i",
				function() require("tabout").taboutBack() end,
				desc = "Tab into pairs",
			},
		},
		config = function()
			require("tabout").setup({
				tabkey = "", -- Disable internal bindings
				backwards_tabkey = "",
				act_as_tab = false, -- Disable tab fallback
				enable_backwards = true,
				completion = false,
				ignore_beginning = false, -- Must be false for multi-level
				tabouts = {

					{ open = "'", close = "'" },
					{ open = '"', close = '"' },
					{ open = "`", close = "`" },
					{ open = "(", close = ")" },
					{ open = "[", close = "]" },
					{ open = "{", close = "}" },
				},
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"hrsh7th/nvim-cmp",
			"L3MON4D3/LuaSnip",
		},
	},
	{
		"L3MON4D3/LuaSnip",
		keys = function() return {} end,
	},
}
