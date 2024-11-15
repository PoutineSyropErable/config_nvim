require("nvim-treesitter.configs").setup({
	-- A list of parser names, or "all"
	ensure_installed = { "asm", "c", "lua", "rust", "ruby", "vim", "html", "python", "java" },

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
})

vim.cmd([[
  autocmd BufRead,BufNewFile *.dump set filetype=asm
]])
