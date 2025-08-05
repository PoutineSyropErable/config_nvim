return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			flavour = "mocha",
			transparent_background = true,
			styles = {
				comments = { "italic" },
			},
			-- New float window controls (added in recent updates)
			float = {
				transparent = true, -- Force transparent floats
				solid = true, -- Disable solid borders
			},
			integrations = {
				telescope = {
					enabled = true,
					style = "nvchad", -- More transparent style
				},
				-- which_key = true,
			},
			custom_highlights = function(colors)
				return {
					-- Force transparency in all float elements
					NormalFloat = { bg = "NONE" },
					FloatBorder = { bg = "NONE", fg = colors.blue },
					TelescopeNormal = { bg = "NONE" },
					TelescopeBorder = { bg = "NONE", fg = colors.blue },
					WhichKeyFloat = { bg = "NONE" },
					LazyNormal = { bg = "NONE" }, -- For Lazy.nvim
				}
			end,
		})

		vim.o.termguicolors = true
		-- vim.o.background = "dark"
		vim.cmd.colorscheme("catppuccin")

		local extra = false
		if extra then
			-- Additional fixes for specific plugins
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "catppuccin",
				callback = function()
					vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
					vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE", fg = "#89b4fa" })
				end,
			})
		end
	end,
}
