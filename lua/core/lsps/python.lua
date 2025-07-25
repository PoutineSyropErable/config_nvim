local lspconfig = require("lspconfig")

lspconfig.pyright.setup({
	on_attach = function(client, bufnr)
		require("core.plugins_lazy.helper.lsp").add_keybinds(client, bufnr)
		--
	end,
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
