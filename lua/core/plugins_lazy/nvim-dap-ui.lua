-- File: lua/plugins/nvim-dap-ui.lua

return {
	"rcarriga/nvim-dap-ui",
	dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	opts = {},
	lazy = true,

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		-- dapui.setup({})
		dapui.setup({
			layouts = {
				{
					elements = {
						"scopes",
						"breakpoints",
						"stacks",
						"watches",
						-- "repl",  -- 🚫 remove this line
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						"console",
						-- "repl", -- 🚫 no repl in bottom layout either
					},
					size = 10,
					position = "bottom",
				},
			},
		})

		local focusOnDapTerminal = function()
			vim.schedule(function()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local buf_name = vim.api.nvim_buf_get_name(buf)
					if buf_name:lower():match("dap%-terminal") then
						vim.api.nvim_set_current_win(win)
						vim.api.nvim_feedkeys("i", "n", false)
						return
					end
				end
			end)
		end

		local focusOnDapDebugTerminal = function()
			vim.schedule(function()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local buf_name = vim.api.nvim_buf_get_name(buf)
					if buf_name:lower():match("dap%-repl") then
						vim.api.nvim_set_current_win(win)
						return
					end
				end
			end)
		end

		dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end

		dap.listeners.before.event_initialized["dapui_config"] = function()
			dapui.open()
			-- focusOnDapTerminal()
			-- focusOnDapDebugTerminal()
		end

		dap.listeners.before.event_terminated["dapui_config"] = function()
			-- dapui.close()
		end

		dap.listeners.before.event_exited["dapui_config"] = function()
			-- dapui.close()
		end

		vim.api.nvim_create_autocmd("BufWinLeave", {
			pattern = "dap-repl",
			callback = function()
				local dap_repl = require("dap.repl")
				if dap_repl then
					_G.print_custom("[DAP] Closing REPL...")
					pcall(dap_repl.close)
				end
			end,
		})

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
	end,
}
