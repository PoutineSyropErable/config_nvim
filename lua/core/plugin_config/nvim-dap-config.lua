local dap = require("dap")
dap.set_log_level("DEBUG")

local function debug_log(func_name, ...)
	local args = table.concat({ ... }, ", ")
	print("[DEBUG] Called: " .. func_name .. " with args: " .. args)
end

local arg_func = function()
	local args = vim.fn.input("[DAP] Enter the program's arguments (space-separated): ")
	print("")
	if args == "" then
		return nil
	end
	local ret = vim.split(args, " ")
	return ret
end
-------------------------------- PYTHON ----------------------------------
require("dap-python").setup(vim.fn.exepath("python")) -- Use system Python by default

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
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

		-- program = "${file}", -- Run the currently open file
		cwd = "/home/francois/Documents/University (Real)/Semester 10/Comp 303/Project",
		module = "303MUD.client_local",
		args = arg_func,
	},
}

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
		args = arg_func, -- Script arguments
		env = {}, -- Environment variables
		stopOnEntry = false,
	},
}
-------------------------------- C/C++ ----------------------------------

local function find_in_build()
	debug_log("find_in_build")

	local build_dir = vim.fn.getcwd() .. "/build/"
	local safe_build_dir = vim.fn.shellescape(build_dir) -- Escape the path properly

	-- Check if the build directory exists
	if vim.fn.isdirectory(build_dir) == 0 then
		print("[WARNING] find_in_build(): build/ directory does not exist")
		return nil
	end

	-- Run find command safely
	local executables = vim.fn.systemlist("find " .. safe_build_dir .. " -maxdepth 1 -type f -executable")

	-- Ensure the result is valid
	if #executables > 0 and vim.fn.filereadable(executables[1]) == 1 then
		print("[DEBUG] find_in_build() found executable: " .. executables[1])
		return executables[1]
	end

	return nil
end

local function find_elf_in_cwd()
	debug_log("find_elf_in_root")
	local cwd = vim.fn.getcwd()
	local bufname = vim.fn.expand("%:t:r") -- buffer name without extension

	-- First, check if executable matching buffer name exists and is ELF
	local candidate = cwd .. "/" .. bufname
	if vim.fn.executable(candidate) == 1 then
		local file_info = vim.fn.system("file " .. vim.fn.shellescape(candidate))
		if file_info:find("ELF") then
			print("[DEBUG] Found matching ELF executable: " .. candidate)
			return candidate
		end
	end

	-- Otherwise, find any ELF executable
	local elf_executables = vim.fn.systemlist(
		"find " .. vim.fn.shellescape(cwd) .. " -maxdepth 1 -type f -executable -exec file {} \\; | grep 'ELF' | awk -F: '{print $1}'"
	)

	if #elf_executables > 0 then
		print("[DEBUG] Found ELF executable: " .. elf_executables[1])
		return elf_executables[1]
	end

	print("[WARNING] No ELF executable found.")
	return nil
end

local function parse_automake()
	debug_log("parse_automake")
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
	debug_log("parse_makefile")
	local cwd = vim.fn.getcwd()
	local makefile = cwd .. "/Makefile"
	local target_cmd = "make --dry-run --always-make --print-data-base | awk -F ': ' '/^TARGET/ {print $2; exit}'"
	local target = vim.trim(vim.fn.system(target_cmd))

	if target == "" then
		print("[WARNING] parse_makefile() did not find a TARGET, defaulting to /build/main")
		target = cwd .. "/build/main"
		if vim.fn.filereadable(target) ~= 1 then
			print("[ERROR] Target executable not found: " .. (target == "" and "(no target specified)" or target))
			return nil
		end
	end

	print("[DEBUG] parse_makefile() found executable: " .. cwd .. "/" .. target)
	return cwd .. "/" .. target
end

