M = {}

local gu = require("_before.general_utils")
local keymap = vim.keymap

function M.safe_lsp_call(fn)
	return function()
		if vim.lsp.buf[fn] then
			vim.lsp.buf[fn]()
		else
			gu.print_custom("LSP function '" .. fn .. "' not available")
		end
	end
end

function M.safe_telescope_call(fn)
	local ok, telescope_builtin = pcall(require, "telescope.builtin")
	if ok and telescope_builtin[fn] then
		gu.print_custom(vim.inspect(telescope_builtin[fn]))

		telescope_builtin[fn]()
		return 0
	else
		gu.print_custom("Telescope function '" .. fn .. "' not available")
		return 1
	end
end

------ Custom weird Shit ---------

function M.goto_current_function()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }

	vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(_, result)
		if not result then
			gu.print_custom("No LSP symbols found.")
			return
		end

		local row = vim.api.nvim_win_get_cursor(0)[1] -- Get cursor line
		local function_node = nil

		-- Recursive search for the function under the cursor
		local function find_function(symbols)
			for _, symbol in ipairs(symbols) do
				local kind = symbol.kind
				local range = symbol.range

				-- Function or Method symbols
				if kind == 12 or kind == 6 then
					local start_line = range.start.line + 1
					local end_line = range["end"].line + 1

					-- Check if cursor is within function bounds
					if start_line <= row and row <= end_line then
						function_node = symbol
					end
				end

				-- Recursively check children (for nested functions)
				if symbol.children then
					find_function(symbol.children)
				end
			end
		end

		find_function(result)

		if function_node then
			local target_line = function_node.range.start.line + 1
			local target_col = function_node.range.start.character
			local line_content = vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1]

			-- **🔹 Debugging output**
			gu.print_custom("---- DEBUG INFO ----")
			gu.print_custom("🔹 Full Line:", line_content)
			gu.print_custom("🔹 LSP Start Character:", target_col)

			-- Attempt to extract function name from the line
			local function_name = string.match(line_content, "([_%w]+)%s*%(")

			if function_name then
				local col = string.find(line_content, function_name) - 1
				gu.print_custom("🔹 Detected Function Name:", function_name, "at column:", col)
				vim.api.nvim_win_set_cursor(0, { target_line, col })
			else
				gu.print_custom("❌ Function name not found using regex. Using fallback LSP position.")
				vim.api.nvim_win_set_cursor(0, { target_line, target_col })
			end
		else
			gu.print_custom("❌ No function found.")
		end
	end)
end

function M.get_function_calls()
	local ft = vim.bo.filetype

	if not ft or ft == "" then
		return {} -- No filetype detected, exit early
	end

	local ok, parser = pcall(vim.treesitter.get_parser, 0, ft)
	if not ok or not parser then
		return {} -- Parser not found or error occurred, exit early
	end

	local tree = parser:parse()[1]
	local root = tree:root()
	local calls = {}

	local function traverse(node)
		if node:type() == "call_expression" then
			local func_node = node:child(0) -- Function name
			if func_node then
				local func_name = vim.treesitter.get_node_text(func_node, 0)
				local line, col, _ = node:start()
				line = line + 1

				-- Store function call information
				table.insert(calls, { name = func_name, line = line, col = col })
			end
		end
		-- Recursively check children
		for child in node:iter_children() do
			traverse(child)
		end
	end

	traverse(root)

	-- 🔹 Debugging Output: Print All Found Calls
	-- gu.print_custom("📌 [DEBUG] Function Calls Found:")
	-- for _, call in ipairs(calls) do
	--  gu.print_custom("  🔹 " .. call.name .. " at line " .. call.line .. ", column " .. call.col)
	-- end

	return calls
end

function M.goto_next_function_call()
	local calls = M.get_function_calls()
	if #calls == 0 then
		gu.print_custom("❌ No function calls found in this file.")
		return nil
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Get cursor position
	local next_call = nil

	-- 🔹 Find the first function call that occurs after the cursor position
	for _, call in ipairs(calls) do
		if call.line > row or (call.line == row and call.col > col) then
			next_call = call
			break
		end
	end

	if next_call then
		gu.print_custom("🔹 Jumping to function call:", next_call.name, "at line", next_call.line, "column", next_call.col)
		vim.api.nvim_win_set_cursor(0, { next_call.line, next_call.col })
		return next_call
	else
		gu.print_custom("❌ No next function call found.")
	end
end

function M.goto_previous_function_call()
	local calls = M.get_function_calls()
	if #calls == 0 then
		gu.print_custom("❌ No function calls found in this file.")
		return nil
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Get cursor position
	local prev_call = nil

	-- 🔹 Find the last function call that occurs before the cursor position
	for i = #calls, 1, -1 do
		local call = calls[i]
		if call.line < row or (call.line == row and call.col < col) then
			prev_call = call
			break
		end
	end

	if prev_call then
		gu.print_custom("🔹 Jumping to function call:", prev_call.name, "at line", prev_call.line, "column", prev_call.col)
		vim.api.nvim_win_set_cursor(0, { prev_call.line, prev_call.col })
		return prev_call
	else
		gu.print_custom("❌ No previous function call found.")
	end
end

function M.select_and_write_function()
	local builtin = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	builtin.treesitter({
		default_text = ":function:",
		attach_mappings = function(_, map)
			local insert_function_call = function(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection and selection.value then
					local func_name_and_symbol_type = selection.ordinal or selection.display or "unknown"
					-- local func_name = selection.display
					local func_name = vim.split(func_name_and_symbol_type, "%s+")[1]
					gu.print_custom("the function name is: \n" .. vim.inspect(func_name))
					vim.api.nvim_put({ func_name .. "()" }, "", true, true)
				end
			end

			map("i", "<CR>", insert_function_call)
			map("n", "<CR>", insert_function_call)

			return true
		end,
	})
end

------- on attach ---------

return M
