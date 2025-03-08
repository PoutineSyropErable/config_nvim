-- ~/.config/nvim/lua/plugin_config/alpha.lua
local alpha = require("alpha")
local startify = require("alpha.themes.startify")

-- Set file icon provider to 'devicons'
startify.file_icons.provider = "devicons"

-- Configure alpha with startify theme
alpha.setup(startify.config)
