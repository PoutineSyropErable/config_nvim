local M = {}

M.config = {
	cmd = { "tcl-lsp-server" },

	settings = {
		tclLsp = {
			dialect = "tcl8.6",
		},
	},

	filetypes = { "tcl", "tcl-apl" },

	root_dir = require("lspconfig.util").root_pattern(".tcl-lsp.ini", "tclpkg.tcl", ".git"),

	on_init = function(client, bufnr)
		print("Lsp tcl-lsp-server initiated")

		local lsp_helper = require("lsps.helper.lsp_config_helper")
		lsp_helper.add_keybinds()
	end,

	on_attach = function(client, bufnr)
		--
		print("Tcl (tcl-lsp-server) LSP attached")
	end,
}

return M
