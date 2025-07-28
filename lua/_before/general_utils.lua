local M = {}

function M.send_notification(msg)
	local cmd = string.format("notify-send -t 5000 '[Neovim Debug]' '%s'", msg)
	os.execute(cmd)
	M.print_custom("🟢 Debug: " .. msg)
end

M.PRINT_CUSTOM_DEBUG = true

function M.print_custom(...)
	if not M.PRINT_CUSTOM_DEBUG then
		return
	end
	local parts = {}
	for _, v in ipairs({ ... }) do
		table.insert(parts, tostring(v))
	end
	local msg = table.concat(parts, "\t")
	vim.notify(msg, vim.log.levels.INFO)
end

function M.get_lsp_project_root()
	local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })

	for _, client in ipairs(clients) do
		-- Try root_dir first
		if client.config and client.config.root_dir then
			return client.config.root_dir
		end

		-- Fallback to workspace_folders
		local folders = client.workspace_folders
		if folders and folders[1] then
			return vim.uri_to_fname(folders[1].uri)
		end
	end
	return nil -- fallback to cwd or manual override
end

-- ... other functions ...
function M.find_project_root(debug)
	local buffer_path = vim.fn.expand("%:p")
	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")
	buffer_dir = vim.fn.getcwd()

	if debug then
		M.print_custom("buffer_dir =" .. vim.inspect(buffer_dir))
	end
	local script_path = vim.fn.expand("$HOME/.config/nvim/scripts/find_project_root")

	if vim.fn.filereadable(script_path) ~= 1 then
		if debug then
			vim.schedule(function() vim.notify("❌ Project root finder binary not found:\n" .. script_path, vim.log.levels.ERROR) end)
			M.send_notification("project root finder binary not found. " .. vim.inspect(script_path))
		end
		return nil
	end

	local result = vim.system({ script_path, buffer_dir, "--verbose" }, { text = true }):wait()

	-- Collect stderr output from script
	if result.stderr and result.stderr ~= "" and debug then
		local stderr_msg = "🔧 [C++ stderr]\n" .. result.stderr
		vim.schedule(function() vim.notify(stderr_msg, vim.log.levels.DEBUG) end)
		M.print_custom(stderr_msg)
	end

	local root = vim.trim(result.stdout or "")
	local code = result.code or 1
	M.print_custom("fpr: root =" .. vim.inspect(root))

	if code == 1 then
		if debug then
			vim.schedule(function() vim.notify("ℹ️ Project root fallback: using cwd", vim.log.levels.INFO) end)
		end
	elseif code ~= 0 then
		if debug then
			vim.schedule(function() vim.notify("❌ Project root script failed (exit " .. code .. ")", vim.log.levels.ERROR) end)
			M.send_notification("script failed " .. vim.inspect(script_path))
		end
		return nil
	end

	if root == "" or not vim.fn.isdirectory(root) then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Invalid project root: '" .. root .. "'", vim.log.levels.WARN) end)
			M.send_notification("invalid projet root " .. vim.inspect(script_path))
		end
		return nil
	end

	if #root > 256 then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Project root too long\nroot = " .. root, vim.log.levels.WARN) end)
			M.send_notification("too long " .. vim.inspect(script_path))
		end
		return nil
	end

	if root:find("[\n\r]") then
		if debug then
			vim.schedule(function() vim.notify("⚠️ Project root contains newlines\nroot = " .. root, vim.log.levels.WARN) end)
			M.send_notification("contains new lines " .. vim.inspect(script_path))
		end
		return nil
	end

	return root
end

----------------------------------------------- Super utils -----------------------------------

function M.not_invert()
	local word = vim.fn.expand("<cword>")
	local replacements = {
		["true"] = "false",
		["false"] = "true",
		["True"] = "False",
		["False"] = "True",
	}

	if replacements[word] then
		vim.cmd("normal! ciw" .. replacements[word])
	else
		M.print_custom("NotInvert: No matching word to invert")
	end
end

function M.search_word(direction)
	-- Get the word under the cursor
	local word = vim.fn.expand("<cword>")
	if word == nil or word == "" then
		M.print_custom("No word under cursor!")
		return
	end

	-- Perform the search
	local function bool_cast(value) return (value and true) or false end
	local found = false
	if direction == "next" then
		found = bool_cast(vim.fn.search("\\V" .. vim.fn.escape(word, "\\"), "W")) -- Case-sensitive forward search
	elseif direction == "prev" then
		found = bool_cast(vim.fn.search("\\V" .. vim.fn.escape(word, "\\"), "bW")) -- Case-sensitive backward search
	else
		M.print_custom("Invalid direction: Use 'next' or 'prev'")
		return
	end

	if found ~= 0 then
		M.print_custom("Found word: " .. word)
	else
		M.print_custom("Word not found: " .. word)
	end
end

function M.SearchNextWord() M.search_word("next") end

function M.SearchPrevWord() M.search_word("prev") end

--- Search current word and go to next or previous match
---@param reverse boolean? If true, jump backward (NN), else just search forward (/word<CR>)
function M.search_current_word(reverse)
	local word = vim.fn.expand("<cword>")
	if word ~= "" then
		if reverse then
			-- Search forward first to set the search, then skip current with NN backward
			vim.fn.feedkeys("/" .. vim.fn.escape(word, "/\\") .. "\n", "n")
			vim.schedule(function() vim.api.nvim_feedkeys("NN", "n", false) end)
		else
			-- Just search forward once
			vim.fn.feedkeys("/" .. vim.fn.escape(word, "/\\") .. "\n", "n")
		end
	end
end

function M.CopyFilePath()
	local path = vim.fn.expand("%:p") -- Get absolute file path
	vim.fn.setreg("+", path) -- Copy to system clipboard
	M.print_custom("Copied file path: " .. path)
end

function M.CopyDirPath()
	local dir = vim.fn.expand("%:p:h") -- Get directory path of current file
	vim.fn.setreg("+", dir) -- Copy to system clipboard
	M.print_custom("Copied directory path: " .. dir)
end

function M.cdHere()
	local file_path = vim.fn.expand("%:p")
	local dir_to_cd = nil

	if file_path ~= "" then
		-- Buffer has a file loaded, cd to its parent dir
		dir_to_cd = vim.fn.fnamemodify(vim.fn.resolve(file_path), ":p:h")
	else
		-- No file in buffer; check if first CLI argument is a dir
		local first_arg = vim.fn.argv()
		first_arg = first_arg[1] or "" -- get first arg from the array or empty string
		if first_arg ~= "" and vim.fn.isdirectory(first_arg) == 1 then
			dir_to_cd = vim.fn.fnamemodify(vim.fn.resolve(first_arg), ":p")
		end
	end

	if not dir_to_cd or vim.fn.isdirectory(dir_to_cd) == 0 then
		-- No valid dir to cd to
		return
	end

	local escaped_dir = vim.fn.fnameescape(dir_to_cd)
	vim.cmd("tcd " .. escaped_dir)
	vim.cmd("lcd " .. escaped_dir)
	vim.cmd("cd " .. escaped_dir)

	local tapi = package.loaded["nvim-tree.api"]
	if tapi and tapi.tree and tapi.tree.change_root then
		tapi.tree.change_root(dir_to_cd) -- Sync Nvim-Tree, if available
	end

	M.print_custom("Changed directory to: " .. dir_to_cd)
end

return M
