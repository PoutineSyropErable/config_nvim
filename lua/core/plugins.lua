local is_linux = vim.loop.os_uname().sysname ~= "Windows_NT"

local get_buffer_plugins = require("buffer_manager")
local buffer_plugin = get_buffer_plugins(PRE_CONFIG_FRANCK.use_bufferline)

-- using preconfig like that is dumb for the current setup, but one day, it could be useful

require("lazy").setup({
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{
		"numToStr/Comment.nvim",
		config = function() require("Comment").setup() end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		opts = {
			override = {
				opencl = {
					icon = "", -- or 🖥️ or anything you like
					color = "#ff0065",
					name = "OpenCL",
				},
				["cl"] = {
					icon = "", -- Same icon as above
					color = "#ff0065",
					name = "OpenCL",
				},
			},
		},
	},

	{ "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

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
	"nvim-treesitter/nvim-treesitter",
	{
		"echasnovski/mini.bufremove",
		version = false,
		config = function() end, -- No extra config needed
	},
	buffer_plugin,

	"andymass/vim-matchup", -- better %
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
		-- makes ( auto write ()
	},
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
	{ "tiagovla/scope.nvim", config = true },

	"chrisbra/csv.vim",
	"nvim-lualine/lualine.nvim",

	--------------- completion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"L3MON4D3/LuaSnip",
	"rafamadriz/friendly-snippets",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"saadparwaiz1/cmp_luasnip",

	----------------- LSP

	-- "jayp0521/mason-null-ls.nvim",
	"williamboman/mason.nvim",
	"jay-babu/mason-nvim-dap.nvim",
	"williamboman/mason-lspconfig.nvim",
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	"neovim/nvim-lspconfig",
	"stevearc/conform.nvim", -- autoformatting

	{
		"glepnir/lspsaga.nvim",
		event = "LspAttach",
		opts = {
			code_action = {
				keys = {
					quit = "<ESC>",
					exec = "<CR>",
				},
			},
		},
	},

	"bash-lsp/bash-language-server",
	"psf/black",
	"clangd/clangd",
	"Civitasv/cmake-tools.nvim",
	"elkowar/yuck.vim", -- eww filetype support
	-- "gpanders/nvim-parinfer",
	-- coc.nvm and my lsp seems to be going against each other, so i won't use it

	"mfussenegger/nvim-lint",
	{

		"kosayoda/nvim-lightbulb",
		event = "LspAttach",
		opts = {
			sign = { enabled = false },
			virtual_text = { enabled = false },
		},
	},

	-- linting nicer message on multi lines
	-- {
	-- 	"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	-- 	-- "ErichDonGubler/lsp_lines",
	-- 	config = function()
	-- 		require("lsp_lines").setup()
	-- 		vim.diagnostic.config({
	-- 			virtual_text = false,
	-- 			virtual_lines = true,
	-- 		})
	-- 	end,
	-- },
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

	--- Neovim + Lua LSP support
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- DAP core and UI setup

	------- Java Support -----
	PRE_CONFIG_FRANCK.jdtls,
	PRE_CONFIG_FRANCK.java,
	-- BASH DAP support?

	"preservim/vimux",
	{
		"powerman/vim-plugin-AnsiEsc",
		config = function()
			vim.cmd([[
            let g:AnsiEsc_Enabled = 1
        ]])
		end,
	},

	"norcalli/nvim-colorizer.lua",
	-- "ellisonleao/gruvbox.nvim",
	-- "dracula/vim",
	"brenoprata10/nvim-highlight-colors",
	"uga-rosa/ccc.nvim", -- color picker

	-------------------------------- 	START OF TERMINAL ----------------------------

	-- Terminal file managers (lf)
	{
		"rolv-apneseth/tfm.nvim",
		lazy = false, -- Load the plugin immediately
	},
	-- -- It just works vv
	"voldikss/vim-floaterm",

	{ "akinsho/toggleterm.nvim", version = "*", config = true },

	-------------------------------- 	END OF TERMINAL ----------------------------
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
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
					Nvim_tmux_nav = require("nvim-tmux-navigation")
					Nvim_tmux_nav.setup({
						disable_when_zoomed = true, -- defaults to false
					})
				end,
			}
		or nil, -- Use `nil` if the condition is false to skip loading

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
		"goolord/alpha-nvim",
		-- dependencies = { "echasnovski/mini.icons" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Need to configure
	"folke/flash.nvim",
	"abecodes/tabout.nvim",
	"echasnovski/mini.surround",
	"Wansmer/treesj",

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

	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			require("mini.notify").setup({
				history_length = 200,
			})
			vim.notify = require("mini.notify").make_notify()
		end,
	},
	"nvim-pack/nvim-spectre",
	{ "HawkinsT/pathfinder.nvim" },
	-- ^^ For file search
	"vim-test/vim-test",

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
		},
		{
			"folke/trouble.nvim",
			opts = {}, -- for default options, refer to the configuration section for custom setup.
			cmd = "Trouble",
			keys = {
				{
					"<leader>QD",
					"<cmd>Trouble diagnostics toggle<cr>",
					desc = "Diagnostics (Trouble)",
				},
				{
					"<leader>Qd",
					"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{
					"<leader>Qs",
					"<cmd>Trouble symbols toggle focus=false<cr>",
					desc = "Symbols (Trouble)",
				},
				{
					"<leader>Ql",
					"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
					desc = "LSP Definitions / references / ... (Trouble)",
				},
				{
					"<leader>QL",
					"<cmd>Trouble loclist toggle<cr>",
					desc = "Location List (Trouble)",
				},
				{
					"<leader>QQ",
					"<cmd>Trouble qflist toggle<cr>",
					desc = "Quickfix List (Trouble)",
				},
			},
		},
	},

	--
}, {
	rocks = {
		hererocks = true, -- Enables hererocks globally for all plugins
	},
})
