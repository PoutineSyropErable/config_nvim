local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

-- =================================== TABOUT =========================

local ts_utils = require("nvim-treesitter.ts_utils")
local gu = require("_before.general_utils")

local function get_enclosing_pair_node()
	local node = ts_utils.get_node_at_cursor()
	local open_dict = {
		["("] = ")",
		["["] = "]",
		["{"] = "}",
		['"'] = '"',
		["'"] = "'",
		["`"] = "`",
	}
	local close_dict = {
		[")"] = "()",
		["]"] = "[",
		["}"] = "{",
		['"'] = '"',
		["'"] = "'",
		["`"] = "`",
	}

	local on_open = false
	local on_close = false
	local multi_char_node = false
	while node do
		local node_text = vim.treesitter.get_node_text(node, 0)

		-- First check: Is node exactly a single delimiter character?
		if node_text and #node_text == 1 then
			local matching_close = open_dict[node_text]
			if matching_close then
				on_open = true
				return node, on_close, on_open, multi_char_node
			end
			local matching_open = close_dict[node_text]
			if matching_open then
				on_close = true
				return node, on_close, on_open, multi_char_node
			end
		end

		-- Second check: Is node content wrapped in matching delimiters?
		if node_text and #node_text >= 2 then
			local first = node_text:sub(1, 1)
			local last = node_text:sub(-1)
			if open_dict[first] and open_dict[first] == last then
				multi_char_node = true
				return node, on_close, on_open, multi_char_node
			end
		end

		node = node:parent()
	end
	return nil
end

local function jump_out_forward()
	local node, on_close, on_open, multi_char_node = get_enclosing_pair_node()

	print(string.format(
		[[
    ⎯ Pair Debug ⎯
    Node: %s
    on_close: %s
    on_open: %s
    multi_char_node: %s
    ]],
		vim.inspect(node and vim.treesitter.get_node_text(node, 0)),
		vim.inspect(on_close),
		vim.inspect(on_open),
		vim.inspect(multi_char_node)
	))

	if not node then
		return
	end
	local node_text = vim.treesitter.get_node_text(node, 0)
	local end_row, end_col, wack, unknown = node:end_()
	vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
end

local function jump_out_backward()
	local node, on_close, on_open, multi_char_node = get_enclosing_pair_node()
	print(string.format(
		[[
    ⎯ Pair Debug ⎯
    Node: %s
    on_close: %s
    on_open: %s
    multi_char_node: %s
    ]],
		vim.inspect(node and vim.treesitter.get_node_text(node, 0)),
		vim.inspect(on_close),
		vim.inspect(on_open),
		vim.inspect(multi_char_node)
	))

	if not node then
		return
	end
	local start_row, start_col, wack, unknown = node:start()
	vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

-- Keybindings (Meta = Alt)
vim.keymap.set({ "i", "n" }, "<M-d>", jump_out_forward, { noremap = true, silent = true, desc = "Jump out of pair (forward)" })
vim.keymap.set({ "i", "n" }, "<M-a>", jump_out_backward, { noremap = true, silent = true, desc = "Jump back into pair" })
