
require("lazy").setup({
  -- Load all plugin specs from plugins/ directory
    require("core.lsp_config"),
  { import = "core.plugins" },

  -- Load any optional plugin specs from custom/plugins/
  -- { import = "custom.plugins" },
})
