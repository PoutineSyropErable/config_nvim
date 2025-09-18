-- Store current state
local current_comment = ";" -- default to NASM style

-- Function to toggle ASM comment character
function ToggleAsmComment()
	-- Determine the new comment character
	if current_comment == ";" then
		current_comment = "#"
	else
		current_comment = ";"
	end

	-- Make sure Comment.nvim is loaded
	local ft = require("Comment.ft")
	-- Apply to ASM filetypes
	ft.set("asm", current_comment .. "%s")
	ft.set("s", current_comment .. "%s")
	ft.set("S", current_comment .. "%s")

	print("ASM comment character set to: " .. current_comment)
end

return {
	"numToStr/Comment.nvim",
	lazy = true,
	keys = {
		"gcc", -- line comment toggle (normal mode)
		"gbc", -- block comment toggle (normal mode)
		"gc", -- operator pending line comment (normal + visual)
		"gb", -- operator pending block comment (normal + visual)
		"gco", -- add comment line below (normal mode)
		"gcO", -- add comment line above (normal mode)
		"gcA", -- add comment at end of line (normal mode)
	},
	config = function()
		require("Comment").setup()

		x = 5

		local ft = require("Comment.ft")
		-- For NASM/GAS style assembly, line comment is `;`
		ft.set("asm", ";%s")

		vim.keymap.set("n", "<leader>.a", ToggleAsmComment, { desc = "Toggle Asm comment from ; to #" })
	end,
}
