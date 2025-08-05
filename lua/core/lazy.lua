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
	{
		"AckslD/nvim-neoclip.lua",
		dependencies = {
			{ "nvim-telescope/telescope.nvim" },
		},
		config = function() require("neoclip").setup() end,
		lazy = true,
	},
	"andymass/vim-matchup", -- better %
	{ -- autocomplete () {}
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
		-- makes ( auto write ()
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
		config = true,
	},
	{
		-- eww filetype support. Widget thing
		"elkowar/yuck.vim",
		ft = "yuck", -- load only for yuck filetype
	},

	"preservim/vimux", -- to configure
	"szw/vim-maximizer", -- good full screen toggle
	{
		-- This does what i wanted baleia to do. Baleia is destructive
		"powerman/vim-plugin-AnsiEsc",
		ft = { "log", "ansi", "txt" },
		cmd = { "AnsiEsc" },
	},
	{
		dir = "~/.config/nvim/tabout_tree",
		-- "PoutineSyropErable/tabout-tree.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function() require("treesitter_inspect").setup() end,
		-- lazy = false  -- Remove comment if you want immediate loading
	},
	{
		"PoutineSyropErable/nvim-possession", --- TODO, make my own
		branch = "main", -- Ensure you're using the correct branch
		dependencies = {
			"ibhagwan/fzf-lua",
			{
				"tiagovla/scope.nvim",
				lazy = false,
				config = true,
			},
		},
		config = true,
	},
})
