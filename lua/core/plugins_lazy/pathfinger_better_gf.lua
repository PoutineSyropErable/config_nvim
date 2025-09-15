return {
	"HawkinsT/pathfinder.nvim",
	lazy = true,
	keys = {
		{ "gf", function() require("pathfinder").gf() end, desc = "Enhanced go to file", mode = "n", noremap = true, silent = true },
		{ "gF", function() require("pathfinder").gF() end, desc = "Enhanced go to file with line", mode = "n", noremap = true, silent = true },
		{
			"gX",
			function() require("pathfinder").gx() end,
			desc = "Navigate to the count'th URL or Git repo after the cursor",
			mode = "n",
			noremap = true,
			silent = true,
		},
	},
	config = function()
		local keymap = vim.keymap
		local function opts(desc) return { noremap = true, silent = true, desc = desc } end

		keymap.set("n", "gf", function() require("pathfinder").gf() end, opts("Enhanced go to file"))
		keymap.set("n", "gF", function() require("pathfinder").gF() end, opts("Enhanced go to file with line"))
		keymap.set("n", "gX", function() require("pathfinder").gX() end, opts("Navigate to the count'th URL or Git repo after the cursor"))
	end,
}
