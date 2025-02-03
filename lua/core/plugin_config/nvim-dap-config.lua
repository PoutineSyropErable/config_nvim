local dap = require("dap")

-------------------------------- C/C++ ----------------------------------

dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "-i", "dap" },
}

local function get_source_directories()
	local cwd = vim.fn.getcwd()
	local dirs = {}
	local output = vim.fn.systemlist("find " .. cwd .. " -type f -name '*.c' -exec dirname {} \\; | sort -u")

	if #output == 0 then
		table.insert(dirs, cwd) -- Default to project root if empty
	else
		for _, dir in ipairs(output) do
			table.insert(dirs, dir)
		end
	end

	return dirs
end

dap.configurations.c = {
	{
		name = "Build & Debug main",
		type = "gdb",
		request = "launch",
		program = function()
			local exe_path = vim.fn.getcwd() .. "/build/main"
			if vim.fn.filereadable(exe_path) == 0 then
				os.execute("make")
			end
			return exe_path
		end,
		cwd = vim.fn.getcwd(),
		stopAtEntry = false,
		setupCommands = vim.tbl_flatten({
			{ text = "-enable-pretty-printing", description = "Enable GDB pretty printing", ignoreFailures = true },
			{ text = "set auto-load safe-path /", description = "Allow auto-loading of symbols", ignoreFailures = false },
			{ text = "set breakpoint pending on", description = "Enable pending breakpoints", ignoreFailures = false },
			vim.tbl_map(function(dir)
				return { text = "directory " .. dir, description = "Add source directory", ignoreFailures = false }
			end, get_source_directories()),
		}),
	},
}

dap.configurations.cpp = dap.configurations.c -- Apply same config for C++

-------------------------------- BASH ----------------------------------

-- DAP Adapter for Bash
dap.adapters.bashdb = {
	type = "executable",
	command = "bash-debug-adapter",
	name = "bashdb",
}

-- DAP Configurations for Bash
dap.configurations.sh = {
	{
		name = "Run Bash Script",
		type = "bashdb",
		request = "launch",
		program = "${file}", -- Current file
		cwd = "${workspaceFolder}",
		args = {}, -- Script arguments
		env = {}, -- Environment variables
		stopOnEntry = false,
	},
}

-------------------------------- PYTHON ----------------------------------

require("dap-python").setup(vim.fn.exepath("python3")) -- Use system Python by default

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}", -- Run the currently open file
		pythonPath = function()
			-- Use the active virtual environment if available
			if vim.env.VIRTUAL_ENV then
				return vim.env.VIRTUAL_ENV .. "/bin/python"
			end
			-- Otherwise, fallback to system Python
			return vim.fn.exepath("python3") or "python"
		end,
	},
}
