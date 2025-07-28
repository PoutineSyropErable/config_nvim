-- lua/core/lsps/lua.lua
M = {}

M.config = {
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
	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		lsp_helper.add_keybinds()
	end,
}

return M
