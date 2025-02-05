require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "nightfly",
	},
	sections = {
		lualine_a = {
			{
				"filename",
				path = 1,
			},
		},
		lualine_b = {
			{
				"branch",
				icon = "",
				cond = function()
					return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null") == "true\n"
				end,
			},
		},
	},
})
