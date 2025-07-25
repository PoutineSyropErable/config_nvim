-- ftplugin/lua.lua
local lspconfig = require("lspconfig")
local client_name = "lua_ls"

if not vim.b.lua_lsp_attached then
	vim.b.lua_lsp_attached = true

	lspconfig.lua_ls.setup({
		on_attach = function(client, bufnr) require("core.plugins_lazy.helper.lsp").add_keybinds(client, bufnr) end,
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

	-- 🔧 Manually attach if this buffer wasn't already attached
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients()
	local client_id = nil

	for _, client in ipairs(clients) do
		if client.name == client_name then
			client_id = client.id
			break
		end
	end

	local attached = false
	if client_id then
		attached = vim.lsp.buf_is_attached(bufnr, client_id)
	end
end
