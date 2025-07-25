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
function M.add_keybinds(client, bufnr)
	local opts = function(desc) return { noremap = true, silent = true, desc = desc, buffer = bufnr } end
	local hl = "core.plugins_lazy.helper.lsp"
	local tb = "telescope.builtin"

	-- LSP Information
	keymap.set("n", "<leader>Lg", M.safe_lsp_call("hover"), opts("Show LSP hover info"))
	keymap.set("n", "<leader>Ls", M.safe_lsp_call("signature_help"), opts("Show function signature help"))

	-- Workspace Folder Management
	keymap.set("n", "<leader>LA", M.safe_lsp_call("add_workspace_folder"), opts("Add workspace folder"))
	keymap.set("n", "<leader>LR", M.safe_lsp_call("remove_workspace_folder"), opts("Remove workspace folder"))
	keymap.set("n", "<leader>LL", function()
		if vim.lsp.buf.list_workspace_folders then
			gu.print_custom(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		else
			gu.print_custom("LSP function 'list_workspace_folders' not available")
		end
	end, opts("List workspace folders"))

	keymap.set("n", "<leader>de", function() require(tb).diagnostics({ default_text = ":E:" }) end, opts("Show Errors and diagnostics (Telescope UI)"))
	keymap.set(
		"n",
		"<leader>dw",
		function() require(tb).diagnostics({ default_text = ":W:" }) end,
		opts("Show Warning and diagnostics (Telescope UI)")
	)
	keymap.set("n", "<leader>dH", function() require(tb).diagnostics({ default_text = ":H:" }) end, opts("Show Hints and diagnostics (Telescope UI)"))

	-- Rename / Actions
	keymap.set("n", "<leader>Ll", function() require("lint").try_lint() end, opts("Manually trigger linting"))

	keymap.set("n", "<leader>Lr", vim.lsp.buf.rename, opts("Rename symbol"))
	keymap.set("n", "<leader>Lc", vim.lsp.buf.code_action, opts("Show code actions"))

	-- Goto / navigation
	keymap.set("n", "gd", function() require(hl).safe_telescope_call("lsp_definitions") end, opts("Goto definition"))

	keymap.set("n", "gD", function() require(hl).safe_lsp_call("declaration")() end, opts("Goto declaration"))

	keymap.set("n", "gj", function()
		if vim.lsp.buf.definition then
			vim.lsp.buf.definition()
		else
			vim.notify("definition not supported by attached LSP", vim.log.levels.WARN)
		end
	end, opts("Go to definition (No telescope)"))

	keymap.set("n", "gI", function() require(hl).safe_telescope_call("lsp_implementations") end, opts("Find implementations"))

	keymap.set("n", "gr", function() require(hl).safe_telescope_call("lsp_references") end, opts("Find references"))

	keymap.set("n", "gh", M.goto_current_function, opts("Go to current function"))
	keymap.set("n", "gn", M.goto_next_function_call, opts("Go to next function call"))
	keymap.set("n", "gN", M.goto_previous_function_call, opts("Go to previous function call"))

	keymap.set("n", "gi", function() require(hl).safe_telescope_call("lsp_incoming_calls") end, opts("Incoming calls (Telescope)"))

	keymap.set("n", "go", function() require(hl).safe_telescope_call("lsp_outgoing_calls") end, opts("Outgoing calls (Telescope)"))

	keymap.set("n", "ge", function()
		if vim.lsp.buf.incoming_calls then
			vim.lsp.buf.incoming_calls()
		else
			vim.notify("incoming_calls not supported by attached LSP", vim.log.levels.WARN)
		end
	end, opts("Incoming calls (LSP buffer)"))

	keymap.set("n", "gy", function()
		if vim.lsp.buf.outgoing_calls then
			vim.lsp.buf.outgoing_calls()
		else
			vim.notify("outgoing_calls not supported by attached LSP", vim.log.levels.WARN)
		end
	end, opts("Outgoing calls (LSP buffer)"))

	keymap.set(
		"n",
		"gl",
		function()
			vim.diagnostic.open_float({
				border = "rounded",
				max_width = 120,
				header = "Diagnostics:",
				focusable = true,
			})
		end
	)

	--- end of function
end

return M
