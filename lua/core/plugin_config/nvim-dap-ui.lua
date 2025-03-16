-- Add dap configurations based on your language/adapter settings
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
-- dap.configurations.xxxxxxxxxx = {
--   {
--   },
-- }

-- Debugging Support
local dap = require("dap")
local dapui = require("dapui")
dapui.setup({})

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end

local focusOnDapTerminal = function()
	vim.schedule(function()
		-- Get all windows in the current tabpage
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buf_name = vim.api.nvim_buf_get_name(buf)

			-- Ensure buffer name matches a known DAP Terminal format
			if buf_name:lower():match("dap%-terminal") then
				vim.api.nvim_set_current_win(win) -- Set focus to the correct window
				vim.api.nvim_feedkeys("i", "n", false)
				return
			end
		end
	end)
end
local focusOnDapDebugTerminal = function()
	vim.schedule(function()
		-- Get all windows in the current tabpage
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			local buf_name = vim.api.nvim_buf_get_name(buf)

			-- Ensure buffer name matches a known DAP Terminal format
			if buf_name:lower():match("dap%-repl") then
				vim.api.nvim_set_current_win(win) -- Set focus to the correct window
				return
			end
		end
	end)
end

dap.listeners.before.event_initialized["dapui_config"] = function()
	-- Open the dapui
	dapui.open()
	-- focusOnDapTerminal()
	-- focusOnDapDebugTerminal()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	-- Commented to prevent DAP UI from closing when unit tests finish
	-- dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	-- Commented to prevent DAP UI from closing when unit tests finish
	-- dapui.close()
end

vim.api.nvim_create_autocmd("BufWinLeave", {
	pattern = "dap-repl",
	callback = function()
		local dap_repl = require("dap.repl")
		if dap_repl then
			print("[DAP] Closing REPL...")
			pcall(dap_repl.close) -- Ensure it doesn't crash if nil
		end
	end,
})

-- I don't know if bellow is necessary to jump to line where there is error
dap.listeners.after.event_stopped["jump_to_error"] = function(session, body)
	if body.reason == "exception" or body.reason == "error" then
		local frame = body.frame or (body.frames and body.frames[1])
		if frame then
			local bufnr = vim.uri_to_bufnr(vim.uri_from_fname(frame.source.path))
			vim.api.nvim_set_current_buf(bufnr)
			vim.api.nvim_win_set_cursor(0, { frame.line, frame.column })
		end
	end
end

--
