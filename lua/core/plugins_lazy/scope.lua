return {
	"tiagovla/scope.nvim",
	lazy = true, -- or event = "VeryLazy", or remove to load eagerly
	config = function()
		-- no-op placeholder function
		local function nohup() end

		require("scope").setup({
			hooks = {
				pre_tab_leave = function() vim.api.nvim_exec_autocmds("User", { pattern = "ScopeTabLeavePre" }) end,
				post_tab_enter = function() vim.api.nvim_exec_autocmds("User", { pattern = "ScopeTabEnterPost" }) end,
				pre_tab_enter = nohup,
				pre_tab_close = nohup,
				post_tab_close = nohup,
			},
		})

		-- Function to move buffer to tab and focus it
		local function scope_move_and_focus(tab_index)
			local buf = vim.api.nvim_get_current_buf()

			-- Move buffer to target tab
			vim.cmd("ScopeMoveBuf " .. tab_index)

			-- Switch to that tab
			vim.cmd(tab_index .. "tabnext")

			-- Focus the buffer if visible in the tab
			local wins = vim.api.nvim_tabpage_list_wins(0)
			local focused = false
			for _, win in ipairs(wins) do
				if vim.api.nvim_win_get_buf(win) == buf then
					vim.api.nvim_set_current_win(win)
					focused = true
					break
				end
			end

			-- If not focused yet, open buffer manually
			if not focused then
				vim.cmd("buffer " .. buf)
			end
		end

		-- Mapping from tab number to shifted symbol for Hyprland style keys
		local number_to_shifted_symbol = {
			[1] = "!",
			[2] = '"',
			[3] = "#",
			[4] = "$",
			[5] = "%",
			[6] = "&",
			[7] = "'",
			[8] = "(",
			[9] = ")",
			[10] = ")",
		}

		-- Keymaps: <leader>s[1-9] to send buffer + switch to tab
		for i = 1, 9 do
			vim.keymap.set("n", "<leader>s" .. i, function() scope_move_and_focus(i) end, { desc = "Send + switch to tab " .. i })
		end

		-- Keymaps: <C-w> + shifted symbol for sending buffer + switch to tab (Hyprland style)
		for i, symbol in pairs(number_to_shifted_symbol) do
			vim.keymap.set("n", "<C-w>" .. symbol, function() scope_move_and_focus(i) end, { desc = "Send + switch to tab " .. i .. " (Hypr-style)" })
		end

		-- Keymaps: <C-w>[1-9] to just go to tab
		for i = 1, 9 do
			vim.keymap.set("n", "<C-w>" .. i, i .. "gt", { desc = "Go to tab " .. i })
		end
	end,
}
