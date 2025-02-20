require("nvim-highlight-colors").setup({
	render = "background", -- Choose 'background', 'foreground', or 'virtual'
	enable_hex = true,
	enable_rgb = true,
	enable_hsl = true,
	enable_hsl_without_function = true,
	enable_named_colors = true,
	enable_var_usage = true,
	enable_tailwind = false,

	--	Fix: Custom colors should follow proper label format
	custom_colors = {
		{ label = "%-%-theme%-primary%-color", color = "#FF5555" },
		{ label = "%-%-theme%-secondary%-color", color = "#50FA7B" },
	},
})
