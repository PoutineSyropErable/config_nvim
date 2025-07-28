M = {}
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

M.extension_to_filetype = {
	lua = "lua",
	py = "python",
	js = "javascript",
	sh = "bash",
	bash = "bash",
	rb = "ruby",
	c = "c",
	cpp = "cpp",
	go = "go",
	-- Add more extensions as needed
}

M.LSP_MSG = false
function M.print_attach(...)
	-- This function serves as a print message for on attach
	if not M.LSP_MSG then
		return
	end -- suppress if debug off

	local args = { ... }
	local parts = {}
	for i, v in ipairs(args) do
		parts[i] = tostring(v)
	end
	local msg = table.concat(parts, "\t")

	-- Use vim.notify to show as notification or just silent log
	vim.notify(msg, vim.log.levels.INFO)
end

-- Function to detect filetype based on extension or shebang
function M.detect_filetype(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local filetype = vim.bo[bufnr].filetype

	-- If filetype is already set, return early
	if filetype and filetype ~= "" then
		return filetype
	end

	-- Defensive: check if filename is valid and non-empty
	if not filename or filename == "" then
		return "text"
	end

	-- Get the file extension
	local ext = filename:match("^.+(%..+)$")
	if ext then
		ext = ext:sub(2):lower()
	else
		ext = ""
	end

	-- Check if file extension is in the dictionary
	if M.extension_to_filetype[ext] then
		return M.extension_to_filetype[ext]
	end

	-- If no match for extension, check for shebang (first line of file)
	local file = io.open(filename, "r")
	if file then
		local first_line = file:read("*line") -- Read the first line
		file:close()

		-- Check for common shebang patterns
		if first_line:match("^#!.*bash") then
			return "bash"
		elseif first_line:match("^#!.*python") then
			return "python"
		elseif first_line:match("^#!.*perl") then
			return "perl"
		elseif first_line:match("^#!.*ruby") then
			return "ruby"
		elseif first_line:match("^#!.*node") then
			return "javascript"
		end
	end

	-- If still no filetype found, return a default or an empty string
	return "text"
end

M.lsp_name_of_filetype = {
	bash = "bashls",
	sh = "bashls",
	zsh = "bashls",
	lua = "lua_ls",
	python = "pyright",
	c = "clangd",
	cpp = "clangd",
	objc = "clangd",
	objcpp = "clangd",
	rust = "rust_analyzer",
	java = "jdtls",
	tex = "texlab",
	latex = "texlab",
	bib = "texlab",
	asm = "asm_lsp",
	s = "asm_lsp",
	S = "asm_lsp",
}

--- @param name string The name of the LSP server (e.g., "pyright", "clangd").
function M.try_attach_lsp_to_buffer(name, bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	-- Check if the LSP client is already attached
	for _, client in ipairs(clients) do
		if client.name == name then
			M.print_attach("ℹ️ LSP " .. name .. " is already attached to buffer " .. bufnr)
			return true
		end
	end

	-- Try to find the initialized LSP and attach it
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == name then
			vim.lsp.buf_attach_client(bufnr, client.id)
			M.print_attach("✅ LSP " .. name .. " attached to buffer " .. bufnr)
			return true
		end
	end

	-- LSP is not initialized, start it
	M.print_attach("⚠️ LSP " .. name .. " not found to attach to buffer " .. bufnr)
	-- require("lspconfig")[name].setup({}) -- Start the LSP if not running
	return false
end

--- @param name string The name of the LSP server (e.g., "pyright", "clangd").
local function attach_lsp_to_buffer(name, bufnr)
	local max_try = 5
	local attempt = 1

	local function try_attach()
		local ret = M.try_attach_lsp_to_buffer(name, bufnr)
		if ret then
			return
		end

		M.print_attach("Couldn't attach LSP. Attempt #" .. attempt)

		-- Retry after 1 second if max tries are not reached
		if attempt < max_try then
			attempt = attempt + 1
			vim.defer_fn(try_attach, 1000) -- Retry after 1000 ms (1 second)
		else
			M.print_attach("Couldn't attach LSP " .. name .. " to buffer")
		end
	end

	-- Start the process
	try_attach()
end

--- Function to check active buffers and attach corresponding LSPs
local function attach_lsp_to_all_buffers()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local filetype = vim.bo[bufnr].filetype

		-- If the filetype is empty, trigger filetype detection
		if filetype == nil or filetype == "" then
			M.print_attach("Filetype is empty, detecting filetype for buffer: " .. vim.api.nvim_buf_get_name(bufnr))
			vim.cmd("filetype detect") -- Trigger filetype detection
			filetype = vim.bo[bufnr].filetype
		end
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

		if filetype == nil or filetype == "" then
			M.print_attach("Could not get filetype for " .. vim.inspect(bufnr) .. " with name " .. vim.inspect(filename))
			filetype = M.detect_filetype(bufnr)
		else
			M.print_attach("The filetype detect worked")
		end

		-- Check if there's a corresponding LSP for this filetype
		local lsp_name = M.lsp_name_of_filetype[filetype]
		if lsp_name then
			-- Try to attach the LSP to the buffer
			attach_lsp_to_buffer(lsp_name, bufnr)
		else
			M.print_attach(
				"No LSP for filetype " .. vim.inspect(filetype) .. " at bufnr: " .. vim.inspect(bufnr) .. " with filename: " .. vim.inspect(filename)
			)
		end
	end
end

M.add_keybinds = function(client, bufnr)
	local keymap = vim.keymap
	local gu = require("_before.general_utils")
	local hl = "core.plugins_lazy.helper.lsp_keybind"
	local tb = "telescope.builtin"

	local keybind_helper = require(hl)

	-- LSP Information
	keymap.set("n", "<leader>Lg", keybind_helper.safe_lsp_call("hover"), opts("Show LSP hover info"))
	keymap.set("n", "<leader>Ls", keybind_helper.safe_lsp_call("signature_help"), opts("Show function signature help"))

	-- Workspace Folder Management
	keymap.set("n", "<leader>LA", keybind_helper.safe_lsp_call("add_workspace_folder"), opts("Add workspace folder"))
	keymap.set("n", "<leader>LR", keybind_helper.safe_lsp_call("remove_workspace_folder"), opts("Remove workspace folder"))
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
	keymap.set("n", "gd", function() keybind_helper.safe_telescope_call("lsp_definitions") end, opts("Goto definition"))

	keymap.set("n", "gD", function() keybind_helper.safe_lsp_call("declaration")() end, opts("Goto declaration"))

	keymap.set("n", "gj", function()
		if vim.lsp.buf.definition then
			vim.lsp.buf.definition()
		else
			vim.notify("definition not supported by attached LSP", vim.log.levels.WARN)
		end
	end, opts("Go to definition (No telescope)"))

	keymap.set("n", "gI", function() keybind_helper.safe_telescope_call("lsp_implementations") end, opts("Find implementations"))

	keymap.set("n", "gr", function() require(hl).safe_telescope_call("lsp_references") end, opts("Find references"))

	keymap.set("n", "gh", keybind_helper.goto_current_function, opts("Go to current function"))
	keymap.set("n", "gn", keybind_helper.goto_next_function_call, opts("Go to next function call"))
	keymap.set("n", "gN", keybind_helper.goto_previous_function_call, opts("Go to previous function call"))

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

-- Define the command to attach all LSPs
vim.api.nvim_create_user_command("AttachAllLSPs", function() attach_lsp_to_all_buffers() end, { desc = "Attach all LSPs to active buffers" })

-- Keybinding to call the command
vim.keymap.set("n", "<leader>La", attach_lsp_to_all_buffers, opts("Attach all LSPs to active buffers"))

return M
