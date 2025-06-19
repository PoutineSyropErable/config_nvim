local lspconfig = require("lspconfig")
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

local extension_to_filetype = {
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

-- Function to detect filetype based on extension or shebang
local function detect_filetype(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

	-- If filetype is already set, return early
	if filetype and filetype ~= "" then
		return filetype
	end

	-- Get the file extension
	local ext = filename:match("^.+(%..+)$"):sub(2):lower() -- Get the extension and convert to lowercase

	-- Check if file extension is in the dictionary
	if extension_to_filetype[ext] then
		return extension_to_filetype[ext]
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

local lsp_name_of_filetype = {
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
local function try_attach_lsp_to_buffer(name, bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	-- Check if the LSP client is already attached
	for _, client in ipairs(clients) do
		if client.name == name then
		 _G.print_custom("ℹ️ LSP " .. name .. " is already attached to buffer " .. bufnr)
			return true
		end
	end

	-- Try to find the initialized LSP and attach it
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == name then
			vim.lsp.buf_attach_client(bufnr, client.id)
		 _G.print_custom("✅ LSP " .. name .. " attached to buffer " .. bufnr)
			return true
		end
	end

	-- LSP is not initialized, start it
 _G.print_custom("⚠️ LSP " .. name .. " not found to attach to buffer " .. bufnr)
	-- require("lspconfig")[name].setup({}) -- Start the LSP if not running
	return false
end

--- @param name string The name of the LSP server (e.g., "pyright", "clangd").
local function attach_lsp_to_buffer(name, bufnr)
	local max_try = 5
	local attempt = 1

	local function try_attach()
		local ret = try_attach_lsp_to_buffer(name, bufnr)
		if ret then
			return
		end

	 _G.print_custom("Couldn't attach LSP. Attempt #" .. attempt)

		-- Retry after 1 second if max tries are not reached
		if attempt < max_try then
			attempt = attempt + 1
			vim.defer_fn(try_attach, 1000) -- Retry after 1000 ms (1 second)
		else
		 _G.print_custom("Couldn't attach LSP " .. name .. " to buffer")
		end
	end

	-- Start the process
	try_attach()
end

--- Function to check active buffers and attach corresponding LSPs
local function attach_lsp_to_all_buffers()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
		-- If the filetype is empty, trigger filetype detection
		if filetype == nil or filetype == "" then
		 _G.print_custom("Filetype is empty, detecting filetype for buffer: " .. vim.api.nvim_buf_get_name(bufnr))
			vim.cmd("filetype detect") -- Trigger filetype detection
			filetype = vim.api.nvim_buf_get_option(bufnr, "filetype") -- Re-fetch the filetype after detection
		end
		local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")

		if filetype == nil or filetype == "" then
		 _G.print_custom("Could not get filetype for " .. vim.inspect(bufnr) .. " with name " .. vim.inspect(filename))
			filetype = detect_filetype(bufnr)
		else
		 _G.print_custom("The filetype detect worked")
		end

		-- Check if there's a corresponding LSP for this filetype
		local lsp_name = lsp_name_of_filetype[filetype]
		if lsp_name then
			-- Try to attach the LSP to the buffer
			attach_lsp_to_buffer(lsp_name, bufnr)
		else
		 _G.print_custom(
				"No LSP for filetype " .. vim.inspect(filetype) .. " at bufnr: " .. vim.inspect(bufnr) .. " with filename: " .. vim.inspect(filename)
			)
		end
	end
end

-- Define the command to attach all LSPs
vim.api.nvim_create_user_command("AttachAllLSPs", function() attach_lsp_to_all_buffers() end, { desc = "Attach all LSPs to active buffers" })

-- Keybinding to call the command
vim.keymap.set("n", "<leader>La", attach_lsp_to_all_buffers, opts("Attach all LSPs to active buffers"))
