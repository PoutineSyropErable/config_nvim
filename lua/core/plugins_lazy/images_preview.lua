-- In your Neovim config somewhere (before plugins load)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
	callback = function() vim.bo.filetype = "image" end,
})

return {
	{
		"3rd/image.nvim",
		lazy = true,
		ft = { "markdown", "vimwiki", "image" }, -- load only for these filetypes
		opts = {

			backend = "kitty", -- or "ueberzug"
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					floating_windows = false,
					filetypes = { "markdown", "vimwiki" },
				},
			},
			max_width = nil,
			max_height = nil,
			max_width_window_percentage = 50,
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = false,
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
		},
	},
}
