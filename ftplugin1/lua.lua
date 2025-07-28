-- ftplugin/lua.lua
local lspconfig = require("lspconfig")
local client_name = "lua_ls"
local gu = require("_before.general_utils")

if not vim.b.lua_lsp_attached then
	gu.print_custom("not attached")
	vim.b.lua_lsp_attached = true

	if not vim.g.lua_ls_setup then
		gu.print_custom("setting up")
		local lua_config = require("lsps.lua")
		lspconfig.lua_ls.setup(lua_config)
		vim.g.lua_ls_setup = true
	end

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

	print_custom("bufnr = " .. vim.inspect(bufnr))
	print_custom("client = " .. vim.inspect(client_id))

	local attached = false
	if client_id then
		attached = vim.lsp.buf_is_attached(bufnr, client_id)
	end

	print_custom("\nEnd of call\n")
end
