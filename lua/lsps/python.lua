-- lua/core/lsps/pyright.lua
M = {}

M.config = {
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("python lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M
