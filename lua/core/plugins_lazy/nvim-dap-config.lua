local hd = "core.plugins_lazy.helper.barbar"

return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			{ "<leader>bb", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint at current line" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "Start/continue debugging session" },
		},
		cmd = {
			"DapContinue",
			"DapToggleBreakpoint",
			"DapStepOver",
			"DapStepInto",
			"DapStepOut",
			"DapPause",
			"DapTerminate",
			"DapRestart",
			"DapRunLast",
			"DapDisconnect",
			"DapSetExceptionBreakpoints",
			"DapReplOpen",
			"DapRunToCursor",
			"DapToggleRepl",
		},

		dependencies = {
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			local dap = require("dap")

			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb" }, -- Add more if needed
				handlers = {}, -- Don't auto-configure adapters
			})

			------------------------------- Keybinds ---------------------------
			local keymap = vim.keymap
			local function opts(desc) return { noremap = true, silent = true, desc = desc } end

			local dapui = require("dapui")
			local widgets = require("dap.ui.widgets")

			local gu = require("_before.general_utils")

			local function debug_next_function()
				local session = require("dap").session()
				if not session then
					gu.print_custom("❌ Debugger is not running!")
					return
				end

				if session.stopped_thread_id then
					-- Move to the next function call
					local next_call = gu.goto_next_function_call()
					if not next_call then
						gu.print_custom("❌ No next function call found.")
						return
					end

					-- dap.set_breakpoint()
					-- dap.continue()
					dap.run_to_cursor()
				else
					gu.print_custom("⏸ Debugger must be paused before running to the next function call!")
				end
			end

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

			-- Breakpoint Keybindings
			keymap.set(
				"n",
				"<leader>bc",
				function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
				opts("Set conditional breakpoint")
			)
			keymap.set(
				"n",
				"<leader>bl",
				function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
				opts("Set log point (executes a log message instead of stopping execution)")
			)
			keymap.set("n", "<leader>br", dap.clear_breakpoints, opts("Clear all breakpoints"))
			keymap.set(
				"n",
				"<leader>ba",
				function() require("telescope").extensions.dap.list_breakpoints() end,
				opts("List all breakpoints (Telescope UI)")
			)

			keymap.set("n", "<leader>bb", dap.toggle_breakpoint, opts("Toggle breakpoint at current line"))
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

			-- Debugging Stop/Disconnect
			keymap.set("n", "<leader>dt", function()
				dap.terminate()
				dapui.close()
			end, { desc = "Terminate debugging session (kill process)" })

			keymap.set("n", "<leader>dd", function()
				dap.disconnect()
				dap.close()
			end, opts("Disconnect debugger (keep process running)"))

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

			------------------------------- Languages --------------------------

			local arg_func = function()
				local args = vim.fn.input("[DAP] Enter the program's arguments (space-separated): ")
				vim.notify("")
				if args == "" then
					return nil
				end
				return vim.split(args, " ")
			end

			-- Filetype-based setup (e.g., for Python)
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					console = "integratedTerminal", -- Output goes here
					justMyCode = true, -- Optional: set to true for just your code
					pythonPath = function()
						-- Use the active virtual environment if available
						if vim.env.VIRTUAL_ENV then
							vim.notify("Using virtual environment: " .. vim.env.VIRTUAL_ENV)
							return vim.env.VIRTUAL_ENV .. "/bin/python"
						end
						-- Otherwise, fallback to system Python
						vim.notify("Using system Python: " .. vim.fn.exepath("python3"))
						return vim.fn.exepath("python3") or "python"
					end,

					-- program = "${file}", -- Run the currently open file

					program = "/home/francois/Documents/Work/RQC/2025/Fraud/code/example_usage.py", -- Run the currently open file
					-- cwd = "/home/francois/Documents/University (Real)/Semester 10/Comp 303/Project",
					-- cwd = "/home/francois/Documents/Linux Documents/University (real)/Semester 10/Comp 303/Project/",
					-- module = "303MUD.client_local",
					-- module = "303MUD.client_remote",
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
			--

			local dap_helper = require("core.plugins_lazy.helper.barbar")

			dap.configurations.c = {

				{
					name = "C++ Debugger by itself",
					type = "cppdbg",
					request = "launch",
					console = "integratedTerminal", -- Output goes here
					justMyCode = false, -- Optional: set to true for just your code
					cwd = "${workspaceFolder}",
					stopAtEntry = false,
					setupCommands = dap_helper.setupCommands,

					program = dap_helper.find_executable,
					args = arg_func,
				},
				{
					name = "C++ Debugger by itself, custom debug flags",
					type = "cppdbg",
					request = "launch",
					console = "integratedTerminal", -- Output goes here
					justMyCode = true, -- Optional: set to true for just your code
					cwd = "${workspaceFolder}",
					stopAtEntry = false,
					setupCommands = dap_helper.setupCommands,

					program = dap_helper.find_executable_custom_debug,
					args = arg_func,
				},
				-- other_c_dap,
			}

			dap.configurations.cpp = dap.configurations.c -- Apply same config for C++
		end,
	},
}
