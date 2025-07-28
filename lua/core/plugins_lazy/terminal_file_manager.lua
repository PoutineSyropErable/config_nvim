return {
	{
		"rolv-apneseth/tfm.nvim",
		lazy = false, -- Load immediately
		config = function()
			require("tfm").setup({
				file_manager = "lf", -- Use "lf" as the file manager
				replace_netrw = true, -- Replace netrw entirely
				enable_cmds = false, -- Disable commands like Tfm, TfmSplit, etc.

				ui = {
					border = "rounded",
					height = 1,
					width = 1,
					x = 0.5,
					y = 0.5,
				},

				keys = {
					{ "<leader>lf", "<cmd>lua require('tfm').open()<CR>", desc = "Open lf (file manager)" },
					{ "<leader>rr", "<cmd>lua require('tfm').open()<CR>", desc = "TFM" },
					{ "<leader>rv", "<cmd>lua require('tfm').open(nil, require('tfm').OPEN_MODE.split)<CR>", desc = "TFM - horizontal split" },
					{ "<leader>rh", "<cmd>lua require('tfm').open(nil, require('tfm').OPEN_MODE.vsplit)<CR>", desc = "TFM - vertical split" },
					{ "<leader>rt", "<cmd>lua require('tfm').open(nil, require('tfm').OPEN_MODE.tabedit)<CR>", desc = "TFM - new tab" },

					{ "<leader>TT", ":Tfm<CR>", desc = "TFM" },
					{ "<leader>TH", ":TfmSplit<CR>", desc = "TFM - horizontal split" },
					{ "<leader>TV", ":TfmVsplit<CR>", desc = "TFM - vertical split" },
					{ "<leader>TE", ":TfmTabedit<CR>", desc = "TFM - new tab" },
				},
			})
		end,
	},
}
