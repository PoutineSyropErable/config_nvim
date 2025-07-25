local hl = "core.plugins_lazy.helper.lsp"
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "williamboman/mason.nvim", build = ":MasonUpdate" },
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		-- "j-hui/fidget.nvim",
	},

	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup()

		require("lspconfig.ui.windows").default_options.border = "rounded"

		local cmp = require("cmp")
		local luasnip = require("luasnip")

		-- Register your custom bash source here:
		cmp.register_source("bash", {
			complete = function(self, params, callback)
				local handle = io.popen('bash -c "compgen -c"')
				if handle then
					local result = handle:read("*a")
					handle:close()
					local items = {}
					for cmd in string.gmatch(result, "[^\n]+") do
						table.insert(items, { label = cmd })
					end
					callback({ items = items, isIncomplete = false })
				else
					callback({ items = {}, isIncomplete = true })
				end
			end,
		})

		cmp.setup({
			snippet = {
				expand = function(args) luasnip.lsp_expand(args.body) end,
			},
			mapping = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
				{ name = "bash" },
			}),
			formatting = {
				format = function(entry, vim_item)
					-- Custom formatting for LSP items
					if entry.source.name == "nvim_lsp" then
						local documentation = entry:get_completion_item().documentation
						if documentation then
							vim_item.documentation = documentation
						end

						vim_item.kind = string.format("%s %s", vim_item.kind, entry:get_completion_item().label)
					end

					-- Add a custom menu label for each source
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						buffer = "[Buffer]",
						path = "[Path]",
						bash = "[Bash]",
					})[entry.source.name]

					return vim_item
				end,
			},
		})

		-- Helper function to set up cmdline completion for specific command types
		local function setup_cmdline(type, sources)
			cmp.setup.cmdline(type, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = sources,

				enabled = function()
					local cmdline = vim.fn.getcmdline()
					if type == ":" then
						-- Only enable bash source if cmd starts with !
						if cmdline:sub(1, 1) == "!" then
							return true
						end
						-- Otherwise enable other sources normally
						-- To allow buffer/path/cmdline for normal commands, return true
						-- but your sources setup will not include bash in those cases
						return true
					elseif type == "/" then
						return true
					else
						return false
					end
				end,
			})
		end

		-- Setup cmdline completion for `/` (search) and `:` (command)
		setup_cmdline("/", {
			{ name = "buffer" },
		})
		setup_cmdline(":", {
			{ name = "path" },
			{ name = "cmdline" },
			{ name = "bash" },
		})

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

		-- Autoload language LSPs
		require("core.lsps")
	end,
}
