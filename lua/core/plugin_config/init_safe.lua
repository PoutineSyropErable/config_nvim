require("core.plugin_config.alpha")
require("core.plugin_config.colorscheme")
require("core.plugin_config.coloriser")

require("core.plugin_config.nvimtree_config")
require("core.plugin_config.oil")
require("core.plugin_config.treesitter")
require("core.plugin_config.telescope")
require("core.plugin_config.neoclip")

require("core.plugin_config.mason")
require("core.plugin_config.lsp_config")
require("core.plugin_config.completions")
require("core.plugin_config.conform")
require("core.plugin_config.black")
require("core.plugin_config.nvim-dap-virtual-text")
require("core.plugin_config.nvim-dap-config")
require("core.plugin_config.fugitive")

require("core.plugin_config.toggleterm")
require("core.plugin_config.markview")
require("core.plugin_config.image")

require("core.plugin_config.mini_surround")
require("core.plugin_config.gitsigns")
require("core.plugin_config.tressj")

require("core.plugin_config.swagger-preview")
require("core.plugin_config.vim-test")
require("core.plugin_config.colors-highlight")

local has_bufferline = pcall(require, "bufferline")
local has_barbar = pcall(require, "barbar")
if has_bufferline then
	require("core.plugin_config.bufferline")
end

if has_barbar then
	require("core.plugin_config.barbar")
end

local has_lualine = pcall(require, "lualine")
if has_lualine then
	require("core.plugin_config.lualine")
end

local has_nvsm = pcall(require, "session-manager")
if has_nvsm then
	require("core.plugin_config.nvim-session-manager")
end

-- local has_nvp = pcall(require, "nvim-possession")
-- if has_nvp then
-- 	require("core.plugin_config.nvim-possession")
-- end

------ ##### DEACTIVATED ##### -------

-- not needed vv (hologram) (and markdown_preview)
-- require("core.plugin_config.hologram")
-- require("core.plugin_config.markdown_preview")

-- Completions are in completions.lua, not nvim.cmp
-- require("core.plugin_config.nvim-cmp")

-- require("core.plugin_config.EXTRA_DEBUG")

-- require("core.plugin_config.tabout")
-- require("core.plugin_config.noice")

-- End of file

require("core.plugin_config.last")
