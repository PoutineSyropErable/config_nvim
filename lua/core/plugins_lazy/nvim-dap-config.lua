local hd = "core.plugins_lazy.helper.barbar"

return {
	{
		"mfussenegger/nvim-dap",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
		},
		lazy = true,
		config = function()
			local dap = require("dap")

			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb" }, -- Add more if needed
				handlers = {}, -- Don't auto-configure adapters
			})

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
					justMyCode = false, -- Optional: set to true for just your code
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

					program = "${file}", -- Run the currently open file
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

					program = find_executable_custom_debug,
					args = arg_func,
				},
				-- other_c_dap,
			}

			dap.configurations.cpp = dap.configurations.c -- Apply same config for C++
		end,
	},
}
