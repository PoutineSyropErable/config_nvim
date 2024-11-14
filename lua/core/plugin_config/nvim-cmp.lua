local cmp = require'cmp'
cmp.setup {
  sources = {
    { name = 'path' },   -- Enable file path completion
    { name = 'buffer' }, -- Other sources
  },
  mapping = {
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<Enter>'] = cmp.mapping.confirm({ select = true }),
  }
}
