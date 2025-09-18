local is_linux = vim.loop.os_uname().sysname ~= "Windows_NT"

local get_buffer_plugins = require("buffer_manager")
local buffer_plugin = get_buffer_plugins(PRE_CONFIG_FRANCK.use_bufferline)

-- using preconfig like that is dumb for the current setup, but one day, it could be useful

require("lazy").setup({
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{
		"numToStr/Comment.nvim", -- check
		config = function() require("Comment").setup() end,
	},
	{
		"nvim-tree/nvim-web-devicons", -- check
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

	{ "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } }, -- check

	{
		"nvim-telescope/telescope.nvim", -- check
		tag = "0.1.4", -- Specific version/tag for stable release
		dependencies = { "nvim-lua/plenary.nvim" }, -- Make sure plenary.nvim is available
	},

	-- UI Select extension
	{
		"nvim-telescope/telescope-ui-select.nvim", -- check
		after = "telescope.nvim", -- Load after telescope.nvim
	},

	{
		"nvim-telescope/telescope-file-browser.nvim", -- check
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},

	-- fzf-native extension (requires building with 'make')
	{
		"nvim-telescope/telescope-fzf-native.nvim", -- check
		build = "make", -- Ensure it's compiled
		after = "telescope.nvim", -- Load after telescope.nvim
	},
	"nvim-treesitter/nvim-treesitter", --check
	{
		"echasnovski/mini.bufremove", -- check
		version = false,
		config = function() end, -- No extra config needed
	},
	buffer_plugin,
<<<<<<< HEAD
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }, -- check
	"andymass/vim-matchup", -- better %-- check
=======

	"andymass/vim-matchup", -- better %
>>>>>>> 317702eb9fcdbe60deade0257434bd21f1aa536c
	{
		"windwp/nvim-autopairs", -- check
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
		-- makes ( auto write ()
	},
	{
		-- "gennaro-tedesco/nvim-possession",
		"PoutineSyropErable/nvim-possession", --- TODO
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
	{ "tiagovla/scope.nvim", config = true }, -- check

	"nvim-lualine/lualine.nvim", -- check

	--------------- completion
	"hrsh7th/nvim-cmp", -- check
	"hrsh7th/cmp-buffer", -- check
	"hrsh7th/cmp-nvim-lsp", -- check
	"hrsh7th/cmp-path", -- check
	"hrsh7th/cmp-cmdline", -- check
	"saadparwaiz1/cmp_luasnip", -- check
	"L3MON4D3/LuaSnip", -- check
	"rafamadriz/friendly-snippets", -- check

	----------------- LSP
	{
		"folke/lazydev.nvim", -- check
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- "jayp0521/mason-null-ls.nvim", -- check
	"neovim/nvim-lspconfig", -- check
	"williamboman/mason.nvim", -- check
	"williamboman/mason-lspconfig.nvim", -- check
	"WhoIsSethDaniel/mason-tool-installer.nvim", -- check
	"jay-babu/mason-nvim-dap.nvim", -- check
	"stevearc/conform.nvim", -- autoformatting -- check

	{
		"nvimdev/lspsaga.nvim", -- check
		config = function() require("lspsaga").setup({}) end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter", -- optional
			"nvim-tree/nvim-web-devicons", -- optional
		},
	},

	"bash-lsp/bash-language-server", -- check
	"psf/black", -- check
	"clangd/clangd", -- check
	"Civitasv/cmake-tools.nvim", -- dont need it
	"elkowar/yuck.vim", -- eww filetype support -- check
	-- "gpanders/nvim-parinfer",
	-- coc.nvm and my lsp seems to be going against each other, so i won't use it

	"mfussenegger/nvim-lint", -- don't use it
	-- {
	--
	-- 	"kosayoda/nvim-lightbulb",
	-- 	event = "LspAttach",
	-- 	opts = {
	-- 		sign = { enabled = false },
	-- 		virtual_text = { enabled = false },
	-- 	},
	-- },

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
		"mfussenegger/nvim-dap", -- Main nvim-dap plugin -- check
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
		"mfussenegger/nvim-dap-python", -- dont need it. ( i dont think)
		dependencies = { "mfussenegger/nvim-dap" }, -- Ensure nvim-dap is loaded first
		lazy = true,
		ft = { "python" }, -- Only load when editing Python files
	},

	--- Neovim + Lua LSP support

	-- DAP core and UI setup

	------- Java Support -----
	PRE_CONFIG_FRANCK.jdtls,
	PRE_CONFIG_FRANCK.java,
	-- BASH DAP support?

	"preservim/vimux", -- TODO TODO NOW TODAY
	-- {
	-- 	"powerman/vim-plugin-AnsiEsc",
	-- 	config = function()
	-- 		vim.cmd([[
	--            let g:AnsiEsc_Enabled = 1
	--        ]])
	-- 	end,
	-- },

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

	"norcalli/nvim-colorizer.lua", -- dont need it
	-- "ellisonleao/gruvbox.nvim",
	-- "dracula/vim",
	"brenoprata10/nvim-highlight-colors", -- check
	"uga-rosa/ccc.nvim", -- color picker -- check

	-------------------------------- 	START OF TERMINAL ----------------------------

	-- Terminal file managers (lf)
	{
		"rolv-apneseth/tfm.nvim", -- check
		lazy = false, -- Load the plugin immediately
	},
	-- -- It just works vv
	"voldikss/vim-floaterm", -- dont need it

	{ "akinsho/toggleterm.nvim", version = "*", config = true }, -- check

	-------------------------------- 	END OF TERMINAL ----------------------------
	{
		"lukas-reineke/indent-blankline.nvim", -- check
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},

	{
		"ThePrimeagen/harpoon", --- MAYBE, TODO
		config = function()
			-- This function will be called after Harpoon is loaded
			require("harpoon").setup({
				-- Configuration options if needed
			})
		end,
	},

	is_linux
			and {
				"alexghergh/nvim-tmux-navigation", -- check
				config = function()
					Nvim_tmux_nav = require("nvim-tmux-navigation")
					Nvim_tmux_nav.setup({
						disable_when_zoomed = true, -- defaults to false
					})
				end,
			}
		or nil, -- Use `nil` if the condition is false to skip loading

	{
		"jiaoshijie/undotree", -- check
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
	},

	"lewis6991/gitsigns.nvim", -- check
	"tpope/vim-fugitive", -- check
	"kdheepak/lazygit.nvim", -- check

	-- {
	-- 	"sindrets/diffview.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim" },
	-- },
	{
		"akinsho/git-conflict.nvim", -- check
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
	"ThePrimeagen/git-worktree.nvim", -- TODO, maybe later
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

	"tpope/vim-surround", -- dont need it. replace <leader>Sa
	-- "airblade/vim-gitgutter",
	"mhinz/vim-signify", -- dont need it, replace git signs
	"tpope/vim-rhubarb", -- check

	"szw/vim-maximizer", -- check
	"folke/which-key.nvim", -- check
	"stevearc/oil.nvim", -- dont need it

	-- ✍️ Markdown Support
	{
		"OXY2DEV/markview.nvim", -- check
		lazy = false, -- Recommended
		-- ft = "markdown" -- If you decide to lazy-load anyway

		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"lervag/vimtex", -- check
		lazy = false, -- we don't want to lazy load VimTeX
		-- tag = "v2.15", -- uncomment to pin to a specific release
	},

	-- 🖼️ Image Preview (Kitty Terminal Required) -- Images

	{
		"3rd/image.nvim", -- check
		opts = {},
	},
	-- this should be the right one

	{
		"goolord/alpha-nvim", -- check
		-- dependencies = { "echasnovski/mini.icons" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Need to configure
	"folke/flash.nvim", -- check
	"abecodes/tabout.nvim", -- it sucks, make my own

	"echasnovski/mini.surround", -- check
	"Wansmer/treesj", -- check

	{
		"AckslD/nvim-neoclip.lua", -- check
		dependencies = { { "kkharji/sqlite.lua", module = "sqlite" }, { "nvim-telescope/telescope.nvim" } },
	},

	{
		-- Need work
		"kevinhwang91/nvim-ufo", -- check (kinda)
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
	"nvim-pack/nvim-spectre", -- check
	{ "HawkinsT/pathfinder.nvim" }, -- check
	-- ^^ For file search
	"vim-test/vim-test",

	"MunifTanjim/nui.nvim",
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
	{
		"emmanueltouzery/decisive.nvim",
		ft = { "csv" },
		lazy = true,
		config = function()
			require("decisive").setup({})
			vim.keymap.set("n", "<leader>csa", ":lua require('decisive').align_csv({})<cr>", { desc = "Align CSV", silent = true })
			vim.keymap.set("n", "<leader>csc", ":lua require('decisive').align_csv_clear({})<cr>", { desc = "Align CSV clear", silent = true })

			vim.keymap.set("n", "[c", ":lua require('decisive').align_csv_prev_col()<cr>", { desc = "Align CSV prev col", silent = true })
			vim.keymap.set("n", "<M-Left>", ":lua require('decisive').align_csv_prev_col()<cr>", { desc = "Align CSV prev col", silent = true })

			vim.keymap.set("n", "]c", ":lua require('decisive').align_csv_next_col()<cr>", { desc = "Align CSV next col", silent = true })
			vim.keymap.set("n", "<M-Right>", ":lua require('decisive').align_csv_next_col()<cr>", { desc = "Align CSV next col", silent = true })
		end,
	},

	--
})
