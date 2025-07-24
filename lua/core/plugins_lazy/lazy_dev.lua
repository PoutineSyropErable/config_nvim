return {
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load for Lua files
		opts = {
			library = {
				-- Load luvit types when `vim.uv` is detected
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
}
