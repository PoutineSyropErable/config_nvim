-- lua/core/lsps/c.lua
M = {}

M.config = {
	cmd = {
		-- clangd command with additional options
		"clangd",
		-- "--offset-encoding=utf-8",
		"--background-index", -- Enable background indexing
		"--clang-tidy", -- Enable clang-tidy diagnostics
		"--completion-style=detailed", -- Shows full signatures
		"--function-arg-placeholders", -- Displays parameter names
		"--cross-file-rename", -- Support for renaming symbols across files
		"--header-insertion=iwyu", -- Include "what you use" insertion
		"--log=verbose",
		"--query-driver=/opt/rocm/llvm/bin/*", -- Critical for ROCm OpenCL
		"--fallback-style=llvm",
	},
	init_options = {
		clangdFileStatus = true,
		usePlaceholders = true,
		completeUnimported = true,
		fallbackFlags = {
			"-I/opt/rocm/opencl/include", -- ROCm OpenCL headers
			"-I/usr/include/clc", -- Generic OpenCL headers
			"-cl-std=CL2.0", -- OpenCL version flag
			"-xcl", -- Force OpenCL mode
		},
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "x", "opencl" },
	root_dir = require("lspconfig.util").root_pattern(
		"compile_commands.json",
		".clang-format",
		".clangd",
		"compile_flags.txt",
		"Makefile",
		"build.sh",
		".git"
	),
	settings = {
		clangd = {
			fallbackFlags = { "-std=c++17" }, -- Adjust this if using a different C++ standard
		},
	},

	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("c lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M
