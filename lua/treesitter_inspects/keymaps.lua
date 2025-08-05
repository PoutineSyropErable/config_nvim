-- lua/treesitter_inspect/keymaps.lua
local inspect = require("treesitter_inspect")

local function setup()
	vim.keymap.set("n", "<leader>pn", inspect.print_current_node, { desc = "Print current node" })
	vim.keymap.set("n", "<leader>if", inspect.print_node_family, { desc = "Inspect node family" })
	vim.keymap.set("n", "<leader>i2", inspect.print_depth_two, { desc = "Inspect node + children" })
end

return {
	setup = setup,
}
