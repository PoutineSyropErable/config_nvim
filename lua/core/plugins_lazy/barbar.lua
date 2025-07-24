return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- optional: for git status
		"nvim-tree/nvim-web-devicons", -- optional: for file icons
	},
	init = function() vim.g.barbar_auto_setup = false end,
	config = function()
		require("barbar").setup({
			animation = true,
			auto_hide = false,
			tabpages = true,
			clickable = true,
			-- Add other barbar settings here
		})

		-- Recommended keymaps (can be moved to your keymaps file)
		local map = vim.keymap.set
		map("n", "<Tab>", "<Cmd>BufferNext<CR>", { desc = "Next buffer" })
		map("n", "<S-Tab>", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
		map("n", "<Leader>c", "<Cmd>BufferClose<CR>", { desc = "Close buffer" })
	end,
	event = "BufReadPre", -- Load when a buffer is read
}
