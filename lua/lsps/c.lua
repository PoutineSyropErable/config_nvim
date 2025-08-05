-- lua/core/lsps/c.lua
M = {}

M.config = {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--cross-file-rename",
		"--header-insertion=iwyu",
		"--log=verbose",
		"--query-driver=/opt/rocm/llvm/bin/*",
		"--fallback-style=llvm",
	},
	init_options = {
		clangdFileStatus = true,
		usePlaceholders = true,
		completeUnimported = true,
		fallbackFlags = {
			-- Standard C/C++ flags (comment out OpenCL-specific ones)
			"-std=c17",
			-- "-std=c++17",
			-- "-I/usr/local/include",  -- Common include paths
			-- Keep OpenCL flags only for actual OpenCL files
		},
	},
	filetypes = { "c", "cpp", "objc", "objcpp" }, -- Removed "x" and "opencl"
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
			fallbackFlags = { "-std=c17" }, -- Changed from C++ to C standard
		},
	},
	on_attach = function(client, bufnr)
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("c lsp attached")
		lsp_helper.add_keybinds()
	end,
}

-- Separate configuration for OpenCL files
M.opencl_config = vim.deepcopy(M.config)
M.opencl_config.init_options.fallbackFlags = {
	"-I/opt/rocm/opencl/include",
	"-I/usr/include/clc",
	"-cl-std=CL2.0",
	"-xcl", -- Only apply OpenCL mode for .cl files
}
M.opencl_config.filetypes = { "opencl" } -- Only for OpenCL files

return M
