local nvim_possession = require("nvim-possession")
local bufferline = require("bufferline")

-- Function to get bufferline tab names
local function get_tab_names()
	local names = {}
	for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
		local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "bufferline_name")
		if ok and name then
			names[i] = name
		end
	end
	return names
end

-- Function to restore bufferline tab names
local function restore_tab_names(session_data)
	if session_data and session_data.extra and session_data.extra.bufferline_names then
		for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
			local name = session_data.extra.bufferline_names[i]
			if name then
				vim.api.nvim_tabpage_set_var(tab, "bufferline_name", name)
			end
		end
		bufferline.refresh() -- Ensure bufferline updates
	end
end

nvim_possession.setup({
	sessions = {
		sessions_path = set_session_dir(), -- Store session directory
		sessions_variable = "current_session", -- Track active session
		sessions_icon = "󰀚 ", -- Icon for session names
	},
	autoload = false, -- Disable automatic session loading
	autosave = true, -- Automatically save sessions
	autoswitch = {
		enable = true,
		exclude_ft = { "NvimTree", "neo-tree", "TelescopePrompt" },
	},

	-- ✅ Hook: Save bufferline tab names when saving session
	save_hook = function(session_data)
		session_data.extra = session_data.extra or {}
		session_data.extra.bufferline_names = get_tab_names()
		vim.cmd([[ScopeSaveState]]) -- Save Scope.nvim tab states
	end,

	-- ✅ Hook: Restore bufferline tab names when loading session
	post_hook = function(session_data)
		restore_tab_names(session_data)
		vim.cmd([[ScopeLoadState]]) -- Restore Scope.nvim tab states
	end,

	fzf_hls = {
		normal = "Normal",
		preview_normal = "Normal",
		border = "Todo",
		preview_border = "Constant",
	},
	fzf_winopts = {
		width = 0.5,
		preview = {
			vertical = "right:30%",
		},
	},
	sort = require("nvim-possession.sorting").time_sort,
})
