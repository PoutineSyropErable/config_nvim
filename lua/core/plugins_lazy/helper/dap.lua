local keymap = vim.keymap
local function opts(desc) return { noremap = true, silent = true, desc = desc } end
local gu = require("_before.general_utils")

local function debug_log(func_name, ...)
	local args = table.concat({ ... }, ", ")
	gu.print_custom("[DEBUG] Called: " .. func_name .. " with args: " .. args)
end
--------------------------------------------- Debugging (nvim-dap)
-- Breakpoint Management

if false then
	local dap = require("dap")
	local dapui = require("dapui")
	local widgets = require("dap.ui.widgets")

	local function debug_next_function()
		local session = require("dap").session()
		if not session then
			_G.print_custom("❌ Debugger is not running!")
			return
		end

		if session.stopped_thread_id then
			-- Move to the next function call
			local next_call = gu.goto_next_function_call()
			if not next_call then
				_G.print_custom("❌ No next function call found.")
				return
			end

			-- dap.set_breakpoint()
			-- dap.continue()
			dap.run_to_cursor()
		else
			_G.print_custom("⏸ Debugger must be paused before running to the next function call!")
		end
	end

	-- Breakpoint Keybindings
	keymap.set("n", "<leader>bb", dap.toggle_breakpoint, opts("Toggle breakpoint at current line"))
	keymap.set("n", "<leader>bc", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, opts("Set conditional breakpoint"))
	keymap.set(
		"n",
		"<leader>bl",
		function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
		opts("Set log point (executes a log message instead of stopping execution)")
	)
	keymap.set("n", "<leader>br", dap.clear_breakpoints, opts("Clear all breakpoints"))
	keymap.set("n", "<leader>ba", function() require("telescope").extensions.dap.list_breakpoints() end, opts("List all breakpoints (Telescope UI)"))

	-- Debugging Stop/Disconnect
	keymap.set("n", "<leader>dd", function()
		dap.disconnect()
		dap.close()
	end, opts("Disconnect debugger (keep process running)"))

	keymap.set("n", "<leader>dt", function()
		dap.terminate()
		dapui.close()
	end, { desc = "Terminate debugging session (kill process)" })

	_G.last_debugged_file = nil -- Store the last file debugged

	local dap_run = function()
		-- Check if a DAP REPL buffer exists
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buf_name = vim.api.nvim_buf_get_name(buf):lower()
			if buf_name:match("dap%-repl") then
				-- vim.api.nvim_set_current_win(win) -- Focus the REPL if it's already open
				goto evaluate
			end
		end

		-- Open REPL if it's not open
		dap.repl.open()

		::evaluate::
		local input_expr = vim.fn.input("Evaluate expression: ") -- Get input first
		if input_expr and input_expr ~= "" then
			local file_ext = _G.last_debugged_file or "" -- Use stored file extension
			vim.notify("\nfiletype: " .. file_ext)
			if file_ext == ".c" or file_ext == ".cpp" then
				input_expr = "-exec " .. input_expr -- Prefix with "-exec" for GDB-based debuggers
			end
			vim.notify("running " .. input_expr)
			dap.repl.execute(input_expr) -- Pass it to REPL
			-- wont show the diff though?
		end
	end

	-- Debugging Execution Keybindings
	keymap.set("n", "<leader>dc", dap.continue, opts("--- Start/continue debugging session"))
	keymap.set("n", "<leader>dj", dap.step_over, opts("--- Step over (skip function calls)"))
	keymap.set("n", "<leader>dh", dap.step_into, opts("--- Step into function calls"))
	keymap.set("n", "<leader>dl", dap.step_out, opts("--- Step out of current function"))

	keymap.set("n", "<leader>di", dap.up, opts("backtrace one function (backtrace down)"))
	keymap.set("n", "<leader>dk", dap.down, opts("retrace one function (backtrace up)"))

	keymap.set("n", "<leader>dp", dap.pause, opts("--- Pause program execution"))
	-- Reverse Continue (Run backwards until a breakpoint)
	keymap.set("n", "<leader>db", dap.reverse_continue, opts("-- Reverse continue (run backward, previous breakpoint)"))
	-- Reverse Step (Step back one line)
	keymap.set("n", "<leader>dBl", dap.step_back, opts("--Step backward (previous line)"))
	-- Reverse Step Instruction (Step back one assembly instruction)

	keymap.set("n", "<leader>dC", dap.run_to_cursor, opts("Step to cursor"))
	keymap.set("n", "<leader>df", debug_next_function, opts("execute untill next function call"))

	-- Debugging Tools
	keymap.set("n", "<leader>d.", function() dap.repl.toggle() end, opts("Toggle debugger REPL [Not Useful]"))
	keymap.set("n", "<leader>dr", dap_run, opts("Evaluate expression in REPL"))
	keymap.set("n", "<leader>dL", dap.run_last, opts("Re-run last debugging session"))
	keymap.set("n", "<leader>dR", dap.restart, opts("Restart debugging session"))

	keymap.set("n", "<leader>d$", widgets.hover, opts("Hover to inspect variable under cursor"))
	keymap.set("n", "<leader>da", dapui.toggle, opts("Toggle DAP UI"))

	keymap.set("n", "<leader>dv", function() widgets.centered_float(widgets.scopes) end, opts("Show debugging scopes (floating window)"))
	-- keymap.set("n", "<leader>da", function() widgets.centered_float(widgets.variables) end, opts("Show all variables (floating window)"))
	keymap.set("n", "<leader>dS", function() widgets.centered_float(widgets.frames) end, opts("Show call stack (floating window)"))

	-- Telescope DAP Integrations
	keymap.set("n", "<leader>ds", function() require("telescope").extensions.dap.frames() end, opts("Show stack frames (Telescope UI)"))
	keymap.set("n", "<leader>dD", function() require("telescope").extensions.dap.commands() end, opts("List DAP commands (Telescope UI)"))

	keymap.set("n", "<leader>dm", function() require("telescope").extensions.dap.threads() end, opts("Show running threads (Telescope UI)"))

	-- Tests
	keymap.set("n", "<leader>dTc", function()
		if vim.bo.filetype == "python" then
			require("dap-python").test_class()
		end
	end)

	keymap.set("n", "<leader>dTm", function()
		if vim.bo.filetype == "python" then
			require("dap-python").test_method()
		end
	end)
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
	debug_log("find_executable")
	compile_project()
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
