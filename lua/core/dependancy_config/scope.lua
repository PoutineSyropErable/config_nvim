local M = {}

local function nohup() end

function M.setup()
	require("scope").setup({
		hooks = {
			pre_tab_leave = function()
				vim.api.nvim_exec_autocmds("User", { pattern = "ScopeTabLeavePre" })
				-- other statements or leave empty
			end,
			post_tab_enter = function()
				vim.api.nvim_exec_autocmds("User", { pattern = "ScopeTabEnterPost" })
				-- other statements or leave empty
			end,
			pre_tab_enter = nohup,
			post_tab_enter = nohup,
			pre_tab_close = nohup,
			post_tab_close = nohup,
			-- Add any other hooks you want here
		},
		-- Add other options here if needed
	})

	noti
end

return M
