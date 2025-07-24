local M = {}

function M.send_notification(msg)
	local cmd = string.format("notify-send -t 5000 '[Neovim Debug]' '%s'", msg)
	os.execute(cmd)
	M.print_custom("🟢 Debug: " .. msg)
end

function M.print_custom(...)
	if not vim.g.PRINT_CUSTOM_DEBUG then
		return
	end
	local parts = {}
	for _, v in ipairs({ ... }) do
		table.insert(parts, tostring(v))
	end
	local msg = table.concat(parts, "\t")
	vim.notify(msg, vim.log.levels.INFO)
end

-- ... other functions ...
function M.find_project_root(debug)
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
	_G.print_custom("fpr: root =" .. vim.inspect(root))

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

return M
