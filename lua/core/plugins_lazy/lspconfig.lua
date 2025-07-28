-- use mason lsp config, or regular lspconfig, to do your language dependant setups
local pre_config = require("_before.pre_config")
local use_mason = pre_config.useMasonLspConfig

if use_mason then
	return {}
end

local hl = "core.plugins_lazy.helper.lsp_keybind"
return {
	"neovim/nvim-lspconfig",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason.nvim", build = ":MasonUpdate" },
		"hrsh7th/nvim-cmp",
	},

	config = function()
		require("mason").setup()

		local lsp_config = require("lspconfig")
		require("lspconfig.ui.windows").default_options.border = "rounded"

		local lspconfig = require("lspconfig")
		local lsp_defaults = lspconfig.util.default_config

		local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
		local default_capabilities = vim.lsp.protocol.make_client_capabilities()
		local merged_capabilities = vim.tbl_deep_extend("force", default_capabilities, cmp_capabilities)
		lsp_defaults.capabilities = merged_capabilities

		local function extend_capabilities(lsp_conf)
			lsp_conf.capabilities = merged_capabilities
			return lsp_conf
		end

		local lua_lsp = require("lsps.lua")
		local python_lsp = require("lsps.python")
		-- Enhance default capabilities with cmp capabilities

		-- This integrates well with mason lspconfig
		lspconfig.pyright.setup(extend_capabilities(python_lsp.config))
		lspconfig.lua_ls.setup(extend_capabilities(lua_lsp.config))
	end,
}
