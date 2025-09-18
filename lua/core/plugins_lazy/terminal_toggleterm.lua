local function disableSpell()
	-- disable spell checking for terminals
	vim.opt.spell = false
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = { "ToggleTerm", "TermExec", "TermNew" }, -- lazy load on these commands
	-- toggle terminals with directions
	keys = {
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle Floating Terminal" },
		{ "<C-t>", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle Floating Terminal" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle Horizontal Terminal" },
		{ "<leader>th", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Toggle Vertical Terminal" },
		{ "<leader>tu", function() end, desc = "Float Terminal Top Left" }, -- placeholders for lazy loading
		{ "<leader>to", function() end, desc = "Float Terminal Top Right" },
		{ "<leader>tj", function() end, desc = "Float Terminal Bottom Left" },
		{ "<leader>tl", function() end, desc = "Float Terminal Bottom Right" },
		{ "<leader>tb", function() end, desc = "Float Terminal Bottom Right" },
		{ "<leader>tn", function() end, desc = "Float Terminal Bottom Right" },
	},
	config = function()
		local Terminal = require("toggleterm.terminal").Terminal
		local keymap = vim.keymap
		local opts = function(desc) return { noremap = true, silent = true, desc = desc } end

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

		local float_term = Terminal:new({
			direction = "float",
			hidden = true,
			float_opts = {
				border = "rounded",
				width = math.floor(vim.o.columns * 0.45),
				height = math.floor(vim.o.lines * 0.45),
				row = 0,
				col = 0,
			},
		})

		local function reposition_terminal(term, opts)
			term.float_opts = vim.tbl_deep_extend("force", term.float_opts or {}, opts)
			if term:is_open() then
				term:close()
				vim.defer_fn(function() term:open() end, 10)
			else
				term:open()
			end
		end

		local function move_float_terminal(position)
			local cols = vim.o.columns
			local lines = vim.o.lines

			local positions = {
				topleft = { row = 0, col = 0 },
				topright = { row = 0, col = math.floor(cols * 0.55) },
				bottomleft = { row = math.floor(lines * 0.55), col = 0 },
				bottomright = { row = math.floor(lines * 0.55), col = math.floor(cols * 0.55) },
			}

			local pos = positions[position]
			if not pos then
				vim.notify("Invalid terminal position: " .. position, vim.log.levels.ERROR)
				return
			end

			reposition_terminal(float_term, {
				width = math.floor(cols * 0.45),
				height = math.floor(lines * 0.45),
				border = "rounded",
				row = pos.row,
				col = pos.col,
			})
		end

		-- Keymaps for toggling terminals
		keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", opts("Floating Terminal"))
		keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=horizontal<CR>", opts("Horizontal Terminal"))
		keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=vertical<CR>", opts("Vertical Terminal"))

		-- Keymaps for repositioning floating terminal
		keymap.set("n", "<leader>tu", function() move_float_terminal("topleft") end, opts("Float Terminal Top Left"))
		keymap.set("n", "<leader>to", function() move_float_terminal("topright") end, opts("Float Terminal Top Right"))
		keymap.set("n", "<leader>tj", function() move_float_terminal("bottomleft") end, opts("Float Terminal Bottom Left"))
		keymap.set("n", "<leader>tl", function() move_float_terminal("bottomright") end, opts("Float Terminal Bottom Right"))
		keymap.set("n", "<leader>tb", function() move_float_terminal("bottomright") end, opts("Float Terminal Bottom Right"))
		keymap.set("n", "<leader>tn", function() move_float_terminal("bottomright") end, opts("Float Terminal Bottom Right"))

		-- Terminal mode keymap: jk to exit terminal mode
		keymap.set("t", "jk", "<C-\\><C-n>", opts("Terminal: jk to normal mode"))
	end,
}
