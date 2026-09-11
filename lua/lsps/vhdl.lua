local M = {}

M.config = {
	cmd = { "vhdl_ls" },

	filetypes = { "vhdl" },

	root_dir = require("lspconfig.util").root_pattern("vhdl_ls.toml", ".git"),

	on_init = function(client, bufnr)
		print("Lsp vhdl_ls initiated")

		local lsp_helper = require("lsps.helper.lsp_config_helper")
		lsp_helper.add_keybinds()
	end,

	on_attach = function(client, bufnr)
		--
		print("VHDL (vhdl_ls) LSP attached")
	end,
}

return M
