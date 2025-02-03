local dap = require("dap")

-------------------------------- C/C++ ----------------------------------

dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "-i", "dap" },
}

local function find_in_build()
	local build_dir = vim.fn.getcwd() .. "/build/"
	local executables = vim.fn.systemlist("find " .. build_dir .. " -maxdepth 1 -type f -executable")
	if #executables > 0 then
		return executables[1]
	end
	return nil
end

local function find_elf_in_root()
	local cwd = vim.fn.getcwd()
	local elf_executables =
		vim.fn.systemlist("find " .. cwd .. " -maxdepth 1 -type f -executable -exec file {} \\; | grep 'ELF' | awk -F: '{print $1}'")
	if #elf_executables > 0 then
		return elf_executables[1]
	end
	return nil
end

local function parse_automake()
	local cwd = vim.fn.getcwd()
	local automake_file = cwd .. "/AutoMake"

	-- Check if the file exists
	if vim.fn.filereadable(automake_file) == 0 then
		return nil
	end

	-- Read the file line by line
	for _, line in ipairs(vim.fn.readfile(automake_file)) do
		local target = line:match('TARGET="(.-)"')
		if target then
			return cwd .. "/" .. target -- Return the full path
		end
	end

	return nil -- Return nil if no TARGET line was found
end

local function parse_makefile()
	local cwd = vim.fn.getcwd()
	local makefile = cwd .. "/Makefile"
	local target_cmd = "make --dry-run --always-make --print-data-base | awk -F ': ' '/^TARGET/ {print $2; exit}'"
	local target = vim.trim(vim.fn.system(target_cmd))

	if target == "" then
		return cwd .. "/build/main"
	end
	return cwd .. "/" .. target
end

local function find_executable()
	return parse_automake() or find_in_build() or find_elf_in_root() or parse_makefile()
end

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
			return find_executable()
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
