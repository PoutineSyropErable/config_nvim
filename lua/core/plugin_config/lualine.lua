require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "nightfly",
		component_separators = { left = "", right = "" }, -- Separators between components
		section_separators = { left = "", right = "" }, -- Separators between sections
	},
	sections = {
		lualine_a = {
			{
				"filename",
				path = 1,
			},
		},
		-- lualine_a = { "mode" },
		-- lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = {
			{ "tabs", mode = 1 }, -- Show buffer names in the tabline
		},
		-- lualine_x = { "encoding", "fileformat", "filetype" },
		-- lualine_y = { "progress" },
		-- lualine_z = { "location" },
	},
})