local function compile_project()
	debug_log("compile_project")
	local cwd = vim.fn.getcwd()
	local show_build_output = false
	print("\n")
	print("[DEBUG] Current working directory: " .. cwd)

	local build_script = cwd .. "/build.sh"
	print("[DEBUG] Expected build.sh path: " .. build_script)

	local use_make = false

	-- Function to print live output from build process
	local function print_output(_, data, _)
		if data and show_build_output then
			for _, line in ipairs(data) do
				if line ~= "" then
					print("[BUILD OUTPUT] " .. line)
				end
			end
		end
	end

	-- Check if build.sh exists and is executable
	if vim.fn.filereadable(build_script) == 1 then
		print("\n")
		print("[DAP] Running build.sh debug...")
		print("\n")

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
			print("\n")
			print("[ERROR] Build.sh failed! Debugging cannot start.")
			print("\n")
			return nil -- Exit function early
		end

		print("[DAP] Build.sh completed successfully.")
		print("\n")
	else
		print("[WARNING] build.sh not found! Falling back to 'make debug'.")
		print("\n")
		use_make = true
	end

	local try_dumb_gcc = false
	-- If build.sh doesn't exist, use `make` with debug flags
	if use_make then
		if vim.fn.filereadable(cwd .. "/Makefile") ~= 1 then
			print("[WARNING] Makefile not found, skipping make.")
			print("\n")
			try_dumb_gcc = true
		else
			local make_cmd = "make clean && make CFLAGS='-g -O0 -Wall -Wextra' LDFLAGS='-g'"
			print("\n")
			print("[DEBUG] Running: " .. make_cmd)
			print("\n")

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
				print("\n")
				print("[ERROR] Make build failed! Debugging cannot start.")
				print("\n")
				try_dumb_gcc = true
			end

			print("\n")
			print("[DAP] Make build completed successfully.")
			print("\n")
		end
	end

	if try_dumb_gcc then
		local bufname = vim.api.nvim_buf_get_name(0)
		local ext = bufname:match("%.([^.]+)$")
		local output_name = bufname:gsub("%.%w+$", "")
		local compiler_cmd

		if ext == "c" then
			compiler_cmd = { "gcc", bufname, "-o", output_name, "-g", "-O0", "-Wall", "-Wextra" }
		elseif ext == "cpp" or ext == "cc" or ext == "cxx" then
			compiler_cmd = { "g++", bufname, "-o", output_name, "-g", "-O0", "-Wall", "-Wextra", "-std=c++17" }
		else
			print("[ERROR] Unsupported file type: " .. (ext or "unknown"))
			return nil
		end

		print("[DEBUG] Running single-file compilation: " .. table.concat(compiler_cmd, " "))

		local job_id = vim.fn.jobstart(compiler_cmd, {
			stdout_buffered = false,
			stderr_buffered = false,
			on_stdout = print_output,
			on_stderr = print_output,
		})

		local exit_code = vim.fn.jobwait({ job_id })[1]

		if exit_code ~= 0 then
			print("\n")
			print("[ERROR] Single-file compilation failed! Debugging cannot start.")
			print("\n")
			return nil
		end

		print("\n")
		print("[DEBUG] Single-file compilation completed successfully.")
		print("\n")
	end
end

local function store_debug_file()
	local bufname = vim.api.nvim_buf_get_name(0)
	local ext = bufname:match("^.+(%..+)$") or ""

	if ext == ".c" or ext == ".cpp" or ext == ".h" or ext == ".hpp" then
		_G.last_debugged_file = ext -- Store the last known file extension
		print("Stored last debugged file type: " .. ext)
	end
end

local function find_executable()
	debug_log("find_executable")
	compile_project()
	local exe = parse_automake() or find_in_build() or find_elf_in_cwd() or parse_makefile()
	store_debug_file()

	print("\n")
	if exe then
		print("[DAP] Found executable: " .. exe)
		print("")
		return exe
	else
		error("[DAP] No executable found. Check AutoMake, build/, ELF binaries, or Makefile.")
	end
end

local function custom_make()
	local cwd = vim.fn.getcwd()
	local show_build_output = false

	-- Function to print live output from build process
	local function print_output(_, data, _)
		if data and show_build_output then
			for _, line in ipairs(data) do
				if line ~= "" then
					print("[BUILD OUTPUT] " .. line)
				end
			end
		end
	end

	if vim.fn.filereadable(cwd .. "/Makefile") ~= 1 then
		print("[WARNING] Makefile not found, skipping make.")
		print("\n")
		return nil
	else
		local custom_debug_input = vim.fn.input("What is the custom debug flag you want added (No -, Lower case): ")
		local debug_flags = ""

		for flag in custom_debug_input:gmatch("%S+") do
			debug_flags = debug_flags .. " -D" .. string.upper(flag)
		end

		local make_cmd = "make clean && make CFLAGS='-g -O0 -Wall -Wextra " .. debug_flags .. "' LDFLAGS='-g'"

		print("\n")
		print("[DEBUG] Running: " .. make_cmd)
		print("\n")

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
			print("\n")
			print("[ERROR] Make build failed! Debugging cannot start.")
			print("\n")
			return nil
		end

		print("\n")
		print("[DAP] Make build completed successfully.")
		print("\n")
	end
end

local function find_executable_custom_debug()
	debug_log("find_executable_custom_debug_falg")
	custom_make()

	local exe = parse_automake() or find_in_build() or find_elf_in_cwd() or parse_makefile()
	store_debug_file()

	print("\n")
	if exe then
		print("[DAP] Found executable: " .. exe)
		print("")
		return exe
	else
		error("[DAP] No executable found. Check AutoMake, build/, ELF binaries, or Makefile.")
	end

	vim.cmd("messages")
end

