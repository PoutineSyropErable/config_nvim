local dap = require('dap')
local dap_python = require('dap-python')

-- Set the path to the Python interpreter in your virtual environment
dap_python.setup('/home/francois/MainPython_Virtual_Environment/pip_venv/bin/python')

-- Python Debugging Configuration
dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}", -- This will launch the currently opened file
        pythonPath = function()
            return '/home/francois/MainPython_Virtual_Environment/pip_venv/bin/python' -- Use your virtual environment's Python path
        end,
    },
}


-- C/C++ Debugging Configuration
dap.adapters.cppdbg = {
    type = 'executable',
    command = 'lldb-vscode', -- Adjust if you're using a different debugger
    name = 'lldb',
}

dap.configurations.cpp = {
    {
        name = "Launch C++",
        type = "cppdbg",
        request = "launch",
        program = "${workspaceFolder}/path/to/your/executable", -- Adjust this path
        args = {},
        stopAtEntry = false,
        cwd = '${workspaceFolder}',
        environment = {},
        externalConsole = false,
        MIMode = "gdb",
        setupCommands = {
            {
                text = "-enable-pretty-printing",
                description = "Enable pretty printing",
                ignoreFailures = true,
            },
        },
    },
}

dap.configurations.c = dap.configurations.cpp -- Optional: Use the same configuration for C




-- DAP Adapter for Bash
dap.adapters.bashdb = {
	type = 'executable',
	command = 'bash-debug-adapter',
	name = 'bashdb',
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

