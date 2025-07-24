local uname = vim.loop.os_uname()
local is_windows = uname.sysname == "Windows_NT"

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

if is_windows then
	-- Windows: hardcoded keymaps without plugin
	keymap("", "<C-s>j", ":wincmd h<CR>", opts)
	keymap("", "<C-s>k", ":wincmd j<CR>", opts)
	keymap("", "<C-s>i", ":wincmd k<CR>", opts)
	keymap("", "<C-s>l", ":wincmd l<CR>", opts)
	keymap("", "<C-s>,", ":wincmd p<CR>", opts)
	keymap("", "<C-s>Space", ":wincmd w<CR>", opts)

	keymap("", "<C-s><Left>", ":wincmd h<CR>", opts)
	keymap("", "<C-s><Down>", ":wincmd j<CR>", opts)
	keymap("", "<C-s><Up>", ":wincmd k<CR>", opts)
	keymap("", "<C-s><Right>", ":wincmd l<CR>", opts)

	keymap("", "<C-w>j", ":wincmd h<CR>", opts)
	keymap("", "<C-w>k", ":wincmd j<CR>", opts)
	keymap("", "<C-w>i", ":wincmd k<CR>", opts)
	keymap("", "<C-w>l", ":wincmd l<CR>", opts)

	keymap("", "<C-w><Left>", ":wincmd h<CR>", opts)
	keymap("", "<C-w><Down>", ":wincmd j<CR>", opts)
	keymap("", "<C-w><Up>", ":wincmd k<CR>", opts)
	keymap("", "<C-w><Right>", ":wincmd l<CR>", opts)
else
	-- Linux: use lazy-loaded plugin with keys to lazy load it
	return {
		{
			"alexghergh/nvim-tmux-navigation",
			lazy = true,
			keys = {
				"<C-s>j",
				"<C-s>k",
				"<C-s>i",
				"<C-s>l",
				"<C-s>,",
				"<C-s><Space>",
				"<C-s><Left>",
				"<C-s><Down>",
				"<C-s><Up>",
				"<C-s><Right>",
				"<C-w>j",
				"<C-w>k",
				"<C-w>i",
				"<C-w>l",
				"<C-w><Left>",
				"<C-w><Down>",
				"<C-w><Up>",
				"<C-w><Right>",
			},
			config = function()
				local nav = require("nvim-tmux-navigation")

				keymap("", "<C-s>j", nav.NvimTmuxNavigateLeft, opts)
				keymap("", "<C-s>k", nav.NvimTmuxNavigateDown, opts)
				keymap("", "<C-s>i", nav.NvimTmuxNavigateUp, opts)
				keymap("", "<C-s>l", nav.NvimTmuxNavigateRight, opts)
				keymap("", "<C-s>,", nav.NvimTmuxNavigateLastActive, opts)
				keymap("", "<C-s><Space>", nav.NvimTmuxNavigateNext, opts)

				keymap("", "<C-s><Left>", nav.NvimTmuxNavigateLeft, opts)
				keymap("", "<C-s><Down>", nav.NvimTmuxNavigateDown, opts)
				keymap("", "<C-s><Up>", nav.NvimTmuxNavigateUp, opts)
				keymap("", "<C-s><Right>", nav.NvimTmuxNavigateRight, opts)

				keymap("", "<C-w>j", nav.NvimTmuxNavigateLeft, opts)
				keymap("", "<C-w>k", nav.NvimTmuxNavigateDown, opts)
				keymap("", "<C-w>i", nav.NvimTmuxNavigateUp, opts)
				keymap("", "<C-w>l", nav.NvimTmuxNavigateRight, opts)

				keymap("", "<C-w><Left>", nav.NvimTmuxNavigateLeft, opts)
				keymap("", "<C-w><Down>", nav.NvimTmuxNavigateDown, opts)
				keymap("", "<C-w><Up>", nav.NvimTmuxNavigateUp, opts)
				keymap("", "<C-w><Right>", nav.NvimTmuxNavigateRight, opts)
			end,
		},
	}
end
