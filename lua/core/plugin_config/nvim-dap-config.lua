local dap = require("dap")
dap.set_log_level("TRACE")

-------------------------------- C/C++ ----------------------------------

local function find_in_build()
	local build_dir = vim.fn.getcwd() .. "/build/"
	local safe_build_dir = vim.fn.shellescape(build_dir) -- Escape the path properly

	local executables = vim.fn.systemlist("find " .. safe_build_dir .. " -maxdepth 1 -type f -executable")
	if #executables > 0 then
		print("[DAP] find_in_build() found executable: " .. executables[1])
		return executables[1]
	end
	return nil
end

local function find_elf_in_root()
	local cwd = vim.fn.getcwd()
	local elf_executables =
		vim.fn.systemlist("find " .. cwd .. " -maxdepth 1 -type f -executable -exec file {} \\; | grep 'ELF' | awk -F: '{print $1}'")
	if #elf_executables > 0 then
		print("[DAP] find_elf_in_root() found executable: " .. elf_executables[1])
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
			print("[DAP] parse_automake() found executable: " .. cwd .. "/" .. target)
			return cwd .. "/" .. target
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
		print("[DAP] parse_makefile() did not find a TARGET, defaulting to /build/main")
		return cwd .. "/build/main"
	end

	print("[DAP] parse_makefile() found executable: " .. cwd .. "/" .. target)
	return cwd .. "/" .. target
end

local function compile_project()
	local cwd = vim.fn.getcwd()
	print("\n\n")
	print("[DEBUG] Current working directory: " .. cwd)

	local build_script = cwd .. "/build.sh"
	print("[DEBUG] Expected build.sh path: " .. build_script)

	local use_make = false

	-- Function to print live output from build process
	local function print_output(_, data, _)
		if data then
			for _, line in ipairs(data) do
				if line ~= "" then
					print("[BUILD OUTPUT] " .. line)
				end
			end
		end
	end

	-- Check if build.sh exists and is executable
	if vim.fn.filereadable(build_script) == 1 then
		print("\n\n")
		print("[DAP] Running build.sh debug...")
		print("\n\n")

		-- Use `vim.fn.jobstart` for real-time output capturing
		local job_id = vim.fn.jobstart({ "sh", build_script, "debug" }, {
			stdout_buffered = false,
			stderr_buffered = false,
			on_stdout = print_output,
			on_stderr = print_output,
		})

		-- Wait for job to finish
		local exit_code = vim.fn.jobwait({ job_id })[1]

		if exit_code ~= 0 then
			print("\n\n")
			print("[ERROR] Build.sh failed! Debugging cannot start.")
			print("\n\n")
			return nil -- Exit function early
		end

		print("\n\n")
		print("[DAP] Build.sh completed successfully.")
		print("\n\n")
	else
		print("\n\n")
		print("[WARNING] build.sh not found! Falling back to 'make debug'.")
		print("\n\n")
		use_make = true
	end

	-- If build.sh doesn't exist, use `make` with debug flags
	if use_make then
		local make_cmd = "make clean && make CFLAGS='-g -O0 -Wall -Wextra' LDFLAGS='-g'"
		print("\n\n")
		print("[DEBUG] Running: " .. make_cmd)
		print("\n\n")

		-- Run `make` with jobstart to capture its output
		local job_id = vim.fn.jobstart(make_cmd, {
			stdout_buffered = false,
			stderr_buffered = false,
			on_stdout = print_output,
			on_stderr = print_output,
		})

		-- Wait for job to finish
		local exit_code = vim.fn.jobwait({ job_id })[1]

		if exit_code ~= 0 then
			print("\n\n")
			print("[ERROR] Make build failed! Debugging cannot start.")
			print("\n\n")
			return nil -- Exit function early
		end

		print("\n\n")
		print("[DAP] Make build completed successfully.")
		print("\n\n")
	end
end

