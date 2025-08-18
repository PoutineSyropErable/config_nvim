local barbar = require("barbar")

barbar.setup({
	animation = true,
	insert_at_end = true,
	closable = true,

	-- Disable highlighting alternate buffers
	highlight_alternate = true,
	-- Disable highlighting file icons in inactive buffers
	highlight_inactive_file_icons = true,
	-- Enable highlighting visible buffers
	highlight_visible = true,
	icons = {
		-- buffer_number = true,
		buffer_index = true,
		buffer_close = "",
		modified = { button = "●" },
		button = "",
		preset = "default",

		-- separator = { left = "|", right = "" },
		separator_at_end = false,
		diagnostics = {
			[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "" },
			[vim.diagnostic.severity.WARN] = { enabled = true, icon = "" },
			[vim.diagnostic.severity.INFO] = { enabled = true, icon = "" },
			[vim.diagnostic.severity.HINT] = { enabled = true, icon = "" },
		},
	},

	-- Sets the maximum padding width with which to surround each tab
	maximum_padding = 0,
	-- Sets the minimum padding width with which to surround each tab
	minimum_padding = 1,
	-- Sets the maximum buffer name length.
	maximum_length = 30,
	-- Sets the minimum buffer name length.
	minimum_length = 0,
	filter = function(buf, _) return vim.bo[buf].buftype ~= "terminal" end,
	sidebar_filetypes = {
		NvimTree = { text = "File Explorer", align = "center" },
		undotree = { text = "Undo History", align = "center" },
	},
	auto_hide = false,
})

-- vim.cmd([[
--   hi BufferLineFill guibg=NONE ctermbg=NONE
--   hi BufferLineBackground guibg=NONE ctermbg=NONE
-- ]])

-- ===============

local current_groups = {
	"BufferCurrent",
	"BufferCurrentIndex",
	"BufferCurrentMod",
	"BufferCurrentSign",
	"BufferCurrentSignRight",
	"BufferCurrentSignLeft",
	"BufferCurrentBtn",
	"BufferCurrentPin",
	"BufferCurrentIcon",
	"BufferCurrentINFO",
	-- "BufferCurrentHINT",
	-- "BufferCurrentWARN",
	-- "BufferCurrentERROR",
	"BufferCurrentTarget",
	"BufferCurrentNumber",
}

local highlights = require("barbar.highlight")

for _, group in ipairs(current_groups) do
	vim.api.nvim_set_hl(0, group, { underline = true })
end

-- "$HOME/.config/nvim/lua/core/plugin_config/catpuccin_helper.css"
local cp = require("catppuccin.palettes").get_palette() -- defaults to current flavor
local white = cp.overlay0
local mix = cp.text
local gray = cp.subtext1

local gr = "#6c7087"
local mx = "#9399b3"
local wh = "#cdd6f5"

local fg_hint = "#94E2D6"
local fg_saphire = "#74c7ec"
local green = "#A6E3A2"

vim.api.nvim_set_hl(0, "BufferCurrent", { bg = "none", underline = true, bold = true, fg = cp.sky })

local statuses = { "Inactive", "Visible", "Alternate" }
local parts = {
	"",
	"ADDED",
	"Btn",
	"CHANGED",
	"DELETED",
	"ERROR",
	"HINT",
	"Icon",
	"Index",
	"INFO",
	"Mod",
	"ModBtn",
	"Number",
	"Pin",
	"PinBtn",
	"Sign",
	"SignRight",
	"Target",
	"WARN",
}

for _, status in ipairs(statuses) do
	for _, part in ipairs(parts) do
		local group = "Buffer" .. status .. part
		vim.api.nvim_set_hl(0, group, { bg = "none", fg = gray })
	end
end

-- vim.api.nvim_set_hl(0, "BufferCurrentMod", { fg = green })
-- vim.api.nvim_set_hl(0, "BufferVisibleMod", { fg = green })
-- vim.api.nvim_set_hl(0, "BufferInactiveMod", { fg = green })
