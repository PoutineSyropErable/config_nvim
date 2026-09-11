local M = {}
local function opts(desc) return { noremap = true, silent = true, desc = desc } end
local gu = function() return require("_before.general_utils") end
local pre_config = require("_before.pre_config")

M.extension_to_filetype = {
	lua = "lua",
	py = "python",
	js = "javascript",
	sh = "bash",
	bash = "bash",
	rb = "ruby",
	c = "c",
	ino = "c",
	h = "c",
	cpp = "cpp",
	hpp = "cpp",
	go = "go",
	-- Add more extensions as needed
}

M.LSP_MSG = false

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

		if first_line == nil then
			return "text"
		end

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

local lsp_of_c

if pre_config.clangdNotCCLS then
	lsp_of_c = "clangd"
else
	lsp_of_c = "ccls"
end

M.lsp_name_of_filetype = {
	bash = "bashls",
	sh = "bashls",
	zsh = "bashls",
	lua = "lua_ls",
	python = "pyright",
	c = lsp_of_c,
	cpp = lsp_of_c,
	objc = lsp_of_c,
	objcpp = lsp_of_c,
	rust = "rust_analyzer",
	java = "jdtls",
	tex = "texlab",
	latex = "texlab",
	bib = "texlab",
	asm = "asm_lsp",
	s = "asm_lsp",
	S = "asm_lsp",
}

local c_lsp_func = function()
	local clangd = pre_config.clangdNotCCLS

	if clangd then
		return require("lsp.c")
	else
		return require("lsp.ccls")
	end
end

-- Lazy mapping: filetype -> function that returns the LSP config
M.config_of_filetype = {
	lua = function() return require("lsps.lua") end,
	python = function() return require("lsps.python") end,
	bash = function() return require("lsps.bash") end,
	sh = function() return require("lsps.bash") end,
	zsh = function() return require("lsps.bash") end,
	opencl = function() return require("lsps.opencl") end,
	c = c_lsp_func,
	cpp = c_lsp_func,
	objc = c_lsp_func,
	objcpp = c_lsp_func,
	rust = function() return require("lsps.rust") end,
	java = function() return require("lsps.java") end,
	tex = function() return require("lsps.latex") end,
	latex = function() return require("lsps.latex") end,
	bib = function() return require("lsps.latex") end,
	asm = function() return require("lsps.asm") end,
	s = function() return require("lsps.asm") end,
	S = function() return require("lsps.asm") end,
}

-- Lazy loader: LSP server name -> function returning its config
M.config_of_lspname = {
	bashls = function() return require("lsps.bash") end,
	lua_ls = function() return require("lsps.lua") end,
	pyright = function() return require("lsps.python") end,
	clangd = function() return require("lsps.c") end,
	rust_analyzer = function() return require("lsps.rust") end,
	jdtls = function() return require("lsps.java") end,
	texlab = function() return require("lsps.latex") end,
	asm_lsp = function() return require("lsps.asm") end,
	opencl = function() return require("lsps.opencl") end,
}

--- @param name string The name of the LSP server (e.g., "pyright", "clangd").
function M.try_attach_lsp_to_buffer(name, bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	-- Check if the LSP client is already attached
	for _, client in ipairs(clients) do
		if client.name == name then
			gu().print_custom("ℹ️ LSP " .. name .. " is already attached to buffer " .. bufnr)
			return true
		end
	end

	-- Try to find the initialized LSP and attach it
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == name then
			vim.lsp.buf_attach_client(bufnr, client.id)
			gu().print_custom("✅ LSP " .. name .. " attached to buffer " .. bufnr)
			return true
		end
	end

	-- LSP is not initialized, start it
	gu().print_custom("⚠️ LSP " .. name .. " not found to attach to buffer " .. bufnr)

	local conf_fn = M.config_of_lspname[name]
	if conf_fn then
		require("lspconfig")[name].setup(conf_fn())
	else
		gu().print_custom("⚠️ No config function found for LSP " .. name)
	end
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

		gu().print_custom("Couldn't attach LSP. Attempt #" .. attempt)

		-- Retry after 1 second if max tries are not reached
		if attempt < max_try then
			attempt = attempt + 1
			vim.defer_fn(try_attach, 1000) -- Retry after 1000 ms (1 second)
		else
			gu().print_custom("Couldn't attach LSP " .. name .. " to buffer")
		end
	end

	-- Start the process
	try_attach()
end

--- Function to check active buffers and attach corresponding LSPs
M.attach_lsp_to_all_buffers = function()
	-- AttachAllLSPs function implementation
	gu().print_custom("Attaching all LSPs")
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		-- skip invalid / unloaded buffers early

		-- gu().print_custom("The buffer: " .. vim.inspect(bufnr))

		if not vim.api.nvim_buf_is_valid(bufnr) then
			goto continue
		end

		local filetype = vim.bo[bufnr].filetype

		-- If the filetype is empty, trigger filetype detection
		if filetype == nil or filetype == "" then
			gu().print_custom("Filetype is empty, detecting filetype for buffer: " .. vim.api.nvim_buf_get_name(bufnr))
			vim.cmd("filetype detect") -- Trigger filetype detection
			filetype = vim.bo[bufnr].filetype
		end
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

		if filetype == nil or filetype == "" then
			gu().print_custom("Could not get filetype for " .. vim.inspect(bufnr) .. " with name " .. vim.inspect(filename))
			filetype = M.detect_filetype(bufnr)
		else
			gu().print_custom("The filetype detect worked")
		end

		gu().print_custom("The filetype is: " .. vim.inspect(filetype))

		-- Check if there's a corresponding LSP for this filetype
		local lsp_name = M.lsp_name_of_filetype[filetype]
		if lsp_name then
			-- Try to attach the LSP to the buffer
			attach_lsp_to_buffer(lsp_name, bufnr)
		else
			gu().print_custom(
				"No LSP for filetype " .. vim.inspect(filetype) .. " at bufnr: " .. vim.inspect(bufnr) .. " with filename: " .. vim.inspect(filename)
			)
		end

		::continue::
	end
end

function lsp_hover()
	local params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
		if err or not result or not result.contents then
			return
		end

		-- Get raw content
		local content = result.contents
		local lines = {}

		if type(content) == "table" and content.value then
			lines = vim.split(content.value, "\n")
		elseif type(content) == "string" then
			lines = vim.split(content, "\n")
		else
			lines = vim.split(vim.inspect(content), "\n")
		end

		lines = vim.lsp.util.trim_empty_lines(lines)
		if vim.tbl_isempty(lines) then
			return
		end

		-- Detect filetype from current buffer
		local ft = vim.bo.filetype

		-- Calculate width
		local width = 0
		for _, line in ipairs(lines) do
			width = math.max(width, vim.fn.strdisplaywidth(line))
		end
		width = math.min(width + 4, 80)
		local height = math.min(#lines + 2, 25)

		-- Create buffer
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

		-- Set filetype to current buffer's language for syntax highlighting
		vim.api.nvim_buf_set_option(bufnr, "filetype", ft)

		-- Enable treesitter for this language
		pcall(vim.treesitter.start, bufnr, ft)

		-- Open window
		local win = vim.api.nvim_open_win(bufnr, false, {
			relative = "cursor",
			width = width,
			height = height,
			col = 1,
			row = 1,
			style = "minimal",
			border = "rounded",
			focusable = true, -- Make it focusable for interactions
		})

		-- Auto-close on cursor move, but allow interaction
		local close_timer
		vim.api.nvim_create_autocmd("CursorMoved", {
			callback = function()
				-- Don't close if cursor is in the hover window
				local current_win = vim.api.nvim_get_current_win()
				if current_win == win then
					return
				end
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end,
			once = false, -- Keep running
		})

		-- Close on escape
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = bufnr,
			callback = function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end,
			once = true,
		})
	end)
