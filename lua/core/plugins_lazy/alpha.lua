return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	cond = function()
		-- Only load alpha if no files are opened (empty arg list)
		return vim.fn.argc() == 0
	end,
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Optional: Customize header here if you want
		-- dashboard.section.header.val = { ... }

		dashboard.section.buttons.val = {
			dashboard.button("r", " > 󰬙 Last Session (in Dir)", ":lua require('nvim-possession').list()<CR>"),
			dashboard.button("n", "  > New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("b", "  > Browse files", ":Oil --float<CR>"),
			dashboard.button("f", "󰈞  > Find file", ":Telescope find_files<CR>"),
			dashboard.button("R", "  > Recent", ":Telescope oldfiles<CR>"),
			dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
		}

		alpha.setup(dashboard.config)
	end,
}
