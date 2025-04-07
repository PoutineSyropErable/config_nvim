vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("pre_keymaps")
require("pre_config") -- The config before the plugins loading
require("core.options")
require("core.plugins")
print("got here")
require("core.plugin_config")
require("core.spellcheck")
require("core.keymaps")
require("pre_keymaps") -- need a repeat in case plugins default cahnged it
-- require("core.plugin_config.noice")

vim.api.nvim_set_hl(0, "LineNr", { fg = "#ef2f81" }) -- Change this to your desired color for relative line numbers
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#00ff00" }) -- Change this to your desired color for the current line number
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
vim.opt.lazyredraw = true
