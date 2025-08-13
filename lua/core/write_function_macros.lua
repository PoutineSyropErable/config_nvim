------------------------------------------ SYMBOL SEARCH FUNCTION FOR MACROS ---------------

local keymap = vim.keymap
local function opts(desc) return { noremap = true, silent = true, desc = desc } end
local gu = require("_before.general_utils")

-- Function to fetch symbols (LSP + buffer fallback)

local function get_local_variables()
	local parser = vim.treesitter.get_parser(0, "c") -- Treesitter for C
	if not parser then
		return {}
	end
	local tree = parser:parse()[1]
	local root = tree:root()
	local locals = {}

	local function traverse(node)
		-- Look for function definitions
		if node:type() == "function_definition" then
			local function_name_node = node:child(1) -- Function name is usually the second child
			local function_name = function_name_node and vim.treesitter.get_node_text(function_name_node, 0) or "<unknown>"

			-- Find local variables inside function body
			local function_body = node:child(node:child_count() - 1) -- Usually last child is the function body

			if function_body and function_body:type() == "compound_statement" then
				for var_decl in function_body:iter_children() do
					if var_decl:type() == "declaration" then
						local var_name_node = var_decl:child(1) -- Variable name is usually second child
						if var_name_node and var_name_node:type() == "identifier" then
							local var_name = vim.treesitter.get_node_text(var_name_node, 0)
							table.insert(locals, { name = var_name, kind = "Local Variable", scope = function_name })
						end
					end
				end
			end
		end

		-- Recursively check all children
		for child in node:iter_children() do
			traverse(child)
		end
	end

	traverse(root)
	return locals
end

local function get_symbols()
	local symbols = {}

	-- 🔹 1. Fetch top-level and function-local symbols from LSP
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	local lsp_results = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
	if lsp_results then
		for _, server in pairs(lsp_results) do
			for _, item in pairs(server.result or {}) do
				-- Add top-level symbols
				table.insert(symbols, {
					name = item.name,
					kind = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown",
				})

				-- 🔹 If a symbol has children (e.g., function-local vars), add them
				if item.children then
					for _, child in pairs(item.children) do
						table.insert(symbols, {
							name = child.name,
							kind = vim.lsp.protocol.SymbolKind[child.kind] or "Local Variable",
						})
					end
				end
			end
		end
	end

	-- 🔹 2. Fetch Local Variables via Treesitter
	for _, local_var in ipairs(get_local_variables()) do
		table.insert(symbols, local_var)
	end

	-- 🔹 3. Try fetching workspace symbols (across imported files)
	local workspace_results = vim.lsp.buf_request_sync(0, "workspace/symbol", { query = "" }, 1000)
	if workspace_results then
		for _, server in pairs(workspace_results) do
			for _, item in pairs(server.result or {}) do
				table.insert(symbols, {
					name = item.name,
					kind = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown",
				})
			end
		end
	end

	-- 🔹 4. Fallback: Extract words from buffer if no LSP symbols
	if #symbols == 0 then
		local word_set = {}
		for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
			for word in line:gmatch("[A-Za-z_][A-Za-z0-9_]*") do
				if not word_set[word] then
					table.insert(symbols, { name = word, kind = "Buffer Word" })
					word_set[word] = true
				end
			end
		end
	end

	return symbols
end

