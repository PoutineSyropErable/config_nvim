local M = {}

M.use_bufferline = false
M.useJavaLspConfig = false
M.useMyJavaDap = true

M.useMasonLspConfig = true -- masonlspconfig, or regular lspconfig
M.useRegularLspConfig = true -- lspconfig
M.useMergedLspConfig = false

M.use_git_confict = true
-- etc.

-- Function to print the current config state
function M.print_config()
	print("=== Current Pro Config ===")
	for k, v in pairs(M) do
		if type(v) ~= "function" then
			print(string.format("%s = %s", k, tostring(v)))
		end
	end
	print("==========================")
end

-- Create a user command to print the config state
vim.api.nvim_create_user_command("PreConfigState", function() M.print_config() end, {})

return M
