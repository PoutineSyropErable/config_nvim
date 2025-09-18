local gu = require("_before.general_utils")

local function debug_log(func_name, ...)
	local args = table.concat({ ... }, ", ")
	gu.print_custom("[DEBUG] Called: " .. func_name .. " with args: " .. args)
end

-------------------------------- C/C++ ----------------------------------

local function find_in_build()
	debug_log("find_in_build")

	local build_dir = vim.fn.getcwd() .. "/build/"
	local safe_build_dir = vim.fn.shellescape(build_dir) -- Escape the path properly

	-- Check if the build directory exists
	if vim.fn.isdirectory(build_dir) == 0 then
		vim.notify("[WARNING] find_in_build(): build/ directory does not exist")
		return nil
	end

	-- Run find command safely
	local executables = vim.fn.systemlist("find " .. safe_build_dir .. " -maxdepth 1 -type f -executable")

	-- Ensure the result is valid
	if #executables > 0 and vim.fn.filereadable(executables[1]) == 1 then
		vim.notify("[DEBUG] find_in_build() found executable: " .. executables[1])
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
			vim.notify("[DEBUG] Found matching ELF executable: " .. candidate)
			return candidate
		end
	end

	-- Otherwise, find any ELF executable
	local elf_executables = vim.fn.systemlist(
		"find " .. vim.fn.shellescape(cwd) .. " -maxdepth 1 -type f -executable -exec file {} \\; | grep 'ELF' | awk -F: '{print $1}'"
	)

	if #elf_executables > 0 then
		vim.notify("[DEBUG] Found ELF executable: " .. elf_executables[1])
		return elf_executables[1]
	end

	vim.notify("[WARNING] No ELF executable found.")
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
			vim.notify("[DAP] parse_automake() found executable: " .. cwd .. "/" .. target)
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
		vim.notify("[WARNING] parse_makefile() did not find a TARGET, defaulting to /build/main")
		target = cwd .. "/build/main"
		if vim.fn.filereadable(target) ~= 1 then
			vim.notify("[ERROR] Target executable not found: " .. (target == "" and "(no target specified)" or target))
			return nil
		end
	end

	vim.notify("[DEBUG] parse_makefile() found executable: " .. cwd .. "/" .. target)
	return cwd .. "/" .. target
end

