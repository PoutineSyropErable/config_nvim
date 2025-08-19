local hb = "core.plugins_lazy.helper.barbar"
-- helper barbar

return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- optional: for git status
		"nvim-tree/nvim-web-devicons", -- optional: for file icons
		-- "echasnovski/mini.bufremove", -- is loaded by doing a bufferclose. in helper
	},
	-- event = { "BufReadPre", "BufNewFile" }, -- Lazy-load at buffer read or new
	event = { "BufReadPre", "BufNewFile", "User PossessionSessionLoaded" }, -- Lazy-load at buffer read or new
	keys = {
		{
			"<leader>q",
			function() require(hb).close_buffer_or_tab() end,
			desc = "Close current buffer (And Tab if Empty)",
		},
		{
			"<leader>X",
			function() require(hb).force_close_buffer() end,
			desc = "Close Current Buffer (Only)",
		},
	},
	init = function()
		vim.g.barbar_auto_setup = false -- disable auto-setup so we can customize manually
	end,
	config = function()
		local barbar = require("barbar")
		barbar.setup({
			animation = true,
			insert_at_end = true,
			closable = true,
			highlight_alternate = true,
			highlight_inactive_file_icons = true,
			highlight_visible = true,
			icons = {
				buffer_index = true,
				buffer_close = "",
				modified = { button = "●" },
				button = "",
				preset = "default",
				separator_at_end = false,
				diagnostics = {
					[vim.diagnostic.severity.ERROR] = { enabled = true, icon = "" },
					[vim.diagnostic.severity.WARN] = { enabled = true, icon = "" },
					[vim.diagnostic.severity.INFO] = { enabled = true, icon = "" },
					[vim.diagnostic.severity.HINT] = { enabled = true, icon = "" },
				},
			},
			maximum_padding = 0,
			minimum_padding = 1,
			maximum_length = 30,
			minimum_length = 0,
			filter = function(buf, _) return vim.bo[buf].buftype ~= "terminal" end,
			sidebar_filetypes = {
				NvimTree = { text = "File Explorer", align = "center" },
				undotree = { text = "Undo History", align = "center" },
			},
			auto_hide = false,
		})

		-- Custom highlight groups
		local cp = require("catppuccin.palettes").get_palette()
		local gray = cp.subtext1
		local green = "#A6E3A2"

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
			"BufferCurrentTarget",
			"BufferCurrentNumber",
		}
		for _, group in ipairs(current_groups) do
			vim.api.nvim_set_hl(0, group, { underline = true })
		end

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

		vim.api.nvim_set_hl(0, "BufferCurrentMod", { fg = green })
		vim.api.nvim_set_hl(0, "BufferVisibleMod", { fg = green })
		vim.api.nvim_set_hl(0, "BufferInactiveMod", { fg = green })

		-- Barbar keymaps
		local keymap = vim.keymap.set
		local opts = function(desc) return { noremap = true, silent = true, desc = desc } end

		keymap("n", "<C-n>", "<Cmd>BufferNext<CR>", opts("Next buffer (Barbar)"))
		keymap("n", "<C-b>", "<Cmd>BufferPrevious<CR>", opts("Previous buffer (Barbar)"))
		keymap("n", "<leader>B", "<Cmd>BufferMovePrevious<CR>", opts("Move buffer left (Barbar)"))
		keymap("n", "<leader>N", "<Cmd>BufferMoveNext<CR>", opts("Move buffer right (Barbar)"))

		local bh = require(hb)

		for i = 1, 9 do
			keymap("n", "<leader>" .. i, function() bh.goto_buffer(i) end, opts("Go to buffer " .. i))
		end

		keymap("n", "<leader>0", function() bh.goto_buffer(10) end, opts("Go to buffer 10"))

		-- keys, keybinds, keymaps, keyboard shortcut --
	end,
}