local function find_executable()
	compile_project()
	local exe = parse_automake() or find_in_build() or find_elf_in_root() or parse_makefile()

	if exe then
		print("[DEBUG] find_executable() raw path: " .. exe)

		-- Remove fnameescape (test without escaping)
		-- local safe_exe = vim.fn.fnameescape(exe) -- Might be breaking the path
		local safe_exe = exe

		print("[DAP] Final executable: " .. safe_exe)
		return safe_exe
	else
		error("[DAP] No executable found. Check AutoMake, build/, ELF binaries, or Makefile.")
	end
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

local GDBsetupCommands = {
	{ text = "-enable-pretty-printing", description = "Enable GDB pretty printing", ignoreFailures = true },
	{ text = "set auto-load safe-path /", description = "Allow auto-loading of symbols", ignoreFailures = false },
	{ text = "set breakpoint pending on", description = "Enable pending breakpoints", ignoreFailures = false },
	{
		text = "set debug-file-directory " .. vim.fn.getcwd() .. "/build",
		description = "Ensure GDB finds debug symbols",
		ignoreFailures = false,
	},
	{ text = "directory " .. vim.fn.getcwd(), description = "Set source directory", ignoreFailures = false },
	{ text = "info sources", description = "Check if sources are loaded", ignoreFailures = false },
}

-- Append source directories manually
for _, dir in ipairs(get_source_directories()) do
	table.insert(GDBsetupCommands, { text = "directory " .. dir, description = "Add source directory", ignoreFailures = false })
end

dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = vim.fn.expand("~") .. "/.vscode/extensions/ms-vscode.cpptools-1.23.5-linux-x64/debugAdapters/bin/OpenDebugAD7",
}

dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--quiet", "--interpreter=dap" },
}

local setupCommands = {
	{ text = "-enable-pretty-printing", description = "Enable pretty printing", ignoreFailures = true },
	{ text = "set auto-load safe-path /", description = "Allow auto-loading of symbols", ignoreFailures = false },
	{ text = "directory " .. vim.fn.getcwd(), description = "Set source directory", ignoreFailures = false },
	{ text = "set debug-file-directory " .. vim.fn.getcwd() .. "/build", description = "Set debug symbols directory", ignoreFailures = false },
}

dap.configurations.c = {
	{
		name = "C++ Debugger by itself",
		type = "cppdbg",
		request = "launch",
		program = function()
			return find_executable()
			-- return vim.fn.getcwd() .. "/build/mysh"
		end,
		console = "integratedTerminal", -- Output goes here
		justMyCode = true, -- Optional: set to true for just your code
		args = function()
			return vim.split(vim.fn.input("[DAP] Enter arguments (space-separated): "), " ")
		end,
		-- cwd = vim.fn.getcwd(),
		cwd = "${workspaceFolder}",
		stopAtEntry = true,
		setupCommands = setupCommands,
	},
	-- {
	-- 	name = "Attach to GDB Server",
	-- 	type = "cppdbg",
	-- 	request = "launch",
	-- 	MIMode = "gdb",
	-- 	miDebuggerServerAddress = "localhost:1234",
	-- 	miDebuggerPath = "/usr/bin/gdb",
	-- 	cwd = "${workspaceFolder}",
	-- 	program = function()
	-- 		return find_executable()
	-- 		-- return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
	-- 	end,
	-- },
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

require("dap-python").setup(vim.fn.exepath("python")) -- Use system Python by default

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}", -- Run the currently open file
		console = "integratedTerminal", -- Output goes here
		justMyCode = false, -- Optional: set to true for just your code
		pythonPath = function()
			-- Use the active virtual environment if available
			if vim.env.VIRTUAL_ENV then
				print("Using virtual environment: " .. vim.env.VIRTUAL_ENV)
				return vim.env.VIRTUAL_ENV .. "/bin/python"
			end
			-- Otherwise, fallback to system Python
			print("Using system Python: " .. vim.fn.exepath("python3"))
			return vim.fn.exepath("python3") or "python"
		end,
	},
}
