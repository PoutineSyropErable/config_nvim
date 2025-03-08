vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.backspace = "2"
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.wrap = false

-- use spaces for tabs and whatnot
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = false
vim.o.autoindent = true -- Maintain indentation from the previous line
vim.o.smartindent = true -- More intelligent auto-indentation

vim.opt.mousemoveevent = true -- activate mouse

vim.cmd([[ set noswapfile ]])
vim.cmd([[ set termguicolors ]])
--vim.opt.clipboard = 'unnamedplus'
--Line numbers
vim.wo.number = true
vim.opt.number = true
vim.opt.relativenumber = true
-- vim.api.nvim_set_hl(0, "LineNr", { fg = "black" }) -- Change this to your desired color for relative line numbers
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#00ff00" }) -- Change this to your desired color for the current line number

--if you are on a comment and press enter, don't start on another comment
vim.api.nvim_set_var("commentstring", "")
-- Stop automatically adding comments
vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

-- Make searches case insensitive
vim.o.ignorecase = true

-- Override ignorecase if search pattern contains uppercase letters
vim.o.smartcase = true

-- Show special characters
vim.opt.list = false
vim.opt.listchars = {
	tab = ">-",
	trail = "·",
	space = "·",
	eol = "¬",
	precedes = "«",
	extends = "»",
}

--vim.opt.clipboard = 'unnamedplus'

-- Remove `c` and `r` from formatoptions to exclude comments
--vim.o.formatoptions = vim.o.formatoptions:gsub('c', ''):gsub('r', '')

-- Change color of breakpoints
vim.fn.sign_define("DapBreakpoint", {
	text = "🛑", -- This can be any symbol or text for the breakpoint
	texthl = "DapBreakpointHighlight", -- Custom highlight group for breakpoint color
	linehl = "", -- Optional: highlight the line (use with care)
	numhl = "", -- Optional: highlight the line number
})

-- Define the custom highlight group for the breakpoint color
vim.cmd([[
  highlight DapBreakpointHighlight guifg=#0000FF guibg=NONE ctermfg=blue ctermbg=NONE
]])

-- vim.opt.wildmenu = true
-- vim.opt.wildmode = { "list", "longest", "full" } -- Ensure proper completion

vim.g.python3_host_prog = "/home/francois/MainPython_Virtual_Environment/pip_venv/bin/python"

vim.opt.sessionoptions = { -- required
	"buffers",
	"tabpages",
	"globals",
}
-- let g:gitgutter_enabled = 0

vim.cmd("set verbosefile=$HOME/.config/nvim_logs/nvim_log.lua")
-- vim.cmd('set verbose=10')
