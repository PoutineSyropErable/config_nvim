return {
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
}
