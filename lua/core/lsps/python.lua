-- lua/core/lsps/pyright.lua
return {
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
		local lsp_helper = require("core.plugins_lazy.helper.lsp")
		lsp_helper.add_keybinds()
	end,
}
