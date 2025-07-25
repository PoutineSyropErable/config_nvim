local lspconfig = require("lspconfig")
local gu = require("_before.general_utils")

lspconfig.lua_ls.setup({
	on_attach = function(client, bufnr)
		gu.print_custom("attached")
		require("core.plugins_lazy.helper.lsp").add_keybinds(client, bufnr)

		--
	end,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})
