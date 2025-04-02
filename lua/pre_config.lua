-- Ensure PRE_CONFIG_FRANCK exists
_G.PRE_CONFIG_FRANCK = {}
PRE_CONFIG_FRANCK.use_bufferline = true

-- Java
PRE_CONFIG_FRANCK.useJavaLspConfig = false
PRE_CONFIG_FRANCK.useMyJavaDap = false
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
_G.general_utils_franck = {}

-- _G.general_utils_franck.find_project_root = function()
-- 	print("\n\n")
-- 	local buffer_path = vim.fn.expand("%:p")
-- 	if buffer_path == "" then
-- 		buffer_path = vim.fn.getcwd()
-- 	end

-- 	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")
-- 	local script_path = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

-- 	if vim.fn.filereadable(script_path) ~= 1 then
-- 		vim.notify("❌ Project root finder binary not found:\n" .. script_path, vim.log.levels.ERROR)
-- 		return nil
-- 	end

-- 	local result = vim.system({ script_path, buffer_dir, "--verbose" }, { text = true }):wait()

-- 	-- 🔧 Print stderr (debug info from C++)
-- 	if result.stderr and result.stderr ~= "" then
-- 		print("🔧 [C++ stderr]")
-- 		for _, line in ipairs(vim.split(result.stderr, "\n", { trimempty = true })) do
-- 			print("  " .. line)
-- 		end
-- 	end

-- 	print("\n\n")

-- 	-- ✅ Parse stdout (actual result)
-- 	local root = vim.trim(result.stdout or "")
-- 	local code = result.code or 1

-- 	if code == 1 then
-- 		vim.notify("ℹ️ Project root fallback: using cwd", vim.log.levels.INFO)
-- 	elseif code ~= 0 then
-- 		vim.notify("❌ Project root script failed (exit " .. code .. ")", vim.log.levels.ERROR)
-- 		return nil
-- 	end

-- 	-- 🧪 Validate the output
-- 	if root == "" or not vim.fn.isdirectory(root) then
-- 		vim.notify("⚠️ Invalid project root: '" .. root .. "'", vim.log.levels.WARN)
-- 		return nil
-- 	end

-- 	if #root > 256 then
-- 		vim.notify("⚠️ Project root too long", vim.log.levels.WARN)
-- 		vim.notify("root = " .. root, vim.log.levels.INFO)
-- 		return nil
-- 	end

-- 	if root:find("[\n\r]") then
-- 		vim.notify("root = " .. root, vim.log.levels.INFO)
-- 		vim.notify("⚠️ Project root contains newlines", vim.log.levels.WARN)
-- 		return nil
-- 	end

-- 	return root
-- end

-- _G.general_utils_franck.find_project_root = function()
-- 	local buffer_path = vim.fn.expand("%:p")
-- 	if buffer_path == "" then
-- 		buffer_path = vim.fn.getcwd()
-- 	end

-- 	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")
-- 	local script_path = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

-- 	if vim.fn.filereadable(script_path) ~= 1 then
-- 		vim.schedule(function() vim.notify("❌ Project root finder binary not found:\n" .. script_path, vim.log.levels.ERROR) end)
-- 		return nil
-- 	end

-- 	local result = vim.system({ script_path, buffer_dir, "--verbose" }, { text = true }):wait()

-- 	-- Collect stderr output from script
-- 	if result.stderr and result.stderr ~= "" then
-- 		local stderr_msg = "🔧 [C++ stderr]\n" .. result.stderr
-- 		vim.schedule(function() vim.notify(stderr_msg, vim.log.levels.DEBUG) end)
-- 	end

-- 	local root = vim.trim(result.stdout or "")
-- 	local code = result.code or 1

-- 	-- Check exit code
-- 	if code == 1 then
-- 		vim.schedule(function() vim.notify("ℹ️ Project root fallback: using cwd", vim.log.levels.INFO) end)
-- 	elseif code ~= 0 then
-- 		vim.schedule(function() vim.notify("❌ Project root script failed (exit " .. code .. ")", vim.log.levels.ERROR) end)
-- 		return nil
-- 	end

-- 	-- Validate result
-- 	if root == "" or not vim.fn.isdirectory(root) then
-- 		vim.schedule(function() vim.notify("⚠️ Invalid project root: '" .. root .. "'", vim.log.levels.WARN) end)
-- 		return nil
-- 	end

-- 	if #root > 256 then
-- 		vim.schedule(function() vim.notify("⚠️ Project root too long\nroot = " .. root, vim.log.levels.WARN) end)
-- 		return nil
-- 	end

-- 	if root:find("[\n\r]") then
-- 		vim.schedule(function() vim.notify("⚠️ Project root contains newlines\nroot = " .. root, vim.log.levels.WARN) end)
-- 		return nil
-- 	end

-- 	return root
-- end

_G.general_utils_franck.find_project_root = function(debug)
	local buffer_path = vim.fn.expand("%:p")
	if buffer_path == "" then
		buffer_path = vim.fn.getcwd()
	end

	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")
	local script_path = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

	if vim.fn.filereadable(script_path) ~= 1 then
		if debug then
			vim.schedule(function() vim.notify("❌ Project root finder binary not found:\n" .. script_path, vim.log.levels.ERROR) end)
		end
		return nil
	end

	local result = vim.system({ script_path, buffer_dir, "--verbose" }, { text = true }):wait()

	-- Collect stderr output from script
	if result.stderr and result.stderr ~= "" and debug then
		local stderr_msg = "🔧 [C++ stderr]\n" .. result.stderr
		vim.schedule(function() vim.notify(stderr_msg, vim.log.levels.DEBUG) end)
	end

	local root = vim.trim(result.stdout or "")
	local code = result.code or 1

	if code == 1 then
		if debug then
			vim.schedule(function() vim.notify("ℹ️ Project root fallback: using cwd", vim.log.levels.INFO) end)
		end
	elseif code ~= 0 then
		if debug then
			vim.schedule(function() vim.notify("❌ Project root script failed (exit " .. code .. ")", vim.log.levels.ERROR) end)
		end
		return nil
	end

	if root == "" or not vim.fn.isdirectory(root) then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Invalid project root: '" .. root .. "'", vim.log.levels.WARN) end)
		end
		return nil
	end

	if #root > 256 then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Project root too long\nroot = " .. root, vim.log.levels.WARN) end)
		end
		return nil
	end

	if root:find("[\n\r]") then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Project root contains newlines\nroot = " .. root, vim.log.levels.WARN) end)
		end
		return nil
	end

	return root
end
