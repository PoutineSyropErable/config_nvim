-- Detect if the OS is Linux
local is_linux = vim.loop.os_uname().sysname ~= "Windows_NT"

local get_buffer_plugins = require("buffer_manager")
local buffer_plugin = get_buffer_plugins(PRE_CONFIG_FRANCK.use_bufferline)
-- using preconfig like that is dumb for the current setup, but one day, it could be useful

require("lazy").setup({
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	"tpope/vim-commentary",
	"mattn/emmet-vim",
	"nvim-tree/nvim-tree.lua",
	"nvim-tree/nvim-web-devicons",
	"ellisonleao/gruvbox.nvim",
	"dracula/vim",
	"nvim-treesitter/nvim-treesitter",
	"vim-test/vim-test",
	buffer_plugin,
	-- {
	-- 	"Shatur/neovim-session-manager",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- },

	{
		-- "gennaro-tedesco/nvim-possession",
		"PoutineSyropErable/nvim-possession",
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
	{
		"echasnovski/mini.bufremove",
		version = false,
		config = function() end, -- No extra config needed
	},

	"chrisbra/csv.vim",
	"nvim-lualine/lualine.nvim",
	-- "vim-airline/vim-airline",
	-- "vim-airline/vim-airline-themes",
	-- "itchyny/lightline.vim",

	-- DAP core and UI setup
	{
		"mfussenegger/nvim-dap", -- Main nvim-dap plugin
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for nvim-dap
			"nvim-telescope/telescope-dap.nvim", -- Telescope integration with DAP
			"theHamsta/nvim-dap-virtual-text", -- Inline variable text while debugging
			"nvim-neotest/nvim-nio", -- Required dependency for nvim-dap-ui
		},
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

	------- Java Support -----
	PRE_CONFIG_FRANCK.jdtls,
	PRE_CONFIG_FRANCK.java,
	-- BASH DAP support?
	"bash-lsp/bash-language-server",

	-- Terminal file managers (lf)
	{
		"rolv-apneseth/tfm.nvim",
		lazy = false, -- Load the plugin immediately
	},

	"psf/black",

	"preservim/vimux",
	"norcalli/nvim-colorizer.lua",
	{
		"powerman/vim-plugin-AnsiEsc",
		config = function()
			vim.cmd([[
            let g:AnsiEsc_Enabled = 1
        ]])
		end,
	},

	"brenoprata10/nvim-highlight-colors",

	"uga-rosa/ccc.nvim",
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},

	-------------------------------- 	START OF TERMINAL ----------------------------

	-- It just works vv
	"voldikss/vim-floaterm",
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},

	{ "akinsho/toggleterm.nvim", version = "*", config = true },

	-------------------------------- 	END OF TERMINAL ----------------------------
	{
		"numToStr/Comment.nvim",
		config = function() require("Comment").setup() end,
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

	is_linux
			and {
				"alexghergh/nvim-tmux-navigation",
				config = function()
					nvim_tmux_nav = require("nvim-tmux-navigation")
					nvim_tmux_nav.setup({
						disable_when_zoomed = true, -- defaults to false
					})
				end,
			}
		or nil, -- Use `nil` if the condition is false to skip loading
	"TamaMcGlinn/quickfixdd",
	"szw/vim-maximizer",

	{
		"jiaoshijie/undotree",
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
	},

	"lewis6991/gitsigns.nvim",
	"tpope/vim-fugitive",
	"kdheepak/lazygit.nvim",
	"itchyny/vim-gitbranch",

	-- {
	-- 	"sindrets/diffview.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- },
	{
		"akinsho/git-conflict.nvim",
		event = { "BufReadPost" },
		config = function()
			require("git-conflict").setup({
				default_mappings = true, -- enable default keymaps
				disable_diagnostics = true, -- disable lsp diagnostics while resolving
				highlights = {
					incoming = "DiffAdd",
					current = "DiffText",
				},
			})

			-- disable in special buffers like fugitive
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "fugitive", "git", "gitcommit", "gitrebase" },
				callback = function() vim.b.git_conflict_disable = true end,
			})
		end,
	},
	-- "f-person/git-blame.nvim",
	"ThePrimeagen/git-worktree.nvim",
	-- New git plugins vv, needed? idk

	-- {
	-- 	"NeogitOrg/neogit",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim", -- required
	-- 		"sindrets/diffview.nvim", -- optional - Diff integration

	-- 		-- Only one of these is needed.
	-- 		"nvim-telescope/telescope.nvim", -- optional
	-- 	},
	-- 	config = true,
	-- },

	"tpope/vim-rhubarb",
	"tpope/vim-surround",
	-- "airblade/vim-gitgutter",
	"mhinz/vim-signify",

	"szw/vim-maximizer",
	"folke/which-key.nvim",
	"stevearc/oil.nvim",
	-- completion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"L3MON4D3/LuaSnip",
	"rafamadriz/friendly-snippets",
	"hrsh7th/cmp-buffer",
	{ "tiagovla/scope.nvim", config = true },
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"saadparwaiz1/cmp_luasnip",
	-- "mfussenegger/nvim-lint",

	-- {
	-- 	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	-- 	config = function()
	-- 		require("lsp_lines").setup()
	-- 		vim.diagnostic.config({
	-- 			virtual_text = false,
	-- 			virtual_lines = true,
	-- 		})
	-- 	end,
	-- },

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
	-- Lazy.nvim
	{
		"folke/neodev.nvim",
		opts = {}, -- No additional config needed
	},
	"williamboman/mason-lspconfig.nvim",
	"WhoIsSethDaniel/mason-tool-installer.nvim",

	"neovim/nvim-lspconfig",

	{
		"vinnymeller/swagger-preview.nvim",
		run = "npm install -g swagger-ui-watcher",
	},

	-- ✍️ Markdown Support
	{
		"OXY2DEV/markview.nvim",
		lazy = false, -- Recommended
		-- ft = "markdown" -- If you decide to lazy-load anyway

		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"lervag/vimtex",
		lazy = false, -- we don't want to lazy load VimTeX
		-- tag = "v2.15", -- uncomment to pin to a specific release
	},

	-- 🖼️ Image Preview (Kitty Terminal Required) -- Images

	{
		"3rd/image.nvim",
		opts = {},
	},
	-- this should be the right one

	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4", -- Specific version/tag for stable release
		dependencies = { "nvim-lua/plenary.nvim" }, -- Make sure plenary.nvim is available
	},

	-- UI Select extension
	{
		"nvim-telescope/telescope-ui-select.nvim",
		after = "telescope.nvim", -- Load after telescope.nvim
	},

	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},

	-- fzf-native extension (requires building with 'make')
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make", -- Ensure it's compiled
		after = "telescope.nvim", -- Load after telescope.nvim
	},

	{
		"goolord/alpha-nvim",
		dependencies = { "echasnovski/mini.icons" },
		-- dependencies = { 'nvim-tree/nvim-web-devicons' },
	},

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

	-- Noice breaks my print test
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
	-- 		-- "rcarriga/nvim-notify",
	-- 	},
	-- },
	-- {
	-- 	"rcarriga/nvim-notify",
	-- 	lazy = false,
	-- 	config = function()
	-- 		require("notify").setup({
	-- 			stages = "fade",
	-- 			render = "minimal", -- 👈 To avoid line splitting!
	-- 			background_colour = "#ff5577", -- Catppuccin Mocha base
	-- 			timeout = 3000,
	-- 			max_width = 500,
	-- 			merge_duplicates = 2,
	-- 		})

	-- 		-- Override vim.notify
	-- 		vim.notify = require("notify")
	-- 	end,
	-- },
}, {
	rocks = {
		hererocks = true, -- Enables hererocks globally for all plugins
	},
})
