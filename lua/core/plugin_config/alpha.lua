require("alpha").setup(require("alpha.themes.dashboard").config)

local dashboard = require("alpha.themes.dashboard")
local alpha = require("alpha")

-- dashboard.section.header.val = {
--
--
--                                                      
-- 				████ ██████           █████      ██
--               ███████████             █████ 
--               █████████ ███████████████████ ███   ███████████
--              █████████  ███    █████████████ █████ ██████████████
--             █████████ ██████████ █████████ █████ █████ ████ █████
--           ███████████ ███    ███ █████████ █████ █████ ████ █████
--          ██████  █████████████████████ ████ █████ █████ ████ ██████
--
-- }

dashboard.section.buttons.val = {
	dashboard.button("n", "  > New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("b", "  > Browse files", ":Oil --float<CR>"),
	dashboard.button("f", "󰈞  > Find file", ":Telescope find_files<CR>"),
	dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),

	dashboard.button("s", "󰰢  > SessionManager", ":SessionManager<CR>"),
	-- dashboard.button("l", "󰰢  > Last Session", ":SessionManager load_last_session<CR>"),
	-- dashboard.button("d", "󰰢   > Last Session (in Dir)", ":SessionManager load_current_dir_session<CR>"),
	-- dashboard.button("g", "󰰢 󰊢 > Last Session (Git)", ":SessionManager load_git_session<CR>"),

	-- dashboard.button("S", "  > Settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
	dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
}

alpha.setup(dashboard.opts)

require("alpha").setup(dashboard.config)
