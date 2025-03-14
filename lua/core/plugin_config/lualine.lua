local getMacro = function()
	-- Check if a macro is being recorded and show the register
	if vim.fn.reg_recording() ~= "" then
		return "Recording  @" .. vim.fn.reg_recording()
	else
		return ""
	end
end

local getTime = function()
	-- Show the current time formatted as "HH:MM"
	return os.date("%Hh:%Mm")
end

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "nightfly",
		component_separators = { left = "", right = "" }, -- Separators between components
		section_separators = { left = "", right = "" }, -- Separators between sections
	},
	sections = {
		lualine_a = {
			{
				"filename",
				path = 1,
			},
		},
		-- lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = {
			{ "tabs", mode = 1 }, -- Show buffer names in the tabline
		},
		lualine_x = { getMacro, "encoding", "fileformat", "filetype" },
		lualine_y = { "progress", getTime },
		lualine_z = { "location" },
	},
})
