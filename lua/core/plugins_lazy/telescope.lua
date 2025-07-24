local hp = "core.plugins_lazy.helper.telescope"

return {
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		cmd = "Telescope", -- load on Telescope command
		keys = {
			{
				"<leader>ff",
				function() require(hp).find_files() end,
				desc = "Find Files",
			},

			{
				"<leader>ft",
				function() require("core.plugins_lazy.helper.telescope").toggle_find_files() end,
				desc = "Toggle Find Files (Project Root / CWD)",
			},

			{
				"<leader>fg",
				function() require(hp).live_grep() end,
				desc = "Live grep",
			},
			{
				"<leader>fw",
				function() require(hp).live_grep_current_word() end,
				desc = "Live grep current word",
			},
			{
				"gw",
				function() require(hp).live_grep_current_word() end,
				desc = "Live grep current word",
			},

			{
				"<leader>fs",
				function() require("core.plugins_lazy.helper.lsp").all_document_symbols() end,
				desc = "All Variable/Symbols Information (Document)",
			},
			{
				"<leader>fS",
				function() require("core.plugins_lazy.helper.lsp").all_workspace_symbols() end,
				desc = "All Variable/Symbols Information (Workspace)",
			},
			{ "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Find Keymaps" },

			{ "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Fuzzy Find in Buffer" },
			{ "<leader>fG", "<cmd>Telescope grep_string", desc = "grep string" },

			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recently Used Files" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },

			{ "<leader>fB", "<cmd>Telescope file_browser<CR>", desc = "File Browser" },
			{ "<leader><leader>", "<cmd>Telescope file_browser<CR>", desc = "File Browser" },
			{ "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help Tags" },
			{ "<leader>fi", "<cmd>Telescope lsp_incoming_calls<CR>", desc = "Incoming Calls" },
			{ "<leader>fm", "<cmd>Telescope treesitter default_text=:method:<CR>", desc = "Find Methods" },
			{ "<leader>fF", "<cmd>Telescope treesitter default_text=:function:<CR>", desc = "Find Functions" },
			{ "<leader>fn", "<cmd>Telescope neoclip<CR>", desc = "Telescope Neoclip" },
			{ "<leader>fr", "<cmd>lua select_and_write_function()<CR>", desc = "Select and Write Function" },
			{ "<leader>fc", "<cmd>Telescope colorscheme<CR>", desc = "Change Color Scheme" },
			-- Add more keybinds as needed
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-fzf-native.nvim", -- fzf extension
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"AckslD/nvim-neoclip.lua",
			"nvim-treesitter/nvim-treesitter",

			"mfussenegger/nvim-dap",
			"nvim-telescope/telescope-dap.nvim",

			"nvim-tree/nvim-tree.lua",
			"tiagovla/scope.nvim",
			"ghillb/cybu.nvim", -- if you want scope extension (or remove if not needed)
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local tapi = require("nvim-tree.api")

			local function create_new_file(prompt_bufnr)
				local new_file = action_state.get_current_line()
				actions.close(prompt_bufnr)
				vim.cmd("edit " .. new_file)
			end

			telescope.setup({
				defaults = {
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							width = 0.95,
							height = 0.9,
							preview_width = 0.5,
						},
						vertical = {
							width = 0.9,
							height = 0.95,
							preview_height = 0.5,
						},
					},
					file_ignore_patterns = { "node_modules/.*", "%.git/.*", ".nvim-session/.*" },
				},
				pickers = {
					find_files = {
						hidden = true,
						no_ignore = true,
						follow = true,
						attach_mappings = function(_, map)
							map("i", "<C-n>", create_new_file)
							return true
						end,
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
					file_browser = {
						hijack_netrw = true,
						hidden = true,
						respect_gitignore = false,
						grouped = true,
						mappings = {
							i = {
								["<CR>"] = function(prompt_bufnr)
									local entry = action_state.get_selected_entry()
									if entry then
										local file_dir = vim.fn.fnamemodify(entry.path, ":h")
										vim.cmd("tcd " .. vim.fn.fnameescape(file_dir))
										tapi.tree.change_root(file_dir)
										vim.notify("Telescope: Changed tab directory to: " .. file_dir)
									end
									actions.select_default(prompt_bufnr)
								end,
							},
						},
					},
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})

			-- Load extensions
			telescope.load_extension("neoclip")
			telescope.load_extension("fzf")
			telescope.load_extension("ui-select")
			telescope.load_extension("file_browser")
			telescope.load_extension("scope")
			telescope.load_extension("dap")

			-- Optional extensions can be loaded as needed:
			-- telescope.load_extension("undo")
			-- telescope.load_extension("advanced_git_search")
			-- telescope.load_extension("live_grep_args")
			-- telescope.load_extension("colors")
			-- telescope.load_extension("noice")

			-- Enable zoxide integration for directory navigation
			vim.g.zoxide_use_select = true

			--- special keymaps ---
			local th = require(hp)
			local function opts(desc) return { noremap = true, silent = true, desc = desc } end
			local keymap = vim.keymap
		end,
	},
}
