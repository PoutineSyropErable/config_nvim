local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

-- =================================== TABOUT =========================

local ts_utils = require("nvim-treesitter.ts_utils")
local gu = require("_before.general_utils")

local function print_node_info(node, cursor_row, cursor_col)
	if not node then
		print("No node at cursor position")
		return
	end

	-- Get cursor and node positions
	local start_row, start_col, end_row, end_col = node:range()
	local on_start = (cursor_row == start_row and cursor_col == start_col)
	local on_end = (cursor_row == end_row and cursor_col == end_col - 1)

	-- Get node text
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
	local node_text = table.concat(lines, "\\n")
	node_text = node_text:gsub("[\n\r]", "\\n") -- Show newlines as escaped characters

	-- Define all info in display order
	local info = {
		{ label = "Node Type", value = node:type() },
		{ label = "Node Range", value = string.format("%d:%d → %d:%d", start_row, start_col, end_row, end_col) },
		{ label = "Cursor Position", value = string.format("%d:%d", cursor_row, cursor_col) },
		{ label = "On Start?", value = on_start and "✅ YES" or "❌ NO" },
		{ label = "On End?", value = on_end and "✅ YES" or "❌ NO" },
		{ label = "Node Text", value = string.format("'%s'", node_text) },
	}

	-- Calculate padding for alignment
	local max_label_len = 0
	for _, item in ipairs(info) do
		max_label_len = math.max(max_label_len, #item.label)
	end

	-- Generate output
	local output = { "Node Information:" }
	for _, item in ipairs(info) do
		table.insert(output, string.format("  %-" .. (max_label_len + 1) .. "s %s", item.label .. ":", item.value))
	end

	print(table.concat(output, "\n"))
end

local function get_enclosing_pair_node()
	local node = ts_utils.get_node_at_cursor()
	local delimiters = {
		["("] = ")",
		["["] = "]",
		["{"] = "}",
		[")"] = "(",
		["]"] = "[",
		["}"] = "{",
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

		print_node_info(node, cursor_row, cursor_col)

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

	local function find_jump_target(node)
		local end_row, end_col = node:end_()
		local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
		cursor_row = cursor_row - 1 -- Convert to 0-based

		-- Check if cursor is already at this node's end
		if cursor_row == end_row and cursor_col == end_col - 1 then
			local parent = node:parent()
			if parent then
				return find_jump_target(parent) -- Recurse up the tree
			end
			return nil -- At top level with cursor at end
		end

		-- Return this node's end position if valid
		return { end_row + 1, end_col - 1 }
	end

	-- Find the appropriate jump target
	local target = find_jump_target(pair.node)
	if target then
		vim.api.nvim_win_set_cursor(0, target)
	end
end

local function jump_out_backward()
	local pair = get_enclosing_pair_node()
	if not pair then
		return
	end

	local function find_jump_target(node)
		local start_row, start_col = node:start()
		local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
		cursor_row = cursor_row - 1 -- Convert to 0-based

		-- Check if cursor is already at this node's start
		if cursor_row == start_row and cursor_col == start_col then
			local parent = node:parent()
			if parent then
				return find_jump_target(parent) -- Recurse up the tree
			end
			return nil -- At top level with cursor at start
		end

		-- Return this node's start position if valid
		return { start_row + 1, start_col }
	end

	-- Find the appropriate jump target
	local target = find_jump_target(pair.node)
	if target then
		vim.api.nvim_win_set_cursor(0, target)
	end
end

-- Keybindings (Meta = Alt)
vim.keymap.set({ "i", "n" }, "<M-d>", jump_out_forward, { noremap = true, silent = true, desc = "Jump out of pair (forward)" })
vim.keymap.set({ "i", "n" }, "<M-a>", jump_out_backward, { noremap = true, silent = true, desc = "Jump back into pair" })

local function get_child_nodes_around_cursor(node)
	if not node or node:named_child_count() == 0 then
		return nil
	end

	local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
	cursor_row = cursor_row - 1 -- Convert to 0-based

	local children = {}
	for i = 0, node:named_child_count() - 1 do
		local child = node:named_child(i)
		local _, _, end_row, end_col = child:range()
		table.insert(children, {
			node = child,
			index = i,
			is_after = (cursor_row < end_row) or (cursor_row == end_row and cursor_col < end_col),
		})
	end

	return children
end

local function jump_to_next_child()
	local pair = get_enclosing_pair_node()
	if not pair then
		return
	end

	local children = get_child_nodes_around_cursor(pair.node)
	if not children then
		return
	end

	-- Find first child after cursor
	for _, child in ipairs(children) do
		if child.is_after then
			local start_row, start_col = child.node:start()
			vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
			return
		end
	end
end

local function jump_to_prev_child()
	local pair = get_enclosing_pair_node()
	if not pair then
		return
	end

	local children = get_child_nodes_around_cursor(pair.node)
	if not children then
		print("no children")
		return
	end

	-- Find last child before cursor
	for i = #children, 1, -1 do
		if not children[i].is_after then
			local start_row, start_col = children[i].node:start()
			vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
			-- local end_row, end_col = children[i].node:end_()
			-- vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col - 1 })
			return
		end
	end
end

-- Update keybindings
vim.keymap.set({ "i", "n" }, "<M-d>", jump_out_forward, { noremap = true, silent = true, desc = "Jump out of pair (forward)" })
vim.keymap.set({ "i", "n" }, "<M-a>", jump_out_backward, { noremap = true, silent = true, desc = "Jump back into pair" })
vim.keymap.set({ "i", "n" }, "<M-w>", jump_to_next_child, { noremap = true, silent = true, desc = "Jump to next child node" })
vim.keymap.set({ "i", "n" }, "<M-s>", jump_to_prev_child, { noremap = true, silent = true, desc = "Jump to previous child node" })

-- once cousins works, then the movement tree must be added.
-- after that, i'll have some awesome insert mode navigation
