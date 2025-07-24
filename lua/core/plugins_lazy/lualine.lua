return {
	"nvim-lualine/lualine.nvim",
	lazy = true,
	event = "VeryLazy", -- or "BufReadPost", adjust as needed
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local getMacro = function()
			if vim.fn.reg_recording() ~= "" then
				return "Recording  @" .. vim.fn.reg_recording()
			else
				return ""
			end
		end

		local getTime = function() return os.date("%Hh:%Mm") end

		local function get_tab_name(tabnr)
			local ok, name = pcall(vim.api.nvim_tabpage_get_var, tabnr, "name")
			return ok and name or tostring(tabnr)
		end

		local function get_all_tab_names()
			local tab_names = {}
			local current_tab = vim.api.nvim_get_current_tabpage()
			for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
				local name = get_tab_name(tabnr)
				if tabnr == current_tab then
					name = "(" .. name .. ")"
				end
				table.insert(tab_names, name)
			end
			return table.concat(tab_names, " | ")
		end

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "nightfly",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { { "filename", path = 1 } },
				-- lualine_a = { "mode" }, -- alternative if you want mode here
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "tabs", mode = 3 } }, -- or use get_all_tab_names here if preferred
				lualine_x = { getMacro, "encoding", "fileformat", "filetype" },
				lualine_y = { "progress", getTime },
				lualine_z = { "location" },
			},
		})

		vim.keymap.set(
			"n",
			"<leader>pn",
			function() vim.notify(get_all_tab_names(), vim.log.levels.INFO, { title = "Tab Names" }) end,
			{ desc = "Show all tab names" }
		)
	end,
}
