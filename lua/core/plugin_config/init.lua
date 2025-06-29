require("core.plugin_config.alpha")
require("core.plugin_config.colorscheme")
require("core.plugin_config.coloriser")

require("core.plugin_config.nvimtree_config")
require("core.plugin_config.oil")
require("core.plugin_config.treesitter")
require("core.plugin_config.telescope")
require("core.plugin_config.neoclip")
require("core.plugin_config.terminal_file_manager")

if PRE_CONFIG_FRANCK.useNvimJava then
	require("core.plugin_config.nvim-java")
end
require("core.plugin_config.lsp_config")
require("core.plugin_config.lsp_config_helper")
require("core.plugin_config.completions")
require("core.plugin_config.conform")
require("core.plugin_config.black")

require("core.plugin_config.nvim-dap-config")
require("core.plugin_config.nvim-dap-virtual-text")
require("core.plugin_config.nvim-dap-ui")

if PRE_CONFIG_FRANCK.useNvimJdtls then
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "java",
		callback = function() require("core.plugin_config.nvim-jdtls") end,
	})
end

require("core.plugin_config.fugitive")
require("core.plugin_config.undotree")
require("core.plugin_config.pathfinder")
require("core.plugin_config.toggleterm")
require("core.plugin_config.markview")
require("core.plugin_config.image")

require("core.plugin_config.mini_surround")
require("core.plugin_config.gitsigns")
require("core.plugin_config.tressj")

require("core.plugin_config.vim-test")
require("core.plugin_config.colors-highlight")

require("core.plugin_config.lualine")
require("core.plugin_config.bufferline")
-- require("core.plugin_config.barbar")

require("core.plugin_config.nvim-possession")
require("core.plugin_config.nvim-ufo")
require("core.plugin_config.color_picker_ccc")

------ ##### DEACTIVATED ##### -------

-- not needed vv (hologram) (and markdown_preview)
-- require("core.plugin_config.hologram")
-- require("core.plugin_config.markdown_preview")

-- Completions are in completions.lua, not nvim.cmp
-- require("core.plugin_config.nvim-cmp")

-- require("core.plugin_config.EXTRA_DEBUG")

-- require("core.plugin_config.tabout")

-- End of file