local function get_source_directories()
	debug_log("get_source_directories")

	local cwd = vim.fn.getcwd()
	local home = os.getenv("HOME")

	-- 🚨 Prevent scanning dangerous locations
	if cwd == "/" or cwd == home then
		print("[WARN] get_source_directories() aborted: Unsafe directory")
		return {}
	end

	-- Ensure the directory is deep enough
	local subdirs = {}
	for dir in cwd:gmatch("[^/]+") do
		table.insert(subdirs, dir)
	end
	if #subdirs < 3 then
		print("[WARN] get_source_directories() aborted: Not deep enough")
		return {}
	end

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

local function get_GDBsetupCommands()
	local cwd = vim.fn.getcwd()
	local commands = {
		{ text = "-enable-pretty-printing", description = "Enable GDB pretty printing", ignoreFailures = true },
		{ text = "set auto-load safe-path /", description = "Allow auto-loading of symbols", ignoreFailures = false },
		{ text = "set breakpoint pending on", description = "Enable pending breakpoints", ignoreFailures = false },
		{
			text = "set debug-file-directory " .. cwd .. "/build",
			description = "Ensure GDB finds debug symbols",
			ignoreFailures = false,
		},
		{ text = "directory " .. cwd, description = "Set source directory", ignoreFailures = false },
		{ text = "info sources", description = "Check if sources are loaded", ignoreFailures = false },
	}

	-- **Only append source directories when actually needed**
	local src_dirs = get_source_directories()
	for _, dir in ipairs(src_dirs) do
		table.insert(commands, { text = "directory " .. dir, description = "Add source directory", ignoreFailures = false })
	end

	return commands
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

local other_c_dap = {
	name = "Attach to GDB Server",
	type = "cppdbg",
	request = "launch",
	MIMode = "gdb",
	miDebuggerServerAddress = "localhost:1234",
	miDebuggerPath = "/usr/bin/gdb",
	cwd = "${workspaceFolder}",
	program = function()
		return find_executable()
		-- return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
	end,
}

dap.configurations.c = {
	{
		name = "C++ Debugger by itself, custom debug flags",
		type = "cppdbg",
		request = "launch",
		console = "integratedTerminal", -- Output goes here
		justMyCode = true, -- Optional: set to true for just your code
		cwd = "${workspaceFolder}",
		stopAtEntry = false,
		setupCommands = setupCommands,

		program = find_executable_custom_debug,
		args = arg_func,
	},
	{
		name = "C++ Debugger by itself",
		type = "cppdbg",
		request = "launch",
		console = "integratedTerminal", -- Output goes here
		justMyCode = true, -- Optional: set to true for just your code
		cwd = "${workspaceFolder}",
		stopAtEntry = false,
		setupCommands = setupCommands,

		program = find_executable,
		args = arg_func,
	},
	-- other_c_dap,
}

dap.configurations.cpp = dap.configurations.c -- Apply same config for C++

-------------------------------- JAVA ----------------------------------
local function get_class_path()
	-- Get the full path of the current Java file
	local java_file_path = vim.api.nvim_buf_get_name(0)

	-- Ensure the file is a Java file
	local file_ext = vim.fn.fnamemodify(java_file_path, ":e")
	if file_ext ~= "java" then
		print("❌ (In get_class_path), Error: This is not a Java file!")
		return nil
	end

	-- Define the Python script location
	local home = vim.fn.expand("$HOME")
	AutoMakeJava_location = "/Documents/University (Real)/Semester 10/Comp 303/AutomakeJava/"
	local dap_utils_script = home .. AutoMakeJava_location .. "src/dap-utils.py"

	-- Construct the command to run Python script
	local command = "python3 " .. vim.fn.shellescape(dap_utils_script) .. " " .. vim.fn.shellescape(java_file_path) .. " --getClassPath"
	print("running.. (" .. command .. ")")

	-- Execute the command and capture the output
	local result = vim.fn.system(command)

	-- Trim whitespace and newlines
	result = result:gsub("%s+$", "")

	-- Handle errors (empty output means something went wrong)
	if result == "" then
		print("❌ Error: `dap-utils.py` did not return a classpath!")
		return nil
	end

	-- Convert classpath string into a Lua table (split by `:`)
	local classpaths = {}
	for path in result:gmatch("[^:]+") do
		table.insert(classpaths, path)
	end

	return classpaths
end

