return {
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		cmd = "Telescope", -- load on Telescope command
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
			{ "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Fuzzy Find in Buffer" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recently Used Files" },
			-- Add more keybinds as needed
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-fzf-native.nvim", -- fzf extension
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"AckslD/nvim-neoclip.lua",
			"ghillb/cybu.nvim", -- if you want scope extension (or remove if not needed)
			"tiagovla/scope.nvim",
			"nvim-tree/nvim-tree.lua",

			"mfussenegger/nvim-dap",
			"nvim-telescope/telescope-dap.nvim",
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
		end,
	},
}
