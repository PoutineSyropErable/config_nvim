-- local get_debug_plugin = function()
-- 	local path = vim.fn.glob("$HOME/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar", true, true)
-- 	return path
-- end

-- local get_debug_plugin = function()
-- 	local path = vim.fs.find("com.microsoft.java.debug.plugin-*.jar", {
-- 		path = os.getenv("HOME") .. "/java-debug/com.microsoft.java.debug.plugin/target",
-- 		upward = false,
-- 	})
-- 	return path[1] or nil -- Return first match or nil if empty
-- end

local get_debug_plugin = function()
	local home = os.getenv("HOME")
	local cmd = "ls -1 " .. home .. "/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar 2>/dev/null"

	local result = vim.fn.systemlist(cmd)

	-- Check if the command returned valid output
	if #result > 0 then
		return result[1] -- Return the first match
	else
		return nil -- No file found
	end
end

debug_plugin = get_debug_plugin()
print("Java Debug Plugin Path:", debug_plugin)
