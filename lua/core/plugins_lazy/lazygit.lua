return {
	"kdheepak/lazygit.nvim",
	cmd = "LazyGit",
	keys = {
		{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazygit" },
	},
	config = function() require("lazygit").setup({}) end,
}
