-- lua/core/lsps/opencl.lua
M = {}

M.config = {
	cmd = { "opencl-language-server" },
	filetypes = { "opencl" },
	root_dir = require("lspconfig").util.root_pattern(".git", ".asm-lsp.toml"),
	init_options = {
		offsetEncoding = "utf-8", -- Some servers need this too
	},
	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("lua lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M