local function get_main_class()
	-- Get the full path of the current Java file
	local java_file_path = vim.api.nvim_buf_get_name(0)

	-- Ensure the file is a Java file
	local file_ext = vim.fn.fnamemodify(java_file_path, ":e")
	if file_ext ~= "java" then
		print("❌ (in get_main_class) Error: This is not a Java file!")
		return nil
	end

	-- Define the Python script location
	local home = vim.fn.expand("$HOME")
	AutoMakeJava_location = "/Documents/University (Real)/Semester 10/Comp 303/AutomakeJava/"
	local dap_utils_script = home .. AutoMakeJava_location .. "src/dap-utils.py"

	-- Construct the command to run Python script
	local command = "python3 " .. vim.fn.shellescape(dap_utils_script) .. " " .. vim.fn.shellescape(java_file_path) .. " --mainModule"
	print("running.. (" .. command .. ")")

	-- Execute the command and capture the output
	local result = vim.fn.system(command)

	-- Trim whitespace and newlines
	result = result:gsub("%s+$", "")

	-- Handle errors (empty output means something went wrong)
	if result == "" then
		print("❌ Error: `dap-utils.py` did not return a main class!")
		return nil
	end

	return result -- Return the main class name
end

local function wait_for_debugger_async(host, port, timeout, callback)
	local uv = vim.loop
	local start_time = uv.now()

	print("⏳ Waiting for Java Debugger to start on " .. host .. ":" .. port .. "...")

	local function check_debugger()
		local socket = uv.new_tcp()
		socket:connect(host, port, function(err)
			if not err then
				socket:close()
				print("✅ Java Debugger is ready! Attaching...")
				callback(true)
			else
				if (uv.now() - start_time) >= timeout then
					print("❌ Timeout! Java Debugger did not start within " .. timeout .. "ms.")
					callback(false)
				else
					-- Retry in 500ms (non-blocking)
					uv.timer_start(uv.new_timer(), 500, 0, check_debugger)
				end
			end
		end)
	end

	-- Start checking
	check_debugger()
end

local function start_automake()
	local filepath = vim.api.nvim_buf_get_name(0) -- Get the full file path
	local java_file = vim.fn.shellescape(filepath)
	if java_file == "" then
		print("❌ No Java file selected!")
		return
	end

	local home = vim.fn.expand("$HOME")
	local AutoMakeJava_location = "/Documents/University (Real)/Semester 10/Comp 303/AutomakeJava"
	local autoMakeScript = home .. AutoMakeJava_location .. "/src/automake.py"

	-- local cmd = "python3 " .. autoMakeScript .. java_file .. '" --debug &'
	local cmd = string.format('python3 "%s" "%s" --debug &', autoMakeScript, filepath)
	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				print("✅ Automake started Java Debugger.")
			else
				print("❌ Automake failed.")
			end
		end,
	})
end

local other_java_dap = {
	-- 🚀 Launch Java Application with Debugging
	type = "java",
	request = "launch",
	name = "Launch Java Application",

	-- Use functions so values are fetched dynamically at runtime
	classPaths = function() return get_class_path() end,
	mainClass = function() return get_main_class() end,

	javaExec = "/usr/lib/jvm/java-21-openjdk/bin/java",

	-- If using a multi-module project, remove this
	-- projectName = "yourProjectName",

	-- This is automatically set by `nvim-jdtls`
	modulePaths = {},
}

-- dap.adapters.java = function(callback)
-- 	-- FIXME:
-- 	-- Here a function needs to trigger the `vscode.java.startDebugSession` LSP command
-- 	-- The response to the command must be the `port` used below
-- 	callback({
-- 		type = "server",
-- 		host = "127.0.0.1",
-- 		port = javaDapPort,
-- 	})
-- end

if PRE_CONFIG_FRANCK.useMyJavaDap then
	dap.adapters.java = function(callback)
		-- Send a request to the LSP to start the debug session
		vim.lsp.buf_request(0, "workspace/executeCommand", {
			command = "vscode.java.startDebugSession",
			arguments = {},
		}, function(err, result)
			if err then
				vim.notify("Failed to start debug session: " .. err.message)
			else
				vim.notify("Result is: " .. result)
				local port = result
				callback({
					type = "server",
					host = "127.0.0.1",
					port = port,
				})
			end
		end)
	end

	local javaDapPort = 5005
	dap.configurations.java = {
		{
			-- 🚀 Attach to a Running JVM Debug Session
			type = "java",
			request = "attach",
			name = "Debug (Attach) - Remote",
			hostName = "127.0.0.1",
			port = javaDapPort, -- Ensure your Java app is started with `-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005`
			timeout = 30000,
		},
		-- other_java_dap
	}
end

local function opts(desc) return { noremap = true, silent = true, desc = desc } end
vim.keymap.set("n", "<F8>", function()
	local class_path = get_class_path()
	if class_path then
		print("✅ Java Class Path: " .. table.concat(class_path, "\n"))
	end
end, opts("get class path"))

vim.keymap.set("n", "<F9>", function()
	local main_class = get_main_class()
	if main_class then
		print("✅ Java Main Class: " .. main_class)
	end
end, opts("get main class"))

vim.keymap.set("n", "<F10>", start_automake, opts("Start automake debugger"))
