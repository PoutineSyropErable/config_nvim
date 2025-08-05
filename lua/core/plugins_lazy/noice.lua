return {

	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"echasnovski/mini.nvim", -- declare dependency
	},
	opts = {
		messages = { enabled = false }, -- Disable Neovim message overrides
		notify = { enabled = false }, -- Disable notify overrides
		routes = {
			{
				view = "cmdline",
				filter = { event = "msg_showmode" },
			},
		},
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
			},
		},
		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = false,
		},
	},
	config = function(_, opts)
		require("noice").setup(opts)

		-- Optional: Add any additional runtime configuration here
		-- For example, key mappings or custom commands
	end,
}