-- Function to show symbols in Telescope and call `callback` with the selected symbol
local function select_symbol(callback)
	local symbols = get_symbols()

	if #symbols == 0 then
		gu.print_custom("No symbols found!")
		return
	end

	pickers
		.new({}, {
			prompt_title = "Select Symbol",
			finder = finders.new_table({
				results = symbols,
				entry_maker = function(entry)
					return {
						value = entry.name,
						display = entry.name .. " (" .. entry.kind .. ")",
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(_, map)
				map("i", "<CR>", function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and callback then
						callback(selection.value) -- Call the callback function with selected value
					end
				end)
				return true
			end,
		})
		:find()
end

local function get_variable_name(callback)
	select_symbol(callback) -- Calls select_symbol and passes `callback`
end

--------------------------------- WRITE FUNCTIONS MACRO --------------------------------------

gu.debug_utils = {}

local function get_indent()
	local indent_level = vim.fn.indent(".") -- Get indentation level in spaces
	local tab_width = vim.o.shiftwidth > 0 and vim.o.shiftwidth or vim.o.tabstop

	if vim.o.expandtab then
		return string.rep(" ", indent_level) -- Use spaces if expandtab is set
	else
		local num_tabs = math.floor(indent_level / tab_width)
		local num_spaces = indent_level % tab_width
		return string.rep("\t", num_tabs) .. string.rep(" ", num_spaces) -- Use actual tabs if expandtab is off
	end
end

-- Simple write function to print variable name and value.
function gu.debug_utils.write_function_simple()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local print_statement = string.format("%sprint(f'%s = {%s}')", indent, input, input)
			vim.api.nvim_put({ print_statement }, "l", true, true)
		end
	end)
end

-- Write function for NumPy variables to print shape and value.
function gu.debug_utils.write_function_numpy()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sprint(f'np.shape(%s) = {np.shape(%s)}')
%sprint(f'%s = \n{%s}\n')]],
				indent,
				input,
				input,
				indent,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

-- Function to write debug prints for max, mean, std dev of a variable
function gu.debug_utils.write_function_stats()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sprint(f"max(%s) = {np.max(%s)}, mean(%s) = {np.mean(%s)}, std(%s) = {np.std(%s)}")]],
				indent,
				input,
				input,
				input,
				input,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

-- Write function for NumPy variables to print shape and value (new line version).
function gu.debug_utils.write_function_np_newline()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sprint(f'np.shape(%s) = {np.shape(%s)}')
%sprint(f'%s = \n{%s}\n')]],
				indent,
				input,
				input,
				indent,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

function gu.debug_utils.write_function_newline()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local print_statement = string.format("%sprint(f'%s = \\n{%s}\\n')", indent, input, input)
			vim.api.nvim_put({ print_statement }, "l", true, true)
		end
	end)
end

-- Enhanced debug function for more robust NumPy variable checks.
function gu.debug_utils.write_function_debug()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sif DEBUG_:
%s print(f'type(%s) = {type(%s)}')
%s	try:
%s	 print(f'np.shape(%s) = {np.shape(%s)}')
%s	except Exception as e:
%s	 print('Some error about not having a shape:', e)
%s 	 print(f'%s = \n{%s}\n')]],
				indent,
				indent,
				input,
				input,
				indent,
				indent,
				input,
				input,
				indent,
				indent,
				indent,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

-- Function to show symbols in Telescope and jump to the selected one
local function select_symbol_and_jump()
	local symbols = get_symbols()

	if #symbols == 0 then
		gu.print_custom("❌ No symbols found!")
		return
	end

	pickers
		.new({}, {
			prompt_title = "Select Symbol",
			finder = finders.new_table({
				results = symbols,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name .. " (" .. entry.kind .. ")",
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(_, map)
				map("i", "<CR>", function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and selection.value then
						vim.cmd("normal! gg") -- Move to top before searching
						vim.fn.search("\\<" .. selection.value.name .. "\\>", "w") -- Search for symbol
					end
				end)
				return true
			end,
		})
		:find()
end

select_and_write_function = function()
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

---- Bind the functions to keymaps -----
keymap.set("n", "<leader>wfs", gu.debug_utils.write_function_simple, opts("Write Function Simple"))
keymap.set("n", "<leader>wfn", gu.debug_utils.write_function_numpy, opts("Write Function Numpy"))
keymap.set("n", "<leader>wfN", gu.debug_utils.write_function_np_newline, opts("Write Function Numpy NewLine"))
keymap.set("n", "<leader>wfl", gu.debug_utils.write_function_newline, opts("Write Function NewLine"))
keymap.set("n", "<leader>wfd", gu.debug_utils.write_function_debug, opts("Write Function Debug"))
keymap.set("n", "<leader>wfS", gu.debug_utils.write_function_stats, opts("Write Function Stats"))
