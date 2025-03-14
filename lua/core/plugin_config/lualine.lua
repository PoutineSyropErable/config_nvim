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

local function get_tab_name(tabnr)
	local ok, name = pcall(vim.api.nvim_tabpage_get_var, tabnr, "name")
	return ok and name or tabnr -- Fallback if name is missing
end

local function get_all_tab_names()
	local tab_names = {}
	local current_tab = vim.api.nvim_get_current_tabpage() -- Get the current tab page

	-- Get all tab pages using nvim_list_tabpages
	for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
		local name = get_tab_name(tabnr)
		-- If this is the current tab, apply bold styling or special character
		if tabnr == current_tab then
			name = "(" .. name .. ")" -- Add a special symbol for current tab
		end
		table.insert(tab_names, name)
	end

	-- Join all tab names into a string, separated by " | " and return it
	return table.concat(tab_names, " | ")
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
			{ "tabs", mode = 3 }, -- Show buffer names in the tabline
		},
		-- lualine_c = { get_all_tab_names },
		lualine_x = { getMacro, "encoding", "fileformat", "filetype" },
		lualine_y = { "progress", getTime },
		lualine_z = { "location" },
	},
})

vim.keymap.set("n", "<F12>", get_all_tab_names, { desc = "get tab names" })
