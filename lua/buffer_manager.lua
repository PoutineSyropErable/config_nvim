local function get_buffer_plugins(use_bufferline)
	local barbar = {
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function() vim.g.barbar_auto_setup = false end,
		opts = {
			animation = true,
			insert_at_end = true,
		},
	}

	local bufferline = { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" }

	-- Return both plugins
	if use_bufferline then
		return bufferline
	else
		return barbar
	end
end

return get_buffer_plugins
