local M = {}

M.config = {
	cmd = {
		"clangd",
		"--background-index",
		"--completion-style=detailed",
		"--function-arg-placeholders",
	},
	init_options = {
		clangdFileStatus = true,
		usePlaceholders = true,
		completeUnimported = true,
		fallbackFlags = {
			"-std=c23",
		},
	},
	filetypes = { "c", "cpp", "objc", "objcpp" },
	root_dir = require("lspconfig.util").root_pattern("compile_commands.json", ".clang-format", ".clangd", "compile_flags.txt", "Makefile", ".git"),
	on_attach = function(client, bufnr)
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("C LSP attached")
		lsp_helper.add_keybinds(client, bufnr)
	end,
}

return M
