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

	-- Get 0-based cursor position
	local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
	cursor_row = cursor_row - 1 -- Convert to 0-based row

	while node do
		local start_row, start_col, end_row, end_col = node:range()
		local node_text = vim.treesitter.get_node_text(node, 0) or ""

		-- Check if cursor is exactly on node boundaries
		local on_start = (cursor_row == start_row and cursor_col == start_col)
		local on_end = (cursor_row == end_row and cursor_col == end_col - 1) -- end_col is exclusive

		-- Handle single-character delimiters
		if on_start or on_end then
			local char = on_start and node_text:sub(1, 1) or node_text:sub(-1)
			if delimiters[char] then
				return {
					node = node,
					type = on_start and "opening" or "closing",
					char = char,
					counterpart = delimiters[char] or char, -- For quotes
					is_boundary = true,
				}
			end
		end

		-- Handle wrapped content (only if cursor isn't on boundaries)
		if not on_start and not on_end and #node_text >= 2 then
			local first = node_text:sub(1, 1)
			local last = node_text:sub(-1)
			if delimiters[first] and delimiters[first] == last then
				return {
					node = node,
					type = "wrapped",
					char = first,
					counterpart = last,
					is_boundary = false,
				}
			end
		end

		node = node:parent()
	end
	return nil
end

local function jump_out_forward()
	local pair = get_enclosing_pair_node()
	if not pair then
		return
	end

	-- For closing delimiters, jump to parent's end
	if pair.type == "closing" then
		local parent = pair.node:parent()
		if parent then
			local end_row, end_col = parent:end_()
			vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
			return
		end
	end

	-- Default jump to current node's end
	local end_row, end_col = pair.node:end_()
	vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
end

local function jump_out_backward()
	local pair = get_enclosing_pair_node()
	if not pair then
		return
	end

	-- For opening delimiters, jump to parent's start
	if pair.type == "opening" then
		local parent = pair.node:parent()
		if parent then
			local start_row, start_col = parent:start()
			vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
			return
		end
	end

	-- Default jump to current node's start
	local start_row, start_col = pair.node:start()
	vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

-- Keybindings (Meta = Alt)
vim.keymap.set({ "i", "n" }, "<M-d>", jump_out_forward, { noremap = true, silent = true, desc = "Jump out of pair (forward)" })
vim.keymap.set({ "i", "n" }, "<M-a>", jump_out_backward, { noremap = true, silent = true, desc = "Jump back into pair" })
