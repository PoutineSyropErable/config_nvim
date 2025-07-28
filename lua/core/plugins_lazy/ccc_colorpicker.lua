return {
	"uga-rosa/ccc.nvim",
	cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
	keys = {
		{ "<leader>cc", "<cmd>CccPick<cr>", desc = "Pick color (ccc)" },
		{ "<leader>cp", "<cmd>CccPick<cr>", desc = "Pick color (ccc)" },
		{ "<leader>ch", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle color highlighter (ccc)" },
		{ "<leader>ct", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle color highlighter (ccc)" },
	},
	config = function()
		require("ccc").setup({
			highlighter = {
				auto_enable = true,
				lsp = true, -- uses LSP color highlighting if supported
			},
			mappings = {
				-- Directional movement inside sliders
				["i"] = function()
					-- Feed the <Up> key into Neovim's input queue
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Up>", true, false, true), "n", true)
				end,
				["k"] = function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Down>", true, false, true), "n", true) end,
				-- ["k"] = require("ccc.mapping").bar_next, -- move to next slider
				["j"] = require("ccc.mapping").decrease1, -- decrease current slider
				["l"] = require("ccc.mapping").increase1, -- increase current slider
				["J"] = require("ccc.mapping").decrease5, -- bigger decrease
				["L"] = require("ccc.mapping").increase5, -- bigger increase
				["h"] = require("ccc.mapping").cycle_input_mode, -- switch input mode
				["H"] = require("ccc.mapping").cycle_output_mode, -- switch output mode
				["<CR>"] = require("ccc.mapping").complete,
				["q"] = require("ccc.mapping").quit,
				["<Esc>"] = require("ccc.mapping").quit,
			},
		})
	end,
}
