-- use mason lsp config, or regular lspconfig, to do your language dependant setups
local pre_config = require("_before.pre_config")
local use_mason = pre_config.useMasonLspConfig
local use_lsp_config = not use_mason

return {
	"neovim/nvim-lspconfig",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason.nvim", build = ":MasonUpdate" },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/nvim-cmp",
	},

	config = function()
		require("mason").setup()

		local lspconfig = require("lspconfig")
		require("lspconfig.ui.windows").default_options.border = "rounded"

		local lsp_defaults = lspconfig.util.default_config
		local default_capabilities = lsp_defaults.capabilities
		-- local default_capabilities = vim.lsp.protocol.make_client_capabilities() -- Supposedly equal

		local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
		local merged_capabilities = vim.tbl_deep_extend("force", default_capabilities, cmp_capabilities)

		local function extend_capabilities(lsp_conf)
			-- Enhance default capabilities with cmp capabilities
			lsp_conf.capabilities = merged_capabilities
			return lsp_conf
		end

		local lua_lsp = require("lsps.lua")
		local python_lsp = require("lsps.python")
		local bash_lsp = require("lsps.bash")
		local opencl_lsp = require("lsps.opencl")
		local c_lsp = require("lsps.c")
		local rust_lsp = require("lsps.rust")
		local latex_lsp = require("lsps.latex")

		if use_mason then
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls",
					"solargraph",
					"ts_ls",
					"pyright",
					"clangd",
					"rust_analyzer",
					"texlab",
					"bash-language-server",
				},
				automatic_installation = true, -- or true if you want automatic installs
				-- automatic_enable = { "pyright", "lua_ls", exclude = {} },
				automatic_enable = true,
			})

			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Formatters, linters, debuggers, etc. (non-LSP servers)
					"black",
					"debugpy", -- debugger for python
					"flake8",
					"isort",
					"mypy",
					"pylint",
					"ruff",

					"prettier",
					"clang-format", -- formatter
					-- "clang-tidy",  -- optional (commented)

					-- "chktex",       -- manually compiled, so exclude here

					"latexindent", -- formatter for LaTeX
				},
				run_on_start = true,
				auto_update = false,
				start_delay = 3000,
			})
			vim.lsp.config("lua_ls", extend_capabilities(lua_lsp.config))
			vim.lsp.config("pyright", extend_capabilities(python_lsp.config))
			vim.lsp.config("bashls", extend_capabilities(bash_lsp.config))
			vim.lsp.config("opencl_ls", extend_capabilities(opencl_lsp.config))
			vim.lsp.config("clangd", extend_capabilities(c_lsp.config))
			vim.lsp.config("rust_analyzer", extend_capabilities(rust_lsp.config))
			vim.lsp.config("texlab", extend_capabilities(latex_lsp.config))
		end

		-- This
		if use_lsp_config then
			lsp_defaults.capabilities = merged_capabilities

			lspconfig.lua_ls.setup(lua_lsp.config)
			lspconfig.pyright.setup(python_lsp.config)
			lspconfig.bashls.setup(bash_lsp.config)
			lspconfig.opencl_ls.setup(opencl_lsp.config)
			lspconfig.clangd.setup(c_lsp.config)
			lspconfig.rust_analyzer.setup(rust_lsp.config)
			lspconfig.texlab.setup(latex_lsp.config)

			lspconfig.solargraph.setup({})
			lspconfig.ts_ls.setup({})
			lspconfig.gopls.setup({})
			lspconfig.tailwindcss.setup({})
		end

		vim.diagnostic.config({
			virtual_text = {
				spacing = 4,
				prefix = "■", -- or "■", or "" for no symbol
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})
	end,
}
