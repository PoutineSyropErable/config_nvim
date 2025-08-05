local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

-- =================================== TABOUT =========================

local ts_utils = require("nvim-treesitter.ts_utils")
local gu = require("_before.general_utils")

local function inspect_node(node, indent, visited)
	indent = indent or 0
	visited = visited or {}

	-- Handle nil/cyclic cases
	if not node then
		return "nil"
	end
	if visited[node] then
		return "<cyclic node>"
	end
	visited[node] = true

	local spaces = string.rep("  ", indent)
	local result = { "TSNode: " .. node:type() .. " {\n" }

	-- Add node range info
	local start_row, start_col, end_row, end_col = node:range()
	table.insert(result, string.format("%s  range = {%d, %d, %d, %d},\n", spaces, start_row, start_col, end_row, end_col))

	-- Inspect children
	local child_count = node:named_child_count()
	if child_count > 0 then
		table.insert(result, spaces .. "  children = {\n")
		for i = 0, child_count - 1 do
			local child = node:named_child(i)
			table.insert(result, inspect_node(child, indent + 2, visited))
			table.insert(result, ",\n")
		end
		table.insert(result, spaces .. "  },\n")
	end

	table.insert(result, spaces .. "}")
	return table.concat(result)
end

local function print_current_node()
	local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
	if not node then
		print("No node at cursor")
		return
	end

	local node_type = node:type()
	local start_row, start_col, end_row, end_col = node:range()

	print(string.format("Node: %s | Range: line %d, col %d-%d", node_type, start_row + 1, start_col, end_col))
end

vim.keymap.set("n", "<leader>pn", print_current_node)

local function inspect_node_fam(node)
	if not node then
		return print("No node at cursor")
	end

	local output = {}

	-- Parent (if exists)
	local parent = node:parent()
	if parent then
		local ptype = parent:type()
		local prow, pcol, perow, pecol = parent:range()
		table.insert(output, string.format("Parent:  [%s] %d:%d-%d:%d", ptype, prow + 1, pcol, perow + 1, pecol))
	end

	-- Current node
	local node_type = node:type()
	local srow, scol, erow, ecol = node:range()
	table.insert(output, string.format("Current: [%s] %d:%d-%d:%d", node_type, srow + 1, scol, erow + 1, ecol))

	-- Children (depth=1)
	for i = 0, node:named_child_count() - 1 do
		local child = node:named_child(i)
		local ctype = child:type()
		local cs, cc, ce, cec = child:range()
		table.insert(output, string.format("  ↳ Child %d: [%s] %d:%d-%d:%d", i + 1, ctype, cs + 1, cc, ce + 1, cec))
	end

	print(table.concat(output, "\n"))
end

local function inspect_node_family()
	local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
	inspect_node_fam(node)
end

-- Bind to <leader>if (i = inspect, f = family)
vim.keymap.set("n", "<leader>if", inspect_node_family, { desc = "Inspect node family (parent+children)" })

local function inspect_node_depth_two()
	local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
	if not node then
		return print("No node at cursor")
	end

	-- Current node info
	local node_type = node:type()
	local srow, scol, erow, ecol = node:range()
	local output = {
		string.format("Current: [%s] %d:%d-%d:%d", node_type, srow + 1, scol, erow + 1, ecol),
	}

	-- Immediate children (depth=1)
	for i = 0, node:named_child_count() - 1 do
		local child = node:named_child(i)
		local ctype = child:type()
		local cs, cc, ce, cec = child:range()
		table.insert(output, string.format("  ↳ Child %d: [%s] %d:%d-%d:%d", i + 1, ctype, cs + 1, cc, ce + 1, cec))
	end

	print(table.concat(output, "\n"))
end

-- Bind to <leader>i2
vim.keymap.set("n", "<leader>i2", inspect_node_depth_two, { desc = "Inspect node + children" })

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
	vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
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
