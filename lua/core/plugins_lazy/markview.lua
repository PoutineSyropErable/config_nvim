return {
	{
		"OXY2DEV/markview.nvim",
		lazy = false, -- recommended to load immediately
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			-- Set global Vim variables for markview
			vim.g.mkdp_theme = "light"
			vim.g.mkdp_command_for_global = 1

			-- Setup autocmd for User event 'MarkviewAttach'
			vim.api.nvim_create_autocmd("User", {
				pattern = "MarkviewAttach",
				callback = function(event)
					local data = event.data
					vim.print(data)
				end,
			})
		end,
	},
}
