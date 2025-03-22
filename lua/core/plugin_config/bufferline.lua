vim.opt.termguicolors = true
local bufremove = require("mini.bufremove") -- Load once

local bufferline = require("bufferline")

bufferline.setup({
	options = {
		mode = "buffers", -- "tabs" to show only tabs
		-- hover = {
		-- 	enabled = true,
		-- 	delay = 200,
		-- 	reveal = { "close" },
		-- },
		show_buffer_close_icons = true, -- Hide close icons by defaul

		numbers = "ordinal", -- Show buffer numbers
		close_command = function(bufnum) bufremove.delete(bufnum, false) end,
		right_mouse_command = function(bufnum) bufremove.delete(bufnum, false) end,
		left_mouse_command = "buffer %d", -- Switch buffer on click
		middle_mouse_command = nil, -- No middle-click behavior
		indicator = { style = "underline" }, -- Style for active buffer indicator
		buffer_close_icon = "", -- Icon for closing buffer
		modified_icon = "●", -- Icon for unsaved changes
		close_icon = "", -- Icon for closing all buffers
		left_trunc_marker = "", -- Indicator for left truncation
		right_trunc_marker = "", -- Indicator for right truncation
		separator_style = "thin", -- Options: "slant", "thick", "thin"
		diagnostics = "nvim_lsp", -- Show LSP errors/warnings in buffers
		diagnostics_indicator = function(count, level, diagnostics_dict, context)
			local s = " "
			for e, n in pairs(diagnostics_dict) do
				local sym = e == "error" and " " or (e == "warning" and " " or " ")
				s = s .. n .. sym
			end
			return s
		end,
		custom_filter = function(buf_number, _)
			-- Hide terminal buffers from appearing in bufferline
			if vim.bo[buf_number].buftype ~= "terminal" then
				return true
			end
		end,
		always_show_bufferline = true, -- Always show even with 1 buffer
		sort_by = "insert_at_end", -- Buffer sorting method
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				highlight = "Directory",
				text_align = "center",
				separator = true, -- Show a separator between nvim-tree and buffers
				padding = 0, -- Space between the file tree and bufferline
			},
			{
				filetype = "undotree",
				text = "Undo History",
				highlight = "Function",
				text_align = "center",
				separator = true,
				padding = 0,
			},
		},
	},
})
