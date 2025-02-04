-- Debugging Support
require("dapui").setup({})

-- Add event listeners for DAP UI
local dap = require("dap")

dap.listeners.after.event_initialized["dapui_config"] = function()
	require("dapui").open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
	-- Commented to prevent DAP UI from closing when unit tests finish
	-- require('dapui').close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	-- Commented to prevent DAP UI from closing when unit tests finish
	-- require('dapui').close()
end

-- Add dap configurations based on your language/adapter settings
-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
-- dap.configurations.xxxxxxxxxx = {
--   {
--   },
-- }

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
