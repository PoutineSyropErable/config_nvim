require("lazy").setup({
	-- Import all plugin specs from core.plugins directory
	{ import = "core.plugins" },
	{ import = "core.plugins_lazy" },

	-- Add individual plugins or configs inline
	{
		"numToStr/Comment.nvim",
		config = function() require("Comment").setup() end,
	},
})
