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

	"preservim/vimux",
	{
		"m00qek/baleia.nvim",
		version = "*",
		config = function()
			vim.g.baleia = require("baleia").setup({})

			-- Command to colorize the current buffer
			vim.api.nvim_create_user_command("BaleiaColorize", function() vim.g.baleia.once(vim.api.nvim_get_current_buf()) end, { bang = true })

			-- Command to show logs
			vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { bang = true })
		end,
	},
})
