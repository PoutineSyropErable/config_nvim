local pathfinder = require("pathfinder")

-- "$HOME/some file with space.txt"
-- "/home/francois/some file with space2.txt"

pathfinder.setup({
	-- line
	remap_default_keys = false, -- Disable plugin's default key mappings
	-- includeexpr = "substitute(v:fname, '\\$\\\\([^)]*\\\\)', '\\\\=expand(\\\\1)', 'g')",
})