end

M.add_keybinds = function()
	local keymap = vim.keymap
	local hl = "core.plugins_lazy.helper.lsp_keybind"
	local tb = "telescope.builtin"

	local keybind_helper = require(hl)

	-- LSP Information
	keymap.set("n", "$", keybind_helper.safe_lsp_call("hover"), opts("Show LSP hover info"))
	-- keymap.set("n", "$", function() vim.lsp.buf.hover({ border = "rounded", max_height = 25, max_width = 120 }) end, opts("Hover documentation"))

	keymap.set("n", "<leader>Ls", keybind_helper.safe_lsp_call("signature_help"), opts("Show function signature help"))

	-- Workspace Folder Management
	keymap.set("n", "<leader>LA", keybind_helper.safe_lsp_call("add_workspace_folder"), opts("Add workspace folder"))
	keymap.set("n", "<leader>LR", keybind_helper.safe_lsp_call("remove_workspace_folder"), opts("Remove workspace folder"))
	keymap.set("n", "<leader>LL", function()
		if vim.lsp.buf.list_workspace_folders then
			gu().print_custom(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		else
			gu().print_custom("LSP function 'list_workspace_folders' not available")
		end
	end, opts("List workspace folders"))

	keymap.set(
		"n",
		"<leader>de",
		function() require(tb).diagnostics({ default_text = ":E:", bufnr = 0 }) end,
		opts("Show Errors and diagnostics (Telescope UI)")
	)
	keymap.set("n", "<leader>dE", function() require(tb).diagnostics({ default_text = ":E:" }) end, opts("Show Errors and diagnostics (Telescope UI)"))
	keymap.set(
		"n",
		"<leader>dw",
		function() require(tb).diagnostics({ default_text = ":W:", bufnr = 0 }) end,
		opts("Show Warning and diagnostics (Telescope UI)")
	)
	keymap.set(
		"n",
		"<leader>dW",
		function() require(tb).diagnostics({ default_text = ":W:" }) end,
		opts("Show Warning and diagnostics (Telescope UI)")
	)
	keymap.set("n", "<leader>dH", function() require(tb).diagnostics({ default_text = ":H:" }) end, opts("Show Hints and diagnostics (Telescope UI)"))

	-- Rename / Actions
	keymap.set("n", "<leader>Ll", function() require("lint").try_lint() end, opts("Manually trigger linting"))

	keymap.set("n", "<leader>Lr", vim.lsp.buf.rename, opts("Rename symbol"))
	keymap.set("n", "<leader>Lc", vim.lsp.buf.code_action, opts("Show code actions (buf lsp)"))

	-- Goto / navigation
	keymap.set("n", "gd", function() keybind_helper.safe_telescope_call("lsp_definitions") end, opts("Go to definition"))
	keymap.set("n", "gd", function() require(tb).lsp_definitions() end, opts("Go to definition"))

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
vim.api.nvim_create_user_command("AttachAllLSPs", function() M.attach_lsp_to_all_buffers() end, { desc = "Attach all LSPs to active buffers" })

-- Keybinding to call the command
vim.keymap.set("n", "<leader>La", M.attach_lsp_to_all_buffers, opts("Attach all LSPs to active buffers"))

return M
