-- lua/core/lsps/lua.lua
M = {}

M.config = {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
				checkThirdParty = false,
			},
			telemetry = { enable = false },
			hint = {
				enable = true,
				-- arrayIndex = "Disable", -- Makes table.access more visible
			},
		},
	},
	on_attach = function(client, bufnr)
		-- your on_attach logic
		local lsp_helper = require("lsps.helper.lsp_config_helper")
		print("lua lsp attached")
		lsp_helper.add_keybinds()
	end,
}

return M
