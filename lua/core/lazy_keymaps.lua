local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

-- =================================== TABOUT =========================

local ts_utils = require("nvim-treesitter.ts_utils")
local gu = require("_before.general_utils")

local function get_enclosing_pair_node()
	local node = ts_utils.get_node_at_cursor()
	local delimiters = {
		["("] = ")",
		["["] = "]",
		["{"] = "}",
		['"'] = '"',
		["'"] = "'",
		["`"] = "`",
	}

	while node do
		local node_text = vim.treesitter.get_node_text(node, 0)

		-- First check: Is node exactly a single delimiter character?
		if node_text and #node_text == 1 then
			local matching_close = delimiters[node_text]
			if matching_close then
				return node, node_text, matching_close
			end
		end

		-- Second check: Is node content wrapped in matching delimiters?
		if node_text and #node_text >= 2 then
			local first = node_text:sub(1, 1)
			local last = node_text:sub(-1)
			if delimiters[first] and delimiters[first] == last then
				return node, first, last
			end
		end

		node = node:parent()
	end
	return nil
end

local function jump_out_forward()
	local node = get_enclosing_pair_node()
	print("node is : " .. vim.inspect(node))
	if not node then
		return
	end
	local node_text = vim.treesitter.get_node_text(node, 0)
	print("the text is: " .. vim.inspect(node_text))
	local end_row, end_col, wack, unknown = node:end_()

	print("the coord is: " .. vim.inspect(end_row) .. " " .. vim.inspect(end_col))
	vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
end

local function jump_out_backward()
	local node = get_enclosing_pair_node()
	print("node is : " .. vim.inspect(node))
	if not node then
		return
	end
	local node_text = vim.treesitter.get_node_text(node, 0)
	print("the text is: " .. vim.inspect(node_text))
	local start_row, start_col, wack, unknown = node:start()
	print("the coord is: " .. vim.inspect(start_row) .. " " .. vim.inspect(start_col) .. " " .. vim.inspect(wack))
	vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

-- Keybindings (Meta = Alt)
vim.keymap.set({ "i", "n" }, "<M-d>", jump_out_forward, { noremap = true, silent = true, desc = "Jump out of pair (forward)" })
vim.keymap.set({ "i", "n" }, "<M-a>", jump_out_backward, { noremap = true, silent = true, desc = "Jump back into pair" })
