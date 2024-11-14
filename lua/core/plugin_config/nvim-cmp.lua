local cmp = require("cmp")
cmp.setup({
	sources = {
		{ name = "path" }, -- Enable file path completion
		{ name = "buffer" }, -- Other sources
	},
	mapping = {
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<Enter>"] = cmp.mapping.confirm({ select = true }),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
	},
})
