return {
	"Wansmer/treesj",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	keys = {
		{ "<leader>jt", "<cmd>TSJToggle<cr>", desc = "Toggle split/join" },
		{ "<leader>js", "<cmd>TSJSplit<cr>", desc = "Split node" },
		{ "<leader>jj", "<cmd>TSJJoin<cr>", desc = "Join node" },
	},
	opts = {
		-- Keymaps configuration (we set our own above)
		use_default_keymaps = false,

		-- Formatting behavior
		check_syntax_error = true,
		max_join_length = 120,

		-- Cursor behavior
		cursor_behavior = "hold",

		-- Other options
		notify = true,
		dot_repeat = true,
		on_error = nil,

		-- Add language-specific configurations here if needed
		-- langs = {},
	},
	config = function(_, opts) require("treesj").setup(opts) end,
}
