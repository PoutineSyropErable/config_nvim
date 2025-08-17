vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local FIND_PRINT = false

if FIND_PRINT then
	local original_print = print
	print = function(...)
		original_print(...)
		original_print(debug.traceback()) -- This prints the stack trace
	end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- ~/.local/share/nvim .. / lazy/lazy.nvim
-- ~/.local/share/nvim/lazy/lazy.nvim
if not vim.loop.fs_stat(lazypath) then
	-- if lazy_path doesn't exist. git clone there
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

require("_before.pre_keymaps")
require("_before.pre_config")
require("_before.options")
require("core.lazy") -- lazy load here
require("core.lazy_keymaps")
require("core.write_function_macros")
-- require("z_after.something")
require("after.tabcd")

vim.api.nvim_set_hl(0, "LineNr", { fg = "#ef2f81" }) -- Change this to your desired color for relative line numbers
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#00ff00" }) -- Change this to your desired color for the current line number
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- for noice, must be false
vim.opt.lazyredraw = false
