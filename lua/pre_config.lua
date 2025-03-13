-- Ensure PRE_CONFIG_FRANCK exists
_G.PRE_CONFIG_FRANCK = {}
PRE_CONFIG_FRANCK.use_bufferline = true

_G.general_utils_franck = {}
_G.general_utils_franck.find_project_root = function()
	-- Get the absolute path of the current buffer
	local buffer_path = vim.fn.expand("%:p")
	if buffer_path == "" then
		buffer_path = vim.fn.getcwd() -- Fallback to current working directory
	end

	-- Extract the directory containing the current file
	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")

	-- Define the external script to find the project root
	local find_project_root_script = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

	-- Run the script and capture the output
	local project_root = vim.fn.system(find_project_root_script .. " " .. vim.fn.shellescape(buffer_dir))
	if project_root == nil then
		return nil
	end

	project_root = vim.trim(project_root) -- Trim whitespace/newlines

	-- 🚨 **Validation Checks**
	if project_root == "" or not vim.fn.isdirectory(project_root) then
		return nil -- Silent failure, returns nil instead of error message
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
