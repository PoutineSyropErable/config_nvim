-- Ensure PRE_CONFIG_FRANCK exists
_G.PRE_CONFIG_FRANCK = {}
PRE_CONFIG_FRANCK.use_bufferline = true

-- Java
PRE_CONFIG_FRANCK.useJavaLspConfig = true
PRE_CONFIG_FRANCK.useMyJavaDap = true
PRE_CONFIG_FRANCK.useNvimJdtls = false
PRE_CONFIG_FRANCK.useNvimJava = false

PRE_CONFIG_FRANCK.jdtls = PRE_CONFIG_FRANCK.useNvimJdtls
		and {
			"mfussenegger/nvim-jdtls",
			dependencies = {
				"mfussenegger/nvim-dap",
				"rcarriga/nvim-dap-ui",
			},
			ft = { "java" },
		}
	or {}

PRE_CONFIG_FRANCK.java = PRE_CONFIG_FRANCK.useNvimJava and { "nvim-java/nvim-java" } or {}

_G.general_utils_franck = {}
_G.general_utils_franck.find_project_root = function()
	-- Get the absolute path of the current buffer
	local buffer_path = vim.fn.expand("%:p")
	if buffer_path == "" then
		buffer_path = vim.fn.getcwd() -- Fallback to current working directory
	end

	-- Extract the directory containing the current file
	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")

	-- Define the external script path
	local find_project_root_script = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

	-- Run the script and capture output + exit code
	local result = vim.fn.systemlist(find_project_root_script .. " " .. vim.fn.shellescape(buffer_dir))
	local exit_code = vim.v.shell_error -- Get the command's exit code

	-- 🚨 **Validation Checks**
	if exit_code == 2 or #result == 0 then
		print("In pre_config::find_project_root, the exit code of the c++ script was: " .. exit_code)
		local caller = debug.getinfo(2, "Sl") -- 2 = the caller's stack frame
		if caller then
			print("func() was called from: " .. caller.short_src .. ":" .. caller.currentline)
		else
			print("Caller info not available")
		end
		return nil -- Script failed, or output is empty
	end

	if exit_code == 1 then
		print("In pre_config::find_project_root, exit code of the c++ script was 1, meaning it's using current cwd for project root\n")
	end

	local project_root = table.concat(result, "\n") -- Convert table to string
	project_root = vim.trim(project_root) -- Trim whitespace/newlines

	-- Additional Safety Checks
	if project_root == "" or not vim.fn.isdirectory(project_root) then
		return nil
	end

	if #project_root > 256 then
		return nil -- Path too long
	end

	if project_root:find("[\n\r]") then
		return nil -- Unexpected newlines
	end

	-- ✅ Return the validated project root
	return project_root
end
