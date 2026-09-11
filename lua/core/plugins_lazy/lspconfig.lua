-- use mason lsp config, or regular lspconfig, to do your language dependant setups
local pre_config = require("_before.pre_config")
local use_mason = pre_config.useMasonLspConfig
local use_lsp_config = pre_config.useRegularLspConfig
local use_merged = pre_config.useMergedLspConfig
local ggu = function() return require("_before.general_utils") end

return {
	"neovim/nvim-lspconfig",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason.nvim" },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
	},

	config = function()
		require("mason").setup()

		local lspconfig = require("lspconfig")
		local configs = require("lspconfig.configs")
		local util = require("lspconfig.util")
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

		local asm_lsp = require("lsps.asm")
		local c_lsp = require("lsps.c")
		local ccls = require("lsps.ccls")
		local opencl_lsp = require("lsps.opencl")
		local zig_lsp = require("lsps.zig")
		local rust_lsp = require("lsps.rust")

		local latex_lsp = require("lsps.latex")
		local go_lsp = require("lsps.go")

		local iverilog_lsp = require("lsps.verilog")
		local vhdl_lsp = require("lsps.vhdl")
		local tcl_lsp = require("lsps.tcl")

		if use_mason then
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls",
					"pyright",

					"clangd",
					"zls",
					"rust_analyzer",

					"gopls",

					"texlab",
					"solargraph",
					"ts_ls",
					"svls",
				},
				automatic_installation = true, -- or true if you want automatic installs
				-- automatic_enable = { "pyright", "lua_ls", exclude = {} },
				-- automatic_enable = { "clangd" },
				automatic_enable = false,
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
					"vsg",
				},
				run_on_start = true,
				auto_update = false,
				start_delay = 3000,
			})
			vim.lsp.config("lua_ls", extend_capabilities(lua_lsp.config))
			vim.lsp.config("lua_ls", extend_capabilities(lua_lsp.config))
			vim.lsp.config("pyright", extend_capabilities(python_lsp.config))

			vim.lsp.config("svls", extend_capabilities(iverilog_lsp.config))

			-- clangd, rust and asm should be moved here
			vim.lsp.config("zls", extend_capabilities(zig_lsp.config))

			vim.lsp.config("gopls", extend_capabilities({}))

			vim.lsp.enable({ "lua_ls", "pyright", "zls", "gopls" })

			-- It seems the others don't quite works if i set them up like that
			local they_work = false
			if they_work then
				vim.lsp.config("bashls", extend_capabilities(bash_lsp.config))

				vim.lsp.config("asm_lsp", extend_capabilities(asm_lsp.config))

				-- Pick one or the other
				vim.lsp.config("clangd", extend_capabilities(c_lsp.config))
				vim.lsp.config("ccls", extend_capabilities(ccls.config))

				vim.lsp.config("opencl_ls", extend_capabilities(opencl_lsp.config))
				vim.lsp.config("rust_analyzer", extend_capabilities(rust_lsp.config))

				vim.lsp.config("texlab", extend_capabilities(latex_lsp.config))

				vim.lsp.config("vhdl_ls", extend_capabilities(vhdl_lsp.config))
				vim.lsp.config("tcl_ls", extend_capabilities(tcl_lsp.config))

				vim.lsp.enable({ "bashls", "asm_lsp", "clangd", "opencl_ls", "rust_analyzer", "texlab" })
				vim.lsp.enable("ccls")
			end
		end

		if use_lsp_config then
			local clangd_defaults = lspconfig.clangd.document_config.default_config
			-- ^ Due to black magic, this call is necessary. It has side effects,
			-- and force the initialisation of the default clangd
			lsp_defaults.capabilities = merged_capabilities

			-- double setups of lua ls and pyright? (since use mason and the other are auto setups)
			-- lspconfig.lua_ls.setup(lua_lsp.config) -- already configured by native
			-- lspconfig.pyright.setup(python_lsp.config) -- already configured by native
			lspconfig.bashls.setup(bash_lsp.config)

			lspconfig.asm_lsp.setup(asm_lsp.config)

			if pre_config.clangdNotCCLS then
				lspconfig.clangd.setup(c_lsp.config)
			else
				lspconfig.ccls.setup(ccls.config)
			end

			lspconfig.opencl_ls.setup(opencl_lsp.config)
			lspconfig.zls.setup(zig_lsp.config) -- already configured by native
			lspconfig.rust_analyzer.setup(rust_lsp.config)

			-- lspconfig.opencl_language_server.setup() -- wrong name?

			lspconfig.texlab.setup(latex_lsp.config)
			lspconfig.solargraph.setup({})
			lspconfig.ts_ls.setup({})
			lspconfig.gopls.setup({})
			lspconfig.tailwindcss.setup({})

			lspconfig.svls.setup(iverilog_lsp.config)

			lspconfig.vhdl_ls.setup(vhdl_lsp.config)

			if not configs.tcl_lsp then
				configs.tcl_lsp = {
					default_config = tcl_lsp.config,
				}
			end
			lspconfig.tcl_lsp.setup({})

			-- end of if statement
		end

		if use_merged then
			-- not coded yet
			-- I'll just use both the other way
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

		local lsp_helper = require("lsps.helper.lsp_config_helper")
		--
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					ggu().print_custom("Warning: LSP client not found for LspAttach event")
					return
				end
				if client.name == "clangd" then
					ggu().print_custom("C LSP attached")
					lsp_helper.add_keybinds(client, args.buf)
				end
			end,
		})

		vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to :checkhealth vim.lsp" })
		vim.api.nvim_create_user_command("LspLog", function()
			local log_path = vim.lsp.log.get_filename() -- This is the new, non-deprecated function
			if log_path and vim.fn.filereadable(log_path) == 1 then
				vim.cmd("edit " .. log_path)
			else
				vim.notify("LSP log file not found", vim.log.levels.WARN)
			end
		end, { desc = "Open LSP log file" })

		-- End of config
	end,
}
