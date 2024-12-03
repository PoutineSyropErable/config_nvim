local cmp = require("cmp")

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
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
			})[entry.source.name]

			return vim_item
		end,
	},
})

-- Cmdline setup function
local function setup_cmdline(type, sources)
	cmp.setup.cmdline(type, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = sources,
	})
end

-- `/` cmdline setup
setup_cmdline("/", {
	{ name = "buffer" },
})

-- `:` cmdline setup
setup_cmdline(":", {
	{ name = "path" },
	{ name = "cmdline" },
})

-- Custom source for Bash commands
cmp.register_source("bash", {
	complete = function(_, callback)
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
