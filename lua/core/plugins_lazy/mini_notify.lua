return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.notify").setup({
			history_length = 200,
		})
		vim.notify = require("mini.notify").make_notify()
		vim.keymap.set("n", "<leader>nh", function() require("mini.notify").show_history() end, { desc = "Show mini.notify history" })
		vim.keymap.set("n", "<leader>mh", function() require("mini.notify").show_history() end, { desc = "Show mini.notify history" })
	end,
}
