require("lspsaga").setup({
	finder = {
		keys = {
			toggle_or_open = "<CR>", -- make Enter key open/jump (default is 'o')
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
			toggle_or_jump = "<CR>", -- make Enter key open/jump (default is 'o')
			jump = "h",
			quit = "q",
		},
	},

	diagnostic = {
		-- Window layout and size
		max_width = 0.8,
		max_height = 0.6,
		show_layout = "float", -- or "normal"
		show_normal_height = 10,
		max_show_width = 0.9,
		max_show_height = 0.6,

		-- Virtual text options
		diagnostic_only_current = false, -- show virtual text only on current line (recommended if using default vim diagnostic virtual text)

		-- Highlight and border follow diagnostic severity
		text_hl_follow = true,
		border_follow = true,

		-- Show code action in diagnostic window
		show_code_action = true,
		jump_num_shortcut = true, -- enable number shortcuts to quickly execute code actions

		-- Extend related information in diagnostic message
		extend_relatedInformation = false,

		-- Keymaps for diagnostic windows
		keys = {
			exec_action = "o", -- execute code action
			quit = { "q", "<ESC>" }, -- quit diagnostic jump window
			toggle_or_jump = "<CR>", -- toggle or jump to diagnostic position
			quit_in_show = { "q", "<ESC>" }, -- quit in diagnostic_show window
		},
	},
})
