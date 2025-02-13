local function disableSpell()
	-- disable spell checking for terminals
	vim.opt.spell = false
end

require("toggleterm").setup({
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	on_open = disableSpell(),
	on_create = disableSpell(),

	open_mapping = [[<C-t>]], -- Open terminal with Ctrl+\
	hide_numbers = true, -- Hide line numbers in terminal
	shade_terminals = false,
	shading_factor = 0, -- Darken terminal
	start_in_insert = true, -- Enter insert mode when terminal opens
	insert_mappings = true, -- Allow mappings in insert mode
	terminal_mappings = true, -- Allow mappings in terminal mode
	persist_size = true,
	direction = "float", -- Other options: "horizontal", "vertical", "tab"
	close_on_exit = true,
	shell = vim.o.shell, -- Use system shell
	float_opts = {
		border = "curved", -- Borders: single, double, shadow, curved
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})
