-- tfm_setup.lua
require("tfm").setup({
	-- TFM to use
	file_manager = "lf", -- Use "yazi" as the file manager
	replace_netrw = true, -- Replace netrw entirely
	enable_cmds = false, -- Disable commands like Tfm, TfmSplit, etc.

	-- UI settings
	ui = {
		border = "rounded",
		height = 1,
		width = 1,
		x = 0.5,
		y = 0.5,
	},
	keys = {
		-- Make sure to change these keybindings to your preference,
		-- and remove the ones you won't use
		{
			"<leader>TT",
			":Tfm<CR>",
			desc = "TFM",
		},
		{
			"<leader>TH",
			":TfmSplit<CR>",
			desc = "TFM - horizontal split",
		},
		{
			"<leader>TV",
			":TfmVsplit<CR>",
			desc = "TFM - vertical split",
		},
		{
			"<leader>TE",
			":TfmTabedit<CR>",
			desc = "TFM - new tab",
		},
	},
})