local function compile_project()
	debug_log("compile_project")
	local cwd = vim.fn.getcwd()
	local show_build_output = false
	vim.notify("\n")
	vim.notify("[DEBUG] Current working directory: " .. cwd)

	local build_script = cwd .. "/build.sh"
	vim.notify("[DEBUG] Expected build.sh path: " .. build_script)

	local use_make = false

	-- Function to print live output from build process
	local function print_output(_, data, _)
		if data and show_build_output then
			for _, line in ipairs(data) do
				if line ~= "" then
					vim.notify("[BUILD OUTPUT] " .. line)
				end
			end
		end
	end

	-- Check if build.sh exists and is executable
	if vim.fn.filereadable(build_script) == 1 then
		vim.notify("\n")
		vim.notify("[DAP] Running build.sh debug...")
		vim.notify("\n")

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
			vim.notify("\n")
			vim.notify("[ERROR] Build.sh failed! Debugging cannot start.")
			vim.notify("\n")
			return nil -- Exit function early
		end

		vim.notify("[DAP] Build.sh completed successfully.")
		vim.notify("\n")
	else
		vim.notify("[WARNING] build.sh not found! Falling back to 'make debug'.")
		vim.notify("\n")
		use_make = true
	end

	local try_dumb_gcc = false
	-- If build.sh doesn't exist, use `make` with debug flags
	if use_make then
		if vim.fn.filereadable(cwd .. "/Makefile") ~= 1 then
			vim.notify("[WARNING] Makefile not found, skipping make.")
			vim.notify("\n")
			try_dumb_gcc = true
		else
			local make_cmd = "make clean && make CFLAGS='-g -O0 -Wall -Wextra' LDFLAGS='-g'"
			vim.notify("\n")
			vim.notify("[DEBUG] Running: " .. make_cmd)
			vim.notify("\n")

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
				vim.notify("\n")
				vim.notify("[ERROR] Make build failed! Debugging cannot start.")
				vim.notify("\n")
				try_dumb_gcc = true
			end

			vim.notify("\n")
			vim.notify("[DAP] Make build completed successfully.")
			vim.notify("\n")
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
			vim.notify("[ERROR] Unsupported file type: " .. (ext or "unknown"))
			return nil
		end

		vim.notify("[DEBUG] Running single-file compilation: " .. table.concat(compiler_cmd, " "))

		local job_id = vim.fn.jobstart(compiler_cmd, {
			stdout_buffered = false,
			stderr_buffered = false,
			on_stdout = print_output,
			on_stderr = print_output,
		})

		local exit_code = vim.fn.jobwait({ job_id })[1]

		if exit_code ~= 0 then
			vim.notify("\n")
			vim.notify("[ERROR] Single-file compilation failed! Debugging cannot start.")
			vim.notify("\n")
			return nil
		end

		vim.notify("\n")
		vim.notify("[DEBUG] Single-file compilation completed successfully.")
		vim.notify("\n")
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
					_G.print_custom("[BUILD OUTPUT] " .. line)
				end
			end
		end
	end

	if vim.fn.filereadable(cwd .. "/Makefile") ~= 1 then
		vim.notify("[WARNING] Makefile not found, skipping make.")
		vim.notify("\n")
		return nil
	else
		local custom_debug_input = vim.fn.input("What is the custom debug flag you want added (No -, Lower case): ")
		local debug_flags = ""

		for flag in custom_debug_input:gmatch("%S+") do
			debug_flags = debug_flags .. " -D" .. string.upper(flag)
		end

		local make_cmd = "make clean && make CFLAGS='-g -O0 -Wall -Wextra " .. debug_flags .. "' LDFLAGS='-g'"

		vim.notify("\n")
		vim.notify("[DEBUG] Running: " .. make_cmd)
		vim.notify("\n")

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
			vim.notify("\n")
			vim.notify("[ERROR] Make build failed! Debugging cannot start.")
			vim.notify("\n")
			return nil
		end

		vim.notify("\n")
		vim.notify("[DAP] Make build completed successfully.")
		vim.notify("\n")
	end
end

local function store_debug_file()
	local bufname = vim.api.nvim_buf_get_name(0)
	local ext = bufname:match("^.+(%..+)$") or ""

	if ext == ".c" or ext == ".cpp" or ext == ".h" or ext == ".hpp" then
		_G.last_debugged_file = ext -- Store the last known file extension
		vim.notify("Stored last debugged file type: " .. ext)
	end
end

local M = {}

M.setupCommands = {
	{ text = "-enable-pretty-printing", description = "Enable pretty printing", ignoreFailures = true },
	{ text = "set auto-load safe-path /", description = "Allow auto-loading of symbols", ignoreFailures = false },
	{ text = "directory " .. vim.fn.getcwd(), description = "Set source directory", ignoreFailures = false },
	{ text = "set debug-file-directory " .. vim.fn.getcwd() .. "/build", description = "Set debug symbols directory", ignoreFailures = false },
}

function M.find_executable()
	print("test")
	debug_log("find_executable")
	compile_project()
	local exe = parse_automake() or find_in_build() or find_elf_in_cwd() or parse_makefile()
	print("exe = " .. vim.inspect(exe))
	store_debug_file()

	vim.notify("\n")
	if exe then
		vim.notify("[DAP] Found executable: " .. exe)
		vim.notify("")
		return exe
	else
		error("[DAP] No executable found. Check AutoMake, build/, ELF binaries, or Makefile.")
	end
end

function M.find_executable_custom_debug()
	debug_log("find_executable_custom_debug_falg")
	custom_make()

	local exe = parse_automake() or find_in_build() or find_elf_in_cwd() or parse_makefile()
	store_debug_file()

	vim.notify("\n")
	if exe then
		vim.notify("[DAP] Found executable: " .. exe)
		vim.notify("")
		return exe
	else
		error("[DAP] No executable found. Check AutoMake, build/, ELF binaries, or Makefile.")
	end

	vim.cmd("messages")
end

return M
