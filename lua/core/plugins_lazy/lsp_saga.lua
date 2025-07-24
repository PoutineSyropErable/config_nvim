return {
	"nvimdev/lspsaga.nvim",
	-- event = "LspAttach", -- loads when LSP attaches to a buffer
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- Required for some UI like outline
		"neovim/nvim-lspconfig",
	},
	keys = {
		{
			"$",
			"<cmd>Lspsaga hover_doc<CR>",
			desc = "Hover Information",
		},
		{
			"<leader>LC",
			"<cmd>Lspsaga code_action<CR>",
			desc = "Show code actions (Saga)",
		},
		{
			"<Leader>Lo",
			"<cmd>Lspsaga outline<CR>",
			desc = "Show Outline",
		},
		{
			"<Leader>o",
			"<cmd>Lspsaga outline<CR>",
			desc = "Show Outline",
		},
		{
			"<leader>Lb",
			"<cmd>Lspsaga diagnostic_jump_prev<CR>",
			desc = "Previous diagnostic",
		},
		{
			"<leader>Ln",
			"<cmd>Lspsaga diagnostic_jump_next<CR>",
			desc = "Next diagnostic",
		},
		{ "<Leader>Lf", "<cmd>Lspsaga finder<CR>", desc = "Find symbol references/defs" },

		{ "<leader>Ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Show line diagnostic" },
		{ "<leader>LD", "<cmd>Lspsaga show_workspace_diagnostics<CR>", desc = "Show Workspace diagnostic" },
		{ "<leader>Lb", "<cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Go to previous diagnostic" },
		{ "<leader>Ln", "<cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Go to next diagnostic" },
	},
	config = function()
		require("lspsaga").setup({
			finder = {
				keys = {
					toggle_or_open = "<CR>",
					vsplit = "s",
					split = "i",
					tabe = "t",
					tabnew = "r",
					quit = "q",
					close = "<C-c>k",
					shuttle = "[w",
				},
			},
			outline = {
				keys = {
					toggle_or_jump = "<CR>",
					jump = "h",
					quit = "q",
				},
			},
			diagnostic = {
				max_width = 0.8,
				max_height = 0.6,
				show_layout = "float",
				show_normal_height = 10,
				max_show_width = 0.9,
				max_show_height = 0.6,
				diagnostic_only_current = false,
				text_hl_follow = true,
				border_follow = true,
				show_code_action = true,
				jump_num_shortcut = true,
				extend_relatedInformation = false,
				keys = {
					exec_action = "o",
					quit = { "q", "<ESC>" },
					toggle_or_jump = "<CR>",
					quit_in_show = { "q", "<ESC>" },
				},
			},
		})
	end,
}
