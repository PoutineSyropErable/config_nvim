-- use mason lsp config, or regular lspconfig, to do your language dependant setups
local pre_config = require("_before.pre_config")
local use_lsp_config = not pre_config.useMasonLspConfig

if use_lsp_config then
	return {}
end

print("it got here")

return {
	"williamboman/mason-lspconfig.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason.nvim", build = ":MasonUpdate" },
		"hrsh7th/nvim-cmp",
	},

	config = function()
		require("mason").setup()
		-- require("lspconfig")

		local mason_lspconfig = require("mason-lspconfig")
		mason_lspconfig.setup({
			ensure_installed = {},
			-- automatic_enable = { "pyright", exclude = { "lua_ls" } },
		})

		local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
		local default_capabilities = vim.lsp.protocol.make_client_capabilities()
		local merged_capabilities = vim.tbl_deep_extend("force", default_capabilities, cmp_capabilities)

		-- Enhance default capabilities with cmp capabilities
		local function extend_capabilities(lsp_conf)
			lsp_conf.capabilities = merged_capabilities
			return lsp_conf
		end

		local lua_lsp = require("lsps.lua")
		local python_lsp = require("lsps.python")

		-- This integrates well with mason lspconfig
		vim.lsp.config("lua_ls", extend_capabilities(lua_lsp.config))
		vim.lsp.config("pyright", extend_capabilities(python_lsp.config))
	end,
}
