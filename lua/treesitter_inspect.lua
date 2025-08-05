-- lua/treesitter_inspect.lua
local M = {}

local function get_current_node() return require("nvim-treesitter.ts_utils").get_node_at_cursor() end

-- Core inspection function (takes a node)
function M.inspect_node(node, indent, visited)
	indent = indent or 0
	visited = visited or {}

	if not node then
		return "nil"
	end
	if visited[node] then
		return "<cyclic node>"
	end
	visited[node] = true

	local spaces = string.rep("  ", indent)
	local result = { "TSNode: " .. node:type() .. " {\n" }

	local start_row, start_col, end_row, end_col = node:range()
	table.insert(result, string.format("%s  range = {%d, %d, %d, %d},\n", spaces, start_row, start_col, end_row, end_col))

	local child_count = node:named_child_count()
	if child_count > 0 then
		table.insert(result, spaces .. "  children = {\n")
		for i = 0, child_count - 1 do
			local child = node:named_child(i)
			table.insert(result, M.inspect_node(child, indent + 2, visited))
			table.insert(result, ",\n")
		end
		table.insert(result, spaces .. "  },\n")
	end

	table.insert(result, spaces .. "}")
	return table.concat(result)
end

-- Current node version
function M.print_current_node()
	local node = get_current_node()
	if not node then
		return print("No node at cursor")
	end
	print(M.inspect_node(node))
end

-- Node family inspection (takes node)
function M.inspect_node_family(node)
	if not node then
		return
	end

	local output = {}
	local parent = node:parent()

	-- Parent info
	if parent then
		local ptype = parent:type()
		local prow, pcol, perow, pecol = parent:range()
		table.insert(output, string.format("Parent:  [%s] %d:%d-%d:%d", ptype, prow + 1, pcol, perow + 1, pecol))
	end

	-- Current node
	local node_type = node:type()
	local srow, scol, erow, ecol = node:range()
	table.insert(output, string.format("Current: [%s] %d:%d-%d:%d", node_type, srow + 1, scol, erow + 1, ecol))

	-- Children
	for i = 0, node:named_child_count() - 1 do
		local child = node:named_child(i)
		local ctype = child:type()
		local cs, cc, ce, cec = child:range()
		table.insert(output, string.format("  ↳ Child %d: [%s] %d:%d-%d:%d", i + 1, ctype, cs + 1, cc, ce + 1, cec))
	end

	print(table.concat(output, "\n"))
end

-- Current node version
function M.print_node_family() M.inspect_node_family(get_current_node()) end

-- Depth-two inspection (takes node)
function M.inspect_depth_two(node)
	if not node then
		return
	end

	local output = {
		string.format("Current: [%s] %d:%d-%d:%d", node:type(), node:range()),
	}

	for i = 0, node:named_child_count() - 1 do
		local child = node:named_child(i)
		local ctype = child:type()
		local cs, cc, ce, cec = child:range()
		table.insert(output, string.format("  ↳ Child %d: [%s] %d:%d-%d:%d", i + 1, ctype, cs + 1, cc, ce + 1, cec))
	end

	print(table.concat(output, "\n"))
end

-- Current node version
function M.print_depth_two() M.inspect_depth_two(get_current_node()) end

return M
