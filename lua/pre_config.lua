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

_G.general_utils_franck.send_notification = function(message)
	local cmd = string.format("notify-send -t 5000 '[Neovim Debug]' '%s'", message)
	os.execute(cmd) -- Send notification
	_G.print_custom("🟢 Debug: " .. message) -- Also log to Neovim
end

_G.PRINT_CUSTOM_DEBUG = true -- toggle debug output on/off

local function print_custom(...)
	if not _G.PRINT_CUSTOM_DEBUG then
		return
	end -- suppress if debug off

	local args = { ... }
	local parts = {}
	for i, v in ipairs(args) do
		parts[i] = tostring(v)
	end
	local msg = table.concat(parts, "\t")

	-- Use vim.notify to show as notification or just silent log
	vim.notify(msg, vim.log.levels.INFO)
end

_G.print_custom = print_custom

_G.general_utils_franck.find_project_root = function(debug)
	local buffer_path = vim.fn.expand("%:p")
	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")
	buffer_dir = vim.fn.getcwd()

	if debug then
		_G.print_custom("buffer_dir =" .. vim.inspect(buffer_dir))
	end
	local script_path = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

	if vim.fn.filereadable(script_path) ~= 1 then
		if debug then
			vim.schedule(function() vim.notify("❌ Project root finder binary not found:\n" .. script_path, vim.log.levels.ERROR) end)
			general_utils_franck.send_notification("project root finder binary not found. " .. vim.inspect(script_path))
		end
		return nil
	end

	local result = vim.system({ script_path, buffer_dir, "--verbose" }, { text = true }):wait()

	-- Collect stderr output from script
	if result.stderr and result.stderr ~= "" and debug then
		local stderr_msg = "🔧 [C++ stderr]\n" .. result.stderr
		vim.schedule(function() vim.notify(stderr_msg, vim.log.levels.DEBUG) end)
		_G.print_custom(stderr_msg)
	end

	local root = vim.trim(result.stdout or "")
	local code = result.code or 1
	_G.print_custom("root =" .. vim.inspect(root))

	if code == 1 then
		if debug then
			vim.schedule(function() vim.notify("ℹ️ Project root fallback: using cwd", vim.log.levels.INFO) end)
		end
	elseif code ~= 0 then
		if debug then
			vim.schedule(function() vim.notify("❌ Project root script failed (exit " .. code .. ")", vim.log.levels.ERROR) end)
			general_utils_franck.send_notification("script failed " .. vim.inspect(script_path))
		end
		return nil
	end

	if root == "" or not vim.fn.isdirectory(root) then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Invalid project root: '" .. root .. "'", vim.log.levels.WARN) end)
			general_utils_franck.send_notification("invalid projet root " .. vim.inspect(script_path))
		end
		return nil
	end

	if #root > 256 then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Project root too long\nroot = " .. root, vim.log.levels.WARN) end)
			general_utils_franck.send_notification("too long " .. vim.inspect(script_path))
		end
		return nil
	end

	if root:find("[\n\r]") then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Project root contains newlines\nroot = " .. root, vim.log.levels.WARN) end)
			general_utils_franck.send_notification("contains new lines " .. vim.inspect(script_path))
		end
		return nil
	end

	return root
end
