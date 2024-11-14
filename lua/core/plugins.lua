require("lazy").setup({
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	"tpope/vim-commentary",
	"mattn/emmet-vim",
	"nvim-tree/nvim-tree.lua",
	"nvim-tree/nvim-web-devicons",
	"ellisonleao/gruvbox.nvim",
	"dracula/vim",
	"nvim-lualine/lualine.nvim",
	"nvim-treesitter/nvim-treesitter",
	"vim-test/vim-test",

	-- DAP core and UI setup
	{
		"mfussenegger/nvim-dap", -- Main nvim-dap plugin
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for nvim-dap
			"nvim-telescope/telescope-dap.nvim", -- Telescope integration with DAP
			"theHamsta/nvim-dap-virtual-text", -- Inline variable text while debugging
			"nvim-neotest/nvim-nio", -- Required dependency for nvim-dap-ui
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- DAP UI setup
			dapui.setup()

			-- DAP UI listeners to open/close UI automatically
			dap.listeners.before.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
		lazy = true,
		event = { "BufReadPost", "BufNewFile" }, -- Load when reading/creating files
	},

	-- -- Python DAP support
	{
		"mfussenegger/nvim-dap-python",
		dependencies = { "mfussenegger/nvim-dap" }, -- Ensure nvim-dap is loaded first
		lazy = true,
		ft = { "python" }, -- Only load when editing Python files
	},

	-- BASH DAP support?
	"bash-lsp/bash-language-server",

	"psf/black",
	-- {
	-- 	'jose-elias-alvarez/null-ls.nvim',  -- Required for integrating with Neovim's LSP
	-- 	dependencies = { 'nvim-lua/plenary.nvim' },
	-- 	config = function()
	-- 		local null_ls = require('null-ls')
	--
	-- 		null_ls.setup({
	-- 			sources = {
	-- 				null_ls.builtins.formatting.black,
	-- 				null_ls.builtins.formatting.clang_format,
	-- 			},
	-- 		})
	-- 	end,
	-- },

	"preservim/vimux",
	"norcalli/nvim-colorizer.lua",
	"uga-rosa/ccc.nvim",
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{ "akinsho/toggleterm.nvim", version = "*", config = true },
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},

	{
		"rebelot/terminal.nvim",
		config = function()
			-- Set up the plugin with default configuration
			require("terminal").setup({
				-- Optional: you can provide a custom configuration here
				layout = { open_cmd = "botright new" },
				cmd = { vim.o.shell },
				autoclose = false,
			})
		end,
	},

	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	{
		"ThePrimeagen/harpoon",
		config = function()
			-- This function will be called after Harpoon is loaded
			require("harpoon").setup({
				-- Configuration options if needed
			})
		end,
	},

	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			nvim_tmux_nav = require("nvim-tmux-navigation")

			nvim_tmux_nav.setup({
				disable_when_zoomed = true, -- defaults to false
			})

			--    vim.keymap.set('n', "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
			--    vim.keymap.set('n', "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
			--    vim.keymap.set('n', "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
			--    vim.keymap.set('n', "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
			--    vim.keymap.set('n', "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
			--    vim.keymap.set('n', "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)

			--	vim.keymap.set('', "<C-s>j", nvim_tmux_nav.NvimTmuxNavigateLeft)
			--	vim.keymap.set('', "<C-s>k", nvim_tmux_nav.NvimTmuxNavigateDown)
			--	vim.keymap.set('', "<C-s>i", nvim_tmux_nav.NvimTmuxNavigateUp)
			--	vim.keymap.set('', "<C-s>l", nvim_tmux_nav.NvimTmuxNavigateRight)
			--	vim.keymap.set('', "<C-s>,", nvim_tmux_nav.NvimTmuxNavigateLastActive)
			--	vim.keymap.set('', "<C-s>Space", nvim_tmux_nav.NvimTmuxNavigateNext)
		end,
	},

	"TamaMcGlinn/quickfixdd",
	"szw/vim-maximizer",

	"lewis6991/gitsigns.nvim",
	"github/copilot.vim",
	"tpope/vim-fugitive",
	-- New git plugins vv, needed? idk

	-- "f-person/git-blame.nvim",
	"tpope/vim-rhubarb",
	"tpope/vim-surround",
	"airblade/vim-gitgutter",
	"mhinz/vim-signify",
	"kdheepak/lazygit.nvim",
	"itchyny/vim-gitbranch",

	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
			-- animation = true,
			-- insert_at_start = true,
			-- …etc.
		},
		version = "^1.0.0", -- optional: only update when a new 1.x version is released
	},
	"folke/which-key.nvim",
	"stevearc/oil.nvim",
	-- completion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"L3MON4D3/LuaSnip",
	"rafamadriz/friendly-snippets",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"saadparwaiz1/cmp_luasnip",
	"mfussenegger/nvim-lint",
	"clangd/clangd",
	"Civitasv/cmake-tools.nvim",
	"elkowar/yuck.vim",
	-- "gpanders/nvim-parinfer",
	-- coc.nvm and my lsp seems to be going against each other, so i won't use it

	-- "jayp0521/mason-null-ls.nvim",
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"pyright",
				"clangd",
			},
		},
	},
	"williamboman/mason-lspconfig.nvim",
	"WhoIsSethDaniel/mason-tool-installer.nvim",

	"neovim/nvim-lspconfig",

	{
		"vinnymeller/swagger-preview.nvim",
		run = "npm install -g swagger-ui-watcher",
	},
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	{
		"goolord/alpha-nvim",
		dependencies = { "echasnovski/mini.icons" },
		-- dependencies = { 'nvim-tree/nvim-web-devicons' },
	},

	{
		"Shatur/neovim-session-manager",
		dependencies = { "nvim-lua/plenary.nvim", "akinsho/bufferline.nvim" },
		config = function()
			require("neoclip").setup()
		end,
	},

	"nvim-telescope/telescope-ui-select.nvim",
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	-- Need to configure
	"folke/flash.nvim",
	"abecodes/tabout.nvim",
	"echasnovski/mini.surround",
	"Wansmer/treesj",
	"stevearc/conform.nvim",

	{
		"AckslD/nvim-neoclip.lua",
		dependencies = { "kkharji/sqlite.lua", module = "sqlite" },
		{ "nvim-telescope/telescope.nvim" },
	},

	{
		-- Need work
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
	},

	-- {
	-- 	"folke/noice.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = {
	-- 		-- add any options here
	-- 	},
	-- 	dependencies = {
	-- 		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
	-- 		"MunifTanjim/nui.nvim",
	-- 		-- OPTIONAL:
	-- 		--   `nvim-notify` is only needed, if you want to use the notification view.
	-- 		--   If not available, we use `mini` as the fallback
	-- 		"rcarriga/nvim-notify",
	-- 	},
	-- },

	-- It just works
	"voldikss/vim-floaterm",
})
