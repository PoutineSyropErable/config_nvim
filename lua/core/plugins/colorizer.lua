if true then
	return {}
end

-- does the same thing as nvim-highlight but is more lightweight

return {
	"NvChad/nvim-colorizer.lua",
	opts = {
		filetypes = {
			"*", -- Apply to all filetypes
			css = { rgb_fn = true }, -- Enable `rgb(...)` parsing
			html = { names = false }, -- Disable named colors like "Blue"
			["!vim"] = true, -- Exclude Vim files
		},
		user_default_options = {
			mode = "foreground", -- Global default
		},
	},
}
