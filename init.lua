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

require("core.options")
require("core.pre_config") -- The config before the plugins loading
require("core.plugins")
require("core.plugin_config")
require("core.spellcheck")
require("core.keymaps")

vim.api.nvim_set_hl(0, "LineNr", { fg = "#ef2f81" }) -- Change this to your desired color for relative line numbers
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#00ff00" }) -- Change this to your desired color for the current line number
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
vim.opt.lazyredraw = true
