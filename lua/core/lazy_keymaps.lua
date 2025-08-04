-- Set the leader key if not already set
local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

-- keymap.set("n", "gf", function() require("pathfinder").gf() end, opts("Enhanced go to file"))
-- keymap.set("n", "gF", function() require("pathfinder").gF() end, opts("Enhanced Go to file with line"))
-- keymap.set("n", "gx", function() require("pathfinder").gx() end, opts("Enhanced Go to file with line"))
