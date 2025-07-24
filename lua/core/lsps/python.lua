local lspconfig = require("lspconfig")

lspconfig.pyright.setup({

	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic", -- Can be "off", "basic", or "strict"
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})
