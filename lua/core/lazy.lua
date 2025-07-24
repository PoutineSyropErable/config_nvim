require("lazy").setup({
	-- Import all plugin specs from core.plugins directory
	{ import = "core.plugins" },
	{ import = "core.plugins_lazy" },

	-- Add individual plugins or configs inline
	"folke/which-key.nvim",
	{
		"echasnovski/mini.bufremove",
		lazy = true,
		enabled = true, -- Optional, for conditional toggling
		version = false,
	},
	{ "HawkinsT/pathfinder.nvim", lazy = true },
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = {
			{ "nvim-telescope/telescope.nvim" },
		},
		config = function() require("neoclip").setup() end,
		lazy = true,
	},
})
