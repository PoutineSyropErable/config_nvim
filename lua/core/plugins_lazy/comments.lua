return {
	"numToStr/Comment.nvim",
	config = function() require("Comment").setup() end,
	lazy = true,
	keys = {
		"gcc", -- line comment toggle (normal mode)
		"gbc", -- block comment toggle (normal mode)
		"gc", -- operator pending line comment (normal + visual)
		"gb", -- operator pending block comment (normal + visual)
		"gco", -- add comment line below (normal mode)
		"gcO", -- add comment line above (normal mode)
		"gcA", -- add comment at end of line (normal mode)
	},
}
