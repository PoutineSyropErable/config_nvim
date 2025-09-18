-- use :verbose map <key> to get information on a keybind
--run nvim with nvim <file> -V1 to get the information of where the file is
--inside nvimtree, do g? to get information

-- control+space for buffer completion on the other

-- Set the leader key if not already set
vim.g.mapleader = " "
local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

-----------------------------------------------ACTUAL START-------------------------------------------

-- See keymaps pre for stuff that doesn't use a plugin, just general keymaps for if my plugins loading fails

--------------------- General keymaps
local bufremove = require("mini.bufremove") -- Load once
keymap.set("n", "<leader>wq", ":wa | qa<CR>") -- save and quit
-- keymap.set("n", "<leader>qq", ":q!<CR>") -- quit without saving
local function close_buffer_or_tab()
	local buf_count = #vim.fn.getbufinfo({ buflisted = 1 }) -- Get number of open buffers
	local tab_count = vim.fn.tabpagenr("$") -- Get the number of tabs

	-- If only one buffer is open, close the tab
	if buf_count == 1 then
		if tab_count == 1 then
			vim.cmd("q") -- Quit the current tab (and vim if it's the last tab)
		else
			vim.cmd("tabclose") -- Close the current tab
		end
	else
		bufremove.delete(0, false) -- Close the current buffer without saving
	end
end

vim.keymap.set("n", "<leader>q", close_buffer_or_tab, opts("Close current buffer"))
vim.keymap.set("n", "<leader>X", function() bufremove.delete(0, false) end, opts("Close current buffer"))
keymap.set("n", "<leader>bd", ": bd!<CR>", opts(":bd close buffer"))
keymap.set("n", "<leader>ww", ":wa<CR>") -- save
keymap.set("n", "<leader>wa", ":wa<CR>") -- save all buffers
keymap.set("n", "gx", ":!open <c-r><c-a><CR>") -- open URL under cursor

----------------Split window management, split, resize
local tapi = require("nvim-tree.api")

--there's a repeat of sh, it's fine. It's for inside nvim_tree, to open current file in a split
keymap.set("n", "<leader>sh", tapi.node.open.vertical, opts("nvim-tree | Open: Vertical Split"))
keymap.set("n", "<leader>sv", tapi.node.open.horizontal, opts("nvim tree |  Open: Horizontal Split"))
-- I'm used to have it the other way arround. Horizontal split. = Side by side. Though its a vertical line.
-- Too late, I'm used to it mixed up
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width
keymap.set("n", "<leader>sx", ":close<CR>") -- close split window
keymap.set("n", "<leader>sk", "<C-w>-") -- make split window height shorter
keymap.set("n", "<leader>si", "<C-w>+") -- make split windows height taller
keymap.set("n", "<leader>sl", "<C-w>>5") -- make split windows width bigger
keymap.set("n", "<leader>sj", "<C-w><5") -- make split windows width smaller
keymap.set("n", "<C-w>f", ":MaximizerToggle<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>sf", ":MaximizerToggle<CR>", { noremap = true, silent = true })

---- Resize splits with Ctrl + arrow keys
keymap.set("n", "<C-Up>", ":resize +5<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-Down>", ":resize -5<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-Left>", ":vertical resize -5<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-Right>", ":vertical resize +5<CR>", { noremap = true, silent = true })

---- Resized splits with Alt + ijkl
keymap.set("n", "<M-j>", ":vertical resize -5<CR>", { noremap = true, silent = true })
keymap.set("n", "<M-l>", ":vertical resize +5<CR>", { noremap = true, silent = true })
-- these two bellow might not work idk
keymap.set("n", "<M-i>", ":resize 5<CR>", { noremap = true, silent = true })
keymap.set("n", "<M-k>", ":resize -5<CR>", { noremap = true, silent = true })

--------------------------------------------------------------------------------------- Tab management
-- I don't use tabs (but hey) [I use them now]
keymap.set("n", "<leader>Tc", ":tabnew<CR>", opts("New tab"))
keymap.set("n", "<leader>Tx", ":tabclose<CR>", opts("Close tab"))
keymap.set("n", "<leader>Tk", ":tabnext<CR>", opts("Next tab"))
keymap.set("n", "<leader>Tj", ":tabprevious<CR>", opts("Previous tab"))

keymap.set("n", "<C-w>c", "<Cmd>tabnew<CR>", opts("New tab"))
keymap.set("n", "<C-w>x", "<Cmd>tabclose<CR>", opts("Close tab"))
keymap.set("n", "<C-w>b", "<Cmd>tabprevious<CR>", opts("Previous buffer"))
keymap.set("n", "<C-w>n", "<Cmd>tabnext<CR>", opts("Next buffer"))

-- Move Tabs Around
keymap.set("n", "<leader>Tb", ":tabmove -1<CR>", opts("Move tab left"))
keymap.set("n", "<leader>Tn", ":tabmove +1<CR>", opts("Move tab right"))

-- Navigate buffers (Next/Previous)
keymap.set("n", "<C-b>", "<Cmd>BufferPrevious<CR>", opts("Previous buffer"))
keymap.set("n", "<C-n>", "<Cmd>BufferNext<CR>", opts("Next buffer"))
keymap.set("n", "<leader>bj", "<Cmd>BufferPrevious<CR>", opts("Previous buffer"))
keymap.set("n", "<leader>bk", "<Cmd>BufferNext<CR>", opts("Next buffer"))

-- local has_bufferline, _ = pcall(require, "bufferline")
-- local has_barbar, _ = pcall(require, "barbar")

local has_bufferline = PRE_CONFIG_FRANCK.use_bufferline
local has_barbar = not has_bufferline

local function goto_buffer(_) end
if has_bufferline then
	-- _G.print_custom("Using Bufferline")
	-- Bufferline keymaps
	keymap.set("n", "<C-n>", "<Cmd>BufferLineCycleNext<CR>", opts("Next buffer (Bufferline)"))
	keymap.set("n", "<C-b>", "<Cmd>BufferLineCyclePrev<CR>", opts("Previous buffer (Bufferline)"))
	keymap.set("n", "<leader>B", "<Cmd>BufferLineMovePrev<CR>", opts("Move buffer left (Bufferline)"))
	keymap.set("n", "<leader>N", "<Cmd>BufferLineMoveNext<CR>", opts("Move buffer right (Bufferline)"))
	local bufferline = require("bufferline")
	local function rename_tab()
		local new_buffer_name = vim.fn.input("Enter new tab name: ")
		if new_buffer_name ~= "" then
			require(bufferline).rename_tab({ new_buffer_name }) -- Pass as a table/array
		else
			_G.print_custom("❌ Tab rename canceled (empty input)")
		end
	end
	keymap.set("n", "<leader>.r", rename_tab, opts("Rename current tab"))

	goto_buffer = function(buf_num) vim.cmd("BufferLineGoToBuffer " .. buf_num) end
elseif has_barbar then
	-- _G.print_custom("Using Barbar")
	-- Barbar keymaps
	keymap.set("n", "<C-n>", "<Cmd>BufferNext<CR>", opts("Next buffer (Barbar)"))
	keymap.set("n", "<C-b>", "<Cmd>BufferPrevious<CR>", opts("Previous buffer (Barbar)"))
	keymap.set("n", "<leader>B", "<Cmd>BufferMovePrevious<CR>", opts("Move buffer left (Barbar)"))
	keymap.set("n", "<leader>N", "<Cmd>BufferMoveNext<CR>", opts("Move buffer left (Barbar)"))

	goto_buffer = function(buf_num) vim.cmd("BufferGoto " .. buf_num) end
else
	_G.print_custom("Neither Bufferline nor Barbar is installed!")
end

--  <leader># leader# leadern <leader>n <leader><n>   (search strings)
for i = 1, 9 do
	keymap.set("n", "<leader>" .. i, function() goto_buffer(i) end, opts("Go to buffer " .. i))
end
-- Bind <leader>0 to goto 10for buffer switching
keymap.set("n", "<leader>0", function() goto_buffer(10) end, opts("Go to buffer 10"))

-- Keymaps for splits (vertical and horizontal)
keymap.set("n", "<C-w>h", ":vsplit<CR>", opts("Vertical split"))
keymap.set("n", "<C-w>v", ":split<CR>", opts("Horizontal split"))

-- Keymap for closing the current tab using Ctrl+w X
keymap.set("n", "<C-w>d", ":close<CR>", opts("Close window"))

-- See <leader>pm to move buf by itself.
local function scope_move_and_focus(tab_index)
	local buf = vim.api.nvim_get_current_buf()

	-- Step 1: Move buffer to target tab
	vim.cmd("ScopeMoveBuf " .. tab_index)

	-- Step 2: Switch to that tab
	vim.cmd(tab_index .. "tabnext")

	-- Step 3: Focus the buffer we just moved (in case it's not shown)
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local focused = false
	for _, win in ipairs(wins) do
		if vim.api.nvim_win_get_buf(win) == buf then
			vim.api.nvim_set_current_win(win)
			focused = true
			break
		end
	end

	-- If buffer wasn't in any window (rare), open it manually
	if not focused then
		vim.cmd("buffer " .. buf)
	end
end

local number_to_shifted_symbol = {
	[1] = "!",
	[2] = '"',
	[3] = "#",
	[4] = "$",
	[5] = "%",
	[6] = "&",
	[7] = "'",
	[8] = "(",
	[9] = ")",
	[10] = ")",
}

for i = 1, 9 do
	vim.keymap.set("n", "<leader>s" .. i, function() scope_move_and_focus(i) end, { desc = "Send + switch to tab " .. i })
end

for i, symbol in pairs(number_to_shifted_symbol) do
	vim.keymap.set("n", "<C-w>" .. symbol, function() scope_move_and_focus(i) end, { desc = "Send + switch to tab " .. i .. " (Hypr-style)" })
end

for i = 1, 9 do
	vim.keymap.set("n", "<C-w>" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

-- Keymap for saving all
keymap.set("n", "<C-w>S", ":wa<CR>", opts("Save all files"))
keymap.set("", "<C-S>", ":w<CR>", opts("Save file"))
keymap.set("", "<C-s>s", ":w<CR>", opts("Save file"))

-- Keymap for write and save all
keymap.set("", "<C-w>q", ":wa | qa!<CR>", opts("Save all and quit"))
keymap.set("", "<C-w>Q", ":qa!<CR>", opts("Quit without saving"))

-- Function to get all windows in the current tab
local function get_visible_windows()
	return vim.api.nvim_tabpage_list_wins(0) -- Get all windows in the current tab
end

-- Function to move to a specific window by index (1-9)
local function move_to_window(index)
	local windows = get_visible_windows()
	if windows[index] then
		vim.api.nvim_set_current_win(windows[index]) -- Switch to the selected window
	else
		_G.print_custom("No window available for index " .. index)
	end
end

-- Create keybindings for m1-9 to switch between windows
for i = 1, 9 do
	keymap.set("n", "m" .. i, function() move_to_window(i) end, opts("Move to window " .. i))
end

-- m0 to go to the last window in the visible list
keymap.set("n", "m0", function()
	local windows = get_visible_windows()
	if #windows > 0 then
		vim.api.nvim_set_current_win(windows[#windows]) -- Switch to last window
	else
		_G.print_custom("No visible windows to switch to")
	end
end, opts("Move to last visible window"))

------------------------------------------------- Sessions keymaps
keymap.set("n", "<leader>pl", function() require("nvim-possession").list() end, opts("📌list sessions"))
keymap.set("n", "<leader>pc", function() require("nvim-possession").new() end, opts("📌create new session"))
keymap.set("n", "<leader>pu", function() require("nvim-possession").update() end, opts("📌update current session"))
keymap.set("n", "<leader>pm", ":ScopeMoveBuf", opts("move current buffer to the tab nbr"))

local function rename_tab()
	local new_buffer_name = vim.fn.input("Enter new tab name: ")
	if new_buffer_name ~= "" then
		require("bufferline").rename_tab({ new_buffer_name }) -- Pass as a table/array
	else
		_G.print_custom("❌ Tab rename canceled (empty input)")
	end
end
keymap.set("n", "<leader>.r", rename_tab, opts("Rename current tab"))

----------------------------------------------- Flash keymaps
local flash = require("flash")

flash.setup({
	event = "VeryLazy",
	opts = {},
	modes = {
		char = {
			enabled = true, -- Ensure `f`, `t`, `F`, `T` work with Flash.nvim
			jump_labels = true, -- Show labels after `f` or `t`
			multi_line = true, -- Allow jumping across lines
			highlight = {
				matches = true, -- Ensure matches are highlighted
				backdrop = false, -- Prevent dimming of non-matching text
			},
			label = { after = { 0, 1 } },
		},
	},
})

-- Define key mappings using keymap.set

keymap.set({ "n", "x", "o" }, "rj", flash.jump, { desc = "Flash jump" })
keymap.set("n", "rT", flash.toggle, { desc = "Toggle Flash Search" })
keymap.set({ "n", "x", "o" }, "rt", flash.treesitter, { desc = "Flash Treesitter" })
keymap.set("o", "ro", flash.remote, { desc = "Remote Flash" })
keymap.set({ "o", "x" }, "rs", flash.treesitter_search, { desc = "Treesitter Search" })

--------------------------------------------TREESJ
-- Key mappings for TreeSJ commands
keymap.set("n", "<leader>jm", ":TSJToggle<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>js", ":TSJSplit<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>jj", ":TSJJoin<CR>", { noremap = true, silent = true })

--------------------------------------------mini.surround
local surrounds_mappings_see_mini_surround_lua = {
	add = "<leader>Sa", -- Add surrounding in Normal and Visual modes
	delete = "<leader>Sd", -- Delete surrounding
	find = "<leader>Sf", -- Find surrounding (to the right)
	find_left = "<leader>SF", -- Find surrounding (to the left)
	highlight = "<leader>Sh", -- Highlight surrounding
	replace = "<leader>Sr", -- Replace surrounding
	update_n_lines = "<leader>Sn", -- Update `n_lines`

	suffix_last = "l", -- Suffix to search with "prev" method
	suffix_next = "n", -- Suffix to search with "next" method
}

---------------------------------------------------------------- Harpoon
local harpoon_ui = require("harpoon.ui") -- Isolate Harpoon UI
local harpoon_mark = require("harpoon.mark") -- Isolate Harpoon Mark

-- Add current file to Harpoon
keymap.set("n", "<leader>ha", harpoon_mark.add_file, { desc = "Add file to Harpoon" })

-- Toggle Harpoon quick menu
keymap.set("n", "<leader>hh", harpoon_ui.toggle_quick_menu, { desc = "Open Harpoon quick menu" })

-- Navigate to Harpoon file slots (1-9)
for i = 1, 9 do
	keymap.set("n", "<leader>h" .. i, function() harpoon_ui.nav_file(i) end, { desc = "Go to Harpoon file " .. i })
end

-- Cycle through Harpoon files
keymap.set("n", "<leader>hb", harpoon_ui.nav_prev, { desc = "Go to previous Harpoon file" })
keymap.set("n", "<leader>hn", harpoon_ui.nav_next, { desc = "Go to next Harpoon file" })

----------------------------------------------Telescope
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local all_symbols = {
	"File",
	"Module",
	"Namespace",
	"Package",
	"Class",
	"Method",
	"Property",
	"Field",
	"Constructor",
	"Enum",
	"Interface",
	"Function",
	"Variable",
	"Constant",
	"String",
	"Number",
	"Boolean",
	"Array",
	"Object",
	"Key",
	"Null",
	"EnumMember",
	"Struct",
	"Event",
	"Operator",
	"TypeParameter",
}

local function all_document_symbols()
	builtin.lsp_document_symbols({
		symbols = all_symbols,
	})
end

-- Function for all symbols across the workspace
local function all_workspace_symbols()
	builtin.lsp_workspace_symbols({
		symbols = all_symbols,
	})
end

-- Toggle flag to switch between project root and current file's directory
local use_project_root = false

local function toggle_find_files()
	use_project_root = not use_project_root
	--
end

local function telescope_cwd()
	local tel_cwd = nil
	if use_project_root then
		tel_cwd = _G.general_utils_franck.find_project_root(false)
	else
		tel_cwd = vim.fn.getcwd()
	end
	return tel_cwd
end

local function find_files() builtin.find_files({ cwd = telescope_cwd() }) end
local function live_grep() builtin.live_grep({ cwd = telescope_cwd() }) end
local function live_grep_current_word() builtin.live_grep({ default_text = vim.fn.expand("<cword>"), cwd = telescope_cwd() }) end

local select_and_write_function
local select_and_write_fn = function() return select_and_write_function() end -- defined later

vim.keymap.set("n", "<leader>ft", toggle_find_files, { desc = "Toggle Find Files (Project Root / CWD)" })
keymap.set("n", "<leader>ff", find_files, opts("Find Files"))
keymap.set("n", "<leader>fg", live_grep, opts("Live Grep"))
keymap.set("n", "<leader>fw", live_grep_current_word, opts("Live grep current word"))

keymap.set("n", "<leader>fs", all_document_symbols, opts("All Variable/Symbols Information (Document)"))
keymap.set("n", "<leader>fS", all_workspace_symbols, opts("All Variable/Symbols Information (Workspace)"))

keymap.set("n", "<leader>fk", builtin.keymaps, opts("Find Keymaps"))

keymap.set("n", "<leader>fG", builtin.grep_string, opts("Grep String"))
keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, opts("Current Buffer Fuzzy Find"))

keymap.set("n", "<leader>fo", builtin.oldfiles, opts("Recently used files (Old files)"))
keymap.set("n", "<leader>fb", builtin.buffers, opts("Buffers"))
keymap.set("n", "<leader>fB", telescope.extensions.scope.buffers, opts("Telescope File Browser"))
keymap.set("n", "<leader><leader>", telescope.extensions.file_browser.file_browser, opts("Telescope File Browser"))

keymap.set("n", "<leader>fh", builtin.help_tags, opts("Help Tags"))
keymap.set("n", "<leader>fH", ":nohlsearch<CR>") -- No description needed for raw command
keymap.set("n", "<leader>fi", builtin.lsp_incoming_calls, opts("Incoming calls (Those who call this functions)"))
keymap.set("n", "<leader>fm", function() builtin.treesitter({ default_text = ":method:" }) end, opts("Find Methods with Treesitter"))
keymap.set("n", "<leader>fF", function() builtin.treesitter({ default_text = ":function:" }) end, opts("Find functions with Treesitter"))
keymap.set("n", "<leader>fn", "<cmd>Telescope neoclip<CR>", opts("Telescope Neoclip"))
keymap.set("n", "<leader>fr", select_and_write_fn, opts("select and write function, also on <leader>er"))

keymap.set("n", "<leader>fc", builtin.colorscheme, opts("Change Color Scheme"))

-- Jump List Navigation
keymap.set("n", "<C-o>", "<C-o>", opts("Jump Backward in Jump List"))
keymap.set("n", "<C-p>", "<C-i>", opts("Jump Forward in Jump List"))
keymap.set("n", "<leader>jb", "<C-o>", opts("Jump Backward in Jump List"))
keymap.set("n", "<leader>jf", "<C-i>", opts("Jump Forward in Jump List"))

----------------------------------------------------------------------------------------- LSP
-- Helper function to check if LSP is available
local function safe_lsp_call(fn)
	return function()
		if vim.lsp.buf[fn] then
			vim.lsp.buf[fn]()
		else
			_G.print_custom("LSP function '" .. fn .. "' not available")
		end
	end
end

local function safe_telescope_call(fn)
	return function()
		local ok, telescope_builtin = pcall(require, "telescope.builtin")
		if ok and telescope_builtin[fn] then
			telescope_builtin[fn]()
			return 0
		else
			_G.print_custom("Telescope function '" .. fn .. "' not available")
			return 1
		end
	end
end

-- Go to current function
local ts_utils = require("nvim-treesitter.ts_utils")
local function goto_current_function()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }

	vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(_, result)
		if not result then
			_G.print_custom("No LSP symbols found.")
			return
		end

		local row = vim.api.nvim_win_get_cursor(0)[1] -- Get cursor line
		local function_node = nil

		-- Recursive search for the function under the cursor
		local function find_function(symbols)
			for _, symbol in ipairs(symbols) do
				local kind = symbol.kind
				local range = symbol.range

				-- Function or Method symbols
				if kind == 12 or kind == 6 then
					local start_line = range.start.line + 1
					local end_line = range["end"].line + 1

					-- Check if cursor is within function bounds
					if start_line <= row and row <= end_line then
						function_node = symbol
					end
				end

				-- Recursively check children (for nested functions)
				if symbol.children then
					find_function(symbol.children)
				end
			end
		end

		find_function(result)

		if function_node then
			local target_line = function_node.range.start.line + 1
			local target_col = function_node.range.start.character
			local line_content = vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1]

			-- **🔹 Debugging output**
			_G.print_custom("---- DEBUG INFO ----")
			_G.print_custom("🔹 Full Line:", line_content)
			_G.print_custom("🔹 LSP Start Character:", target_col)

			-- Attempt to extract function name from the line
			local function_name = string.match(line_content, "([_%w]+)%s*%(")

			if function_name then
				local col = string.find(line_content, function_name) - 1
				_G.print_custom("🔹 Detected Function Name:", function_name, "at column:", col)
				vim.api.nvim_win_set_cursor(0, { target_line, col })
			else
				_G.print_custom("❌ Function name not found using regex. Using fallback LSP position.")
				vim.api.nvim_win_set_cursor(0, { target_line, target_col })
			end
		else
			_G.print_custom("❌ No function found.")
		end
	end)
end

local function get_function_calls()
	local parser = vim.treesitter.get_parser(0, "c") -- Use Treesitter for C
	local tree = parser:parse()[1]
	local root = tree:root()
	local calls = {}

	local function traverse(node)
		if node:type() == "call_expression" then
			local func_node = node:child(0) -- Function name
			if func_node then
				local func_name = vim.treesitter.get_node_text(func_node, 0)
				local line, col, _ = node:start()
				line = line + 1

				-- Store function call information
				table.insert(calls, { name = func_name, line = line, col = col })
			end
		end
		-- Recursively check children
		for child in node:iter_children() do
			traverse(child)
		end
	end

	traverse(root)

	-- 🔹 Debugging Output: Print All Found Calls
	-- _G.print_custom("📌 [DEBUG] Function Calls Found:")
	-- for _, call in ipairs(calls) do
	--  _G.print_custom("  🔹 " .. call.name .. " at line " .. call.line .. ", column " .. call.col)
	-- end

	return calls
end

local function goto_next_function_call()
	local calls = get_function_calls()
	if #calls == 0 then
		_G.print_custom("❌ No function calls found in this file.")
		return nil
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Get cursor position
	local next_call = nil

	-- 🔹 Find the first function call that occurs after the cursor position
	for _, call in ipairs(calls) do
		if call.line > row or (call.line == row and call.col > col) then
			next_call = call
			break
		end
	end

	if next_call then
		_G.print_custom("🔹 Jumping to function call:", next_call.name, "at line", next_call.line, "column", next_call.col)
		vim.api.nvim_win_set_cursor(0, { next_call.line, next_call.col })
		return next_call
	else
		_G.print_custom("❌ No next function call found.")
	end
end

local function goto_previous_function_call()
	local calls = get_function_calls()
	if #calls == 0 then
		_G.print_custom("❌ No function calls found in this file.")
		return nil
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Get cursor position
	local prev_call = nil

	-- 🔹 Find the last function call that occurs before the cursor position
	for i = #calls, 1, -1 do
		local call = calls[i]
		if call.line < row or (call.line == row and call.col < col) then
			prev_call = call
			break
		end
	end

	if prev_call then
		_G.print_custom("🔹 Jumping to function call:", prev_call.name, "at line", prev_call.line, "column", prev_call.col)
		vim.api.nvim_win_set_cursor(0, { prev_call.line, prev_call.col })
		return prev_call
	else
		_G.print_custom("❌ No previous function call found.")
	end
end

-- LSP Hover
-- keymap.set("n", "$", vim.lsp.buf.hover, opts("Hover Information"))
-- keymap.set("n", "<C-d>", function() vim.lsp.util.scroll(4) end, opts("Scroll down on hover"))
-- keymap.set("n", "<C-e>", function() vim.lsp.util.scroll(-4) end, opts("Scroll up on however"))
vim.keymap.set("n", "¢", function()
	vim.lsp.buf.hover()

	-- Defer switching focus to ensure the hover window is created
	vim.defer_fn(function()
		-- Force `wincmd w` to work properly
		vim.cmd("wincmd w")
	end, 500) -- Small delay to allow hover to open
end, opts("hover and switch"))

-- LSP Actions
keymap.set("n", "<leader>Ll", function() require("lint").try_lint() end, { desc = "Manually trigger linting" })
-- keymap.set("n", "<leader>Lr", "<cmd>Lspsaga rename<CR>", opts("Rename symbol in all occurrences"))
keymap.set("n", "<leader>Lr", safe_lsp_call("rename"), opts("Rename symbol"))
keymap.set("n", "<leader>Lc", safe_lsp_call("code_action"), opts("Show available code actions"))
keymap.set("n", "<leader>LC", "<cmd>Lspsaga code_action<CR>", opts("Show available code actions"))
keymap.set("n", "$", "<cmd>Lspsaga hover_doc<CR>", opts("Hover Information"))
keymap.set("n", "<Leader>Lo", "<cmd>Lspsaga outline<CR>", opts("Show Outline"))
keymap.set("n", "<Leader>o", "<cmd>Lspsaga outline<CR>", opts("Show Outline"))
keymap.set("n", "<leader>Lb", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts("Go to previous diagnostic"))
keymap.set("n", "<leader>Ln", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts("Go to next diagnostic"))
keymap.set("n", "<Leader>Lf", "<cmd>Lspsaga finder<CR>", opts("Show Outline"))

keymap.set("n", "$", "<cmd>Lspsaga hover_doc<CR>", opts("Hover Information"))
keymap.set("n", "<Leader>Lo", "<cmd>Lspsaga outline<CR>")

----- Pathfinder goto files
local pathfinder = require("pathfinder")
--("$HOME/some file with space.txt")
-- $HOME/.zshrc

keymap.set("n", "gf", pathfinder.gf, opts("Enhanced go to file"))
keymap.set("n", "gF", pathfinder.gF, opts("Enhanced Go to file with line"))
keymap.set("n", "gx", pathfinder.gx, opts("Enhanced Go to file with line"))

-- LSP Definitions & References
keymap.set("n", "gd", safe_telescope_call("lsp_definitions"), opts("Go to definition"))
keymap.set("n", "gD", safe_lsp_call("declaration"), opts("Go to declaration"))
keymap.set("n", "gj", vim.lsp.buf.definition, opts("Go to definition (No telescope)"))
keymap.set("n", "gI", safe_telescope_call("lsp_implementations"), opts("Find implementations"))
keymap.set("n", "gr", safe_telescope_call("lsp_references"), opts("Find references"))

keymap.set("n", "gh", goto_current_function, opts("Go to current function"))
keymap.set("n", "gs", goto_next_function_call, opts("Go to next function"))
keymap.set("n", "gn", goto_next_function_call, opts("Go to next function"))
keymap.set("n", "gN", goto_previous_function_call, opts("Go to previous function"))
keymap.set("n", "gi", builtin.lsp_incoming_calls, opts("Incoming calls (Telescope)"))
keymap.set("n", "go", builtin.lsp_outgoing_calls, opts("Outcoming calls (Telescope)"))
keymap.set("n", "ge", vim.lsp.buf.incoming_calls, opts("Incoming calls (lsp buff)"))
keymap.set("n", "gy", vim.lsp.buf.outgoing_calls, opts("Outcoming calls (lsp buff)"))
keymap.set("n", "gw", function() builtin.live_grep({ default_text = vim.fn.expand("<cword>") }) end, opts("Live grep current word"))

vim.keymap.set(
	"n",
	"gl",
	function()
		vim.diagnostic.open_float({
			border = "rounded",
			max_width = 120,
			header = "Diagnostics:",
			focusable = true,
		})
	end
)

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function() vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition (No telescope)")) end,
})

-- LSP Information
keymap.set("n", "<leader>Lg", safe_lsp_call("hover"), opts("Show LSP hover info"))
keymap.set("n", "<leader>Ls", safe_lsp_call("signature_help"), opts("Show function signature help"))

-- Workspace Folder Management
keymap.set("n", "<leader>LA", safe_lsp_call("add_workspace_folder"), opts("Add workspace folder"))
keymap.set("n", "<leader>LR", safe_lsp_call("remove_workspace_folder"), opts("Remove workspace folder"))
keymap.set("n", "<leader>LL", function()
	if vim.lsp.buf.list_workspace_folders then
		_G.print_custom(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	else
		_G.print_custom("LSP function 'list_workspace_folders' not available")
	end
end, opts("List workspace folders"))

-- Diagnostics

keymap.set("n", "<leader>Ld", "<cmd>Lspsaga show_line_diagnostics<CR>", opts("Show line diagnostic"))
keymap.set("n", "<leader>LD", "<cmd>Lspsaga show_workspace_diagnostics<CR>", opts("Show Workspace diagnostic"))
keymap.set("n", "<leader>Lb", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts("Go to previous diagnostic"))
keymap.set("n", "<leader>Ln", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts("Go to next diagnostic"))

-- Auto Formatting
keymap.set({ "n", "v" }, "<leader>LF", function()
	if vim.lsp.buf.format then
		vim.lsp.buf.format({ async = true })
	else
		_G.print_custom("LSP function 'format' not available")
	end
end, opts("Format buffer using LSP"))

-- More LSP Commands on <leader>l...
local d = "More LSP Commands on <leader>L... (Also disables search highlight)"
keymap.set("n", "<leader>lz", ":noh<CR>", opts(d))
keymap.set("n", "<leader>gz", ":noh<CR>", opts(d))

---------------------------------------------------------- Git
-- Lazygit
keymap.set("n", "<leader>lg", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- Undo Tree (Not git)
keymap.set("n", "<leader>u", function() require("undotree").toggle() end, opts("Toggle undo tree"))

-- Git History (Telescope)
keymap.set("n", "<leader>GC", builtin.git_commits, { desc = "Search Git Commits (Telescope)" })
keymap.set("n", "<leader>Gb", builtin.git_bcommits, { desc = "Search Buffer Commits (Telescope)" })

-- Git Status (Fugitive)
keymap.set("n", "<leader>Gf", ":Git<CR>", { desc = "Git status (Fugitive)" })

-- Git Mergetool
keymap.set("n", "<leader>Gm", ":Gvdiffsplit!<CR>", { desc = "Open Git Mergetool" })

-- Reset file to Git index version
keymap.set("n", "<leader>Gr", ":Gread<CR>", { desc = "Reset file to index version" })

-- Stage current file
keymap.set("n", "<leader>Gs", ":Gwrite<CR>", { desc = "Stage current file" })

-- Git Add All
keymap.set("n", "<leader>Ga", ":Git add .<CR>", { desc = "Stage all changes (git add .)" })
keymap.set("n", "<leader>GA", ":Git add --all<CR>", { desc = "Stage all changes (git add --all)" })

-- Git commit
keymap.set("n", "<leader>Gc", ":Git commit<CR>", { desc = "Git commit (Fugitive)" })
-- Git Push Current Branch
vim.keymap.set("n", "<leader>Gp", function()
	local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
	vim.cmd("Git push origin " .. branch)
end, { desc = "Push current branch to remote" })

-- Git log
keymap.set("n", "<leader>Gl", ":Git log --oneline<CR>", { desc = "Show Git log" })

-- Git blame (Avoids `<leader>gb` conflict)
keymap.set("n", "<leader>GB", ":Git blame<CR>", { desc = "Git blame (Fugitive)" })

local git_branches = function() require("neogit").open({ "branch" }) end
keymap.set("n", "<leader>Gg", git_branches, opts("Git branches side"))

---------------------------------------------- Diff keymaps
function ApplyDiffGet(version)
	-- This function is to apply the hunk of a buffer to output buffer
	-- Save current window
	local current_win = vim.api.nvim_get_current_win()
	-- Find the output buffer (should be the one without LOCAL, BASE, REMOTE)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
		if not bufname:match("_LOCAL_") and not bufname:match("_BASE_") and not bufname:match("_REMOTE_") then
			vim.api.nvim_set_current_win(win) -- Switch to output buffer
			vim.cmd("diffget " .. version) -- Apply diffget from LOCAL, BASE, or REMOTE
			vim.api.nvim_set_current_win(current_win) -- Return to previous window
			return
		end
	end
	_G.print_custom("Output buffer not found!")
end

----- Meld like hunk movement
local function get_adjacent_buf(direction)
	local current_win = vim.api.nvim_get_current_win()
	local wins = vim.api.nvim_list_wins()
	local current_x = vim.api.nvim_win_get_position(current_win)[2]

	local target_buf = nil
	for _, win in ipairs(wins) do
		if win ~= current_win then
			local win_x = vim.api.nvim_win_get_position(win)[2]
			if (direction == "left" and win_x < current_x) or (direction == "right" and win_x > current_x) then
				target_buf = vim.api.nvim_win_get_buf(win)
			end
		end
	end
	return target_buf
end

-- Function to pull a hunk from another buffer
local function pull_hunk(direction)
	local source_buf = get_adjacent_buf(direction)
	if source_buf then
		vim.cmd("diffget " .. source_buf) -- Explicitly pull from the correct buffer
	else
		_G.print_custom("No adjacent buffer found to the " .. direction)
	end
end

-- Function to get the adjacent window ID (left or right)
local function get_adjacent_win(direction)
	local current_win = vim.api.nvim_get_current_win()
	local wins = vim.api.nvim_list_wins()
	local current_x = vim.api.nvim_win_get_position(current_win)[2]

	local target_win = nil
	for _, win in ipairs(wins) do
		if win ~= current_win then
			local win_x = vim.api.nvim_win_get_position(win)[2]
			if (direction == "left" and win_x < current_x) or (direction == "right" and win_x > current_x) then
				target_win = win
			end
		end
	end
	return target_win
end

-- Function to push a hunk to another buffer
local function push_hunk(direction)
	local target_win = get_adjacent_win(direction) -- Get adjacent window ID
	local current_win = vim.api.nvim_get_current_win() -- Store current window
	local current_buf = vim.api.nvim_get_current_buf() -- Store current buffer

	if target_win then
		vim.api.nvim_set_current_win(target_win) -- Move to target buffer
		vim.cmd("diffget " .. current_buf) -- Pull hunk from the original buffer into this buffer
		vim.api.nvim_set_current_win(current_win) -- Return to the original window
	else
		_G.print_custom("No adjacent window found to the " .. direction)
	end
end

-- Function to apply a selected version's hunk to all other buffers
local function apply_hunk_to_all(version)
	local current_win = vim.api.nvim_get_current_win() -- Save the current window
	local output_win = nil

	-- Identify the output buffer
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
		if not bufname:match("_LOCAL_") and not bufname:match("_BASE_") and not bufname:match("_REMOTE_") then
			output_win = win
			break
		end
	end

	-- Apply diffget from the chosen version to all buffers except the output buffer
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local target_buf = vim.api.nvim_win_get_buf(win)
		if win ~= output_win then
			vim.api.nvim_set_current_win(win) -- Move to target buffer
			vim.cmd("diffget " .. version) -- Apply hunk from the selected version
		end
	end

	-- Apply the selected hunk to the output buffer without moving to the next hunk
	if output_win then
		vim.api.nvim_set_current_win(output_win) -- Move to output buffer
		vim.cmd("diffget " .. version) -- Apply hunk without changing cursor position
	end

	-- Return to the original window
	vim.api.nvim_set_current_win(current_win)
end

-- Function to detect the current buffer type and apply it to all buffers
local function apply_current_hunk_to_all()
	local bufname = vim.api.nvim_buf_get_name(0)

	if bufname:match("_LOCAL_") then
		apply_hunk_to_all("LOCAL")
	elseif bufname:match("_BASE_") then
		apply_hunk_to_all("BASE")
	elseif bufname:match("_REMOTE_") then
		apply_hunk_to_all("REMOTE")
	else
		_G.print_custom("Current buffer is not LOCAL, BASE, or REMOTE. Cannot apply hunk.")
	end
end

-- Function to push the current hunk into the final output buffer
local function push_to_output()
	local current_win = vim.api.nvim_get_current_win() -- Save current window
	local current_buf = vim.api.nvim_get_current_buf() -- Save current buffer
	local output_win = nil

	-- Find the output buffer window (should be the one without _LOCAL_, _BASE_, _REMOTE_)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
		if not bufname:match("_LOCAL_") and not bufname:match("_BASE_") and not bufname:match("_REMOTE_") then
			output_win = win
			break
		end
	end

	if output_win then
		vim.api.nvim_set_current_win(output_win) -- Switch to output buffer
		vim.cmd("diffget " .. current_buf) -- Pull hunk from the original buffer
		vim.api.nvim_set_current_win(current_win) -- Return to original buffer
	else
		_G.print_custom("Output buffer not found!")
	end
end

------ Setting the keymaps

local use_git_conflict = true

if use_git_conflict then
	-- Write it here

	local conflict = require("git-conflict")

	keymap.set("n", "<leader>kj", function() conflict.choose("ours") end, opts("Accept ours (HEAD)"))
	keymap.set("n", "<leader>kt", function() conflict.choose("theirs") end, opts("Accept theirs (incoming)"))
	keymap.set("n", "<leader>kb", function() conflict.choose("both") end, opts("Accept both"))
	keymap.set("n", "<leader>k0", function() conflict.choose("none") end, opts("Accept none"))

	keymap.set("n", "<leader>kb", function() conflict.find_prev("both") end, opts("Previous conflict (both)"))
	keymap.set("n", "<leader>kn", function() conflict.find_next("both") end, opts("Next conflict (both)"))

	keymap.set("n", "<leader>kB", function() conflict.find_prev("ours") end, opts("Previous conflict (ours/head)"))
	keymap.set("n", "<leader>kN", function() conflict.find_next("ours") end, opts("Previous conflict (ours/Head)"))

	keymap.set("n", "<leader>kv", function() conflict.find_prev("theirs") end, opts("Previous conflict (theirs/incoming)"))
	keymap.set("n", "<leader>kc", function() conflict.find_next("theirs") end, opts("Previous conflict (theirs/incoming)"))
end

if not use_git_conflict then
	-- Move it to the **current buffer** (LOCAL, BASE, REMOTE)
	keymap.set("n", "<leader>kL", ":diffget LOCAL<CR>", opts("Take LOCAL version into current buffer"))
	keymap.set("n", "<leader>kB", ":diffget BASE<CR>", opts("Take BASE version into current buffer"))
	keymap.set("n", "<leader>kR", ":diffget REMOTE<CR>", opts("Take REMOTE version into current buffer"))

	-- Move it to the **output buffer** (final merged file)
	keymap.set("n", "<leader>kl", function() ApplyDiffGet("LOCAL") end, opts("Apply LOCAL version to output buffer"))
	keymap.set("n", "<leader>kb", function() ApplyDiffGet("BASE") end, opts("Apply BASE version to output buffer"))
	keymap.set("n", "<leader>kr", function() ApplyDiffGet("REMOTE") end, opts("Apply REMOTE version to output buffer"))

	-- Push hunk to the left buffer
	keymap.set("n", "<leader>ka", function() push_hunk("left") end, opts("Push hunk to the left buffer"))

	-- Push hunk to the right buffer
	keymap.set("n", "<leader>kd", function() push_hunk("right") end, opts("Push hunk to the right buffer"))

	-- Pull hunk from the left buffer
	keymap.set("n", "<leader>kq", function() pull_hunk("left") end, opts("Pull hunk from the left buffer"))

	-- Pull hunk from the right buffer
	keymap.set("n", "<leader>ke", function() pull_hunk("right") end, opts("Pull hunk from the right buffer"))

	-- Function to push the current hunk into the final output buffer

	keymap.set("n", "<leader>kp", push_to_output, opts("Put current hunk into the final output buffer"))

	-- Jump to next conflict
	keymap.set("n", "<leader>kn", "]c", opts("Jump to next conflict"))

	-- Jump to previous conflict
	keymap.set("n", "<leader>kN", "[c", opts("Jump to previous conflict"))
	keymap.set("n", "<leader>kv", "[c", opts("Jump to previous conflict"))

	-- Apply LOCAL hunk to all buffers
	keymap.set("n", "<leader>kcl", function() apply_hunk_to_all("LOCAL") end, opts("Apply LOCAL hunk to all buffers"))
	-- Apply BASE hunk to all buffers
	keymap.set("n", "<leader>kcb", function() apply_hunk_to_all("BASE") end, opts("Apply BASE hunk to all buffers"))
	-- Apply REMOTE hunk to all buffers
	keymap.set("n", "<leader>kcr", function() apply_hunk_to_all("REMOTE") end, opts("Apply REMOTE hunk to all buffers"))
	-- Apply CURRENT buffer's hunk to all buffers
	keymap.set("n", "<leader>kC", apply_current_hunk_to_all, opts("Apply current buffer's hunk to all buffers"))

	-- Apply LOCAL hunk to all buffers
	keymap.set("n", "<leader>kf", function() apply_hunk_to_all("LOCAL") end, opts("Apply LOCAL hunk to all buffers"))
	-- Apply BASE hunk to all buffers
	keymap.set("n", "<leader>kg", function() apply_hunk_to_all("BASE") end, opts("Apply BASE hunk to all buffers"))
	-- Apply REMOTE hunk to all buffers
	keymap.set("n", "<leader>kh", function() apply_hunk_to_all("REMOTE") end, opts("Apply REMOTE hunk to all buffers"))
end

-- ---------------------------------------------ufo
local ufo = require("ufo")

-- Open/Close All Folds
keymap.set("n", "<leader>zE", ufo.openAllFolds, { desc = "Open all folds" })
keymap.set("n", "<leader>zQ", ufo.closeAllFolds, { desc = "Close all folds" })

-- Open/Close Fold Under Cursor
keymap.set("n", "<leader>ze", function() ufo.openFoldsExceptKinds({}) end, { desc = "Open fold under cursor" })

keymap.set("n", "<leader>zq", function() ufo.closeFoldsWith(1) end, { desc = "Close fold under cursor" })

-- Peek Folded Lines
keymap.set("n", "<leader>zK", function()
	local winid = ufo.peekFoldedLinesUnderCursor()
	if not winid then
		vim.lsp.buf.hover()
	end
end, { desc = "Peek Fold" })

-- Jump to Next/Previous Closed Fold
keymap.set("n", "<leader>zb", function() vim.fn.search("^\\zs.\\{-}\\ze\\n\\%($\\|\\s\\{2,}\\)", "W") end, { desc = "Jump to next closed fold" })

keymap.set("n", "<leader>zn", function() vim.fn.search("^\\zs.\\{-}\\ze\\n\\%($\\|\\s\\{2,}\\)", "bW") end, { desc = "Jump to previous closed fold" })

-------------------------------------------------------Filetype-specific keymaps
-- from https://github.com/bcampolo/nvim-starter-kit/blob/python/.config/nvim/lua/core/keymaps.lua
-- hence check ftplugin directory in that github thing

keymap.set("n", "<leader>go", function()
	if vim.bo.filetype == "python" then
		vim.api.nvim_command("PyrightOrganizeImports")
	end
end, { noremap = true, silent = true, desc = "Organize Python imports (Pyright)" })

--------------------------------------------- Debugging (nvim-dap)
-- Breakpoint Management

local dap = require("dap")
local dapui = require("dapui")
local widgets = require("dap.ui.widgets")

local function debug_next_function()
	local session = require("dap").session()
	if not session then
		_G.print_custom("❌ Debugger is not running!")
		return
	end

	if session.stopped_thread_id then
		-- Move to the next function call
		local next_call = goto_next_function_call()
		if not next_call then
			_G.print_custom("❌ No next function call found.")
			return
		end

		-- dap.set_breakpoint()
		-- dap.continue()
		dap.run_to_cursor()
	else
		_G.print_custom("⏸ Debugger must be paused before running to the next function call!")
	end
end

-- Breakpoint Keybindings
keymap.set("n", "<leader>bb", dap.toggle_breakpoint, opts("Toggle breakpoint at current line"))
keymap.set("n", "<leader>bc", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, opts("Set conditional breakpoint"))
keymap.set(
	"n",
	"<leader>bl",
	function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
	opts("Set log point (executes a log message instead of stopping execution)")
)
keymap.set("n", "<leader>br", dap.clear_breakpoints, opts("Clear all breakpoints"))
keymap.set("n", "<leader>ba", function() telescope.extensions.dap.list_breakpoints() end, opts("List all breakpoints (Telescope UI)"))

-- Debugging Stop/Disconnect
keymap.set("n", "<leader>dd", function()
	dap.disconnect()
	dap.close()
end, opts("Disconnect debugger (keep process running)"))

keymap.set("n", "<leader>dt", function()
	dap.terminate()
	dapui.close()
end, { desc = "Terminate debugging session (kill process)" })

_G.last_debugged_file = nil -- Store the last file debugged

local dap_run = function()
	-- Check if a DAP REPL buffer exists
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local buf_name = vim.api.nvim_buf_get_name(buf):lower()
		if buf_name:match("dap%-repl") then
			-- vim.api.nvim_set_current_win(win) -- Focus the REPL if it's already open
			goto evaluate
		end
	end

	-- Open REPL if it's not open
	dap.repl.open()

	::evaluate::
	local input_expr = vim.fn.input("Evaluate expression: ") -- Get input first
	if input_expr and input_expr ~= "" then
		local file_ext = _G.last_debugged_file or "" -- Use stored file extension
		vim.notify("\nfiletype: " .. file_ext)
		if file_ext == ".c" or file_ext == ".cpp" then
			input_expr = "-exec " .. input_expr -- Prefix with "-exec" for GDB-based debuggers
		end
		vim.notify("running " .. input_expr)
		dap.repl.execute(input_expr) -- Pass it to REPL
		-- wont show the diff though?
	end
end

-- Debugging Execution Keybindings
keymap.set("n", "<leader>dc", dap.continue, opts("--- Start/continue debugging session"))
keymap.set("n", "<leader>dj", dap.step_over, opts("--- Step over (skip function calls)"))
keymap.set("n", "<leader>dh", dap.step_into, opts("--- Step into function calls"))
keymap.set("n", "<leader>dl", dap.step_out, opts("--- Step out of current function"))

keymap.set("n", "<leader>di", dap.up, opts("backtrace one function (backtrace down)"))
keymap.set("n", "<leader>dk", dap.down, opts("retrace one function (backtrace up)"))

keymap.set("n", "<leader>dp", dap.pause, opts("--- Pause program execution"))
-- Reverse Continue (Run backwards until a breakpoint)
keymap.set("n", "<leader>db", dap.reverse_continue, opts("-- Reverse continue (run backward, previous breakpoint)"))
-- Reverse Step (Step back one line)
keymap.set("n", "<leader>dBl", dap.step_back, opts("--Step backward (previous line)"))
-- Reverse Step Instruction (Step back one assembly instruction)

keymap.set("n", "<leader>dC", dap.run_to_cursor, opts("Step to cursor"))
keymap.set("n", "<leader>df", debug_next_function, opts("execute untill next function call"))

-- Debugging Tools
keymap.set("n", "<leader>d.", function() dap.repl.toggle() end, opts("Toggle debugger REPL [Not Useful]"))
keymap.set("n", "<leader>dr", dap_run, opts("Evaluate expression in REPL"))
keymap.set("n", "<leader>dL", dap.run_last, opts("Re-run last debugging session"))
keymap.set("n", "<leader>dR", dap.restart, opts("Restart debugging session"))

keymap.set("n", "<leader>d$", widgets.hover, opts("Hover to inspect variable under cursor"))
keymap.set("n", "<leader>da", dapui.toggle, opts("Toggle DAP UI"))

keymap.set("n", "<leader>dv", function() widgets.centered_float(widgets.scopes) end, opts("Show debugging scopes (floating window)"))
-- keymap.set("n", "<leader>da", function() widgets.centered_float(widgets.variables) end, opts("Show all variables (floating window)"))
keymap.set("n", "<leader>dS", function() widgets.centered_float(widgets.frames) end, opts("Show call stack (floating window)"))

-- Telescope DAP Integrations
keymap.set("n", "<leader>ds", function() telescope.extensions.dap.frames() end, opts("Show stack frames (Telescope UI)"))
keymap.set("n", "<leader>dD", function() telescope.extensions.dap.commands() end, opts("List DAP commands (Telescope UI)"))

keymap.set("n", "<leader>de", function() builtin.diagnostics({ default_text = ":E:" }) end, opts("Show Errors and diagnostics (Telescope UI)"))
keymap.set("n", "<leader>dw", function() builtin.diagnostics({ default_text = ":W:" }) end, opts("Show Warning and diagnostics (Telescope UI)"))
keymap.set("n", "<leader>dH", function() builtin.diagnostics({ default_text = ":H:" }) end, opts("Show Hints and diagnostics (Telescope UI)"))

keymap.set("n", "<leader>dm", function() telescope.extensions.dap.threads() end, opts("Show running threads (Telescope UI)"))

-- Tests
keymap.set("n", "<leader>dTc", function()
	if vim.bo.filetype == "python" then
		require("dap-python").test_class()
	end
end)

keymap.set("n", "<leader>dTm", function()
	if vim.bo.filetype == "python" then
		require("dap-python").test_method()
	end
end)

----------------------------------------------------- Terminal (PICK ONE) ---------------------------

---------------------------------------------- Terminal File Manager -----------------------------------
-- tfm_keymaps.lua
local tfm = require("tfm")
vim.keymap.set("n", "<leader>lf", tfm.open, opts("Open lf (file manager)"))
vim.keymap.set("n", "<leader>rr", tfm.open, opts("TFM"))
vim.keymap.set("n", "<leader>rv", function() tfm.open(nil, tfm.OPEN_MODE.split) end, opts("TFM - horizontal split"))
vim.keymap.set("n", "<leader>rh", function() tfm.open(nil, tfm.OPEN_MODE.vsplit) end, opts("TFM - vertical split"))
vim.keymap.set("n", "<leader>rt", function() tfm.open(nil, tfm.OPEN_MODE.tabedit) end, opts("TFM - new tab"))
-------- ToggleTerm: ---------

local Terminal = require("toggleterm.terminal").Terminal

-- Toggle floating terminal
keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", opts("Floating Terminal"))
-- <C-t>
-- "$HOME/.config/nvim/lua/core/plugin_config/toggleterm.lua"

-- Toggle horizontal split terminal
keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=horizontal<CR>", opts("Horizontal Terminal"))

-- Toggle vertical split terminal
keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=vertical<CR>", opts("Vertical Terminal"))

local float_term = Terminal:new({
	direction = "float",
	hidden = true,
	float_opts = {
		border = "rounded",
		width = math.floor(vim.o.columns * 0.45),
		height = math.floor(vim.o.lines * 0.45),
		row = 0,
		col = 0,
	},
})

local function reposition_terminal(term, opts)
	term.float_opts = vim.tbl_deep_extend("force", term.float_opts or {}, opts)
	if term:is_open() then
		term:close()
		vim.defer_fn(function() term:open() end, 10) -- small delay to ensure reopen
	else
		term:open()
	end
end

local function move_float_terminal(position)
	local cols = vim.o.columns
	local lines = vim.o.lines

	local positions = {
		topleft = { row = 0, col = 0 },
		topright = { row = 0, col = math.floor(cols * 0.55) },
		bottomleft = { row = math.floor(lines * 0.55), col = 0 },
		bottomright = { row = math.floor(lines * 0.55), col = math.floor(cols * 0.55) },
	}

	local pos = positions[position]
	if not pos then
		vim.notify("Invalid terminal position: " .. position, vim.log.levels.ERROR)
		return
	end

	reposition_terminal(float_term, {
		width = math.floor(cols * 0.45),
		height = math.floor(lines * 0.45),
		border = "rounded",
		row = pos.row,
		col = pos.col,
	})
end

vim.keymap.set("n", "<leader>tu", function() move_float_terminal("topleft") end, { desc = "Float Terminal Top Left" })
vim.keymap.set("n", "<leader>to", function() move_float_terminal("topright") end, { desc = "Float Terminal Top Right" })
vim.keymap.set("n", "<leader>tj", function() move_float_terminal("bottomleft") end, { desc = "Float Terminal Bottom Left" })
vim.keymap.set("n", "<leader>tl", function() move_float_terminal("bottomright") end, { desc = "Float Terminal Bottom Right" })

vim.keymap.set("n", "<leader>tb", function() move_float_terminal("bottomright") end, { desc = "Float Terminal Bottom Right" })

-- keymap.set("t", "<Esc>", "<C-\\><C-n>", opts("Make escape work"))
-- keymap.set("t", "q", "<Esc>", opts("make q leave lf. this fucks cli typing"))
-- keymap.set("t", "QQ", [[<C-\><C-n>:q<CR>]], opts("Leave the terminal"))
keymap.set("t", "jk", "<C-\\><C-n>", opts("make jk = go to normal mode"))

-- vim.api.nvim_create_autocmd("TermOpen", {
-- 	pattern = "*",
-- 	callback = function() vim.keymap.set("n", "QQ", ":bd!<CR>", { noremap = true, silent = true, buffer = 0, desc = "Leave the terminal" }) end,
-- })

--------------------------------------Tmux
-- Detect the OS
local uname = vim.loop.os_uname()
local is_windows = uname.sysname == "Windows_NT"

if is_windows then
	-- Windows-specific keymaps
	keymap.set("", "<C-s>j", ":wincmd h<CR>")
	keymap.set("", "<C-s>k", ":wincmd j<CR>")
	keymap.set("", "<C-s>i", ":wincmd k<CR>")
	keymap.set("", "<C-s>l", ":wincmd l<CR>")
	keymap.set("", "<C-s>,", ":wincmd p<CR>")
	keymap.set("", "<C-s>Space", ":wincmd w<CR>")

	keymap.set("", "<C-s><Left>", ":wincmd h<CR>")
	keymap.set("", "<C-s><Down>", ":wincmd j<CR>")
	keymap.set("", "<C-s><Up>", ":wincmd k<CR>")
	keymap.set("", "<C-s><Right>", ":wincmd l<CR>")

	keymap.set("", "<C-w>j", ":wincmd h<CR>")
	keymap.set("", "<C-w>k", ":wincmd j<CR>")
	keymap.set("", "<C-w>i", ":wincmd k<CR>")
	keymap.set("", "<C-w>l", ":wincmd l<CR>")

	keymap.set("", "<C-w><Left>", ":wincmd h<CR>")
	keymap.set("", "<C-w><Down>", ":wincmd j<CR>")
	keymap.set("", "<C-w><Up>", ":wincmd k<CR>")
	keymap.set("", "<C-w><Right>", ":wincmd l<CR>")
else
	-- Linux-specific keymaps (using nvim-tmux navigator)
	keymap.set("", "<C-s>j", Nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-s>k", Nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-s>i", Nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-s>l", Nvim_tmux_nav.NvimTmuxNavigateRight)
	keymap.set("", "<C-s>,", Nvim_tmux_nav.NvimTmuxNavigateLastActive)
	keymap.set("", "<C-s>Space", Nvim_tmux_nav.NvimTmuxNavigateNext)

	keymap.set("", "<C-s><Left>", Nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-s><Down>", Nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-s><Up>", Nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-s><Right>", Nvim_tmux_nav.NvimTmuxNavigateRight)

	keymap.set("", "<C-w>j", Nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-w>k", Nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-w>i", Nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-w>l", Nvim_tmux_nav.NvimTmuxNavigateRight)

	keymap.set("", "<C-w><Left>", Nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-w><Down>", Nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-w><Up>", Nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-w><Right>", Nvim_tmux_nav.NvimTmuxNavigateRight)
end

local function focus_floating_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative ~= "" then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
end

local function focus_normal_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "" then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
end
vim.keymap.set("n", "<C-w>z", focus_floating_win, opts("Move to floating window"))
vim.keymap.set("n", "<C-x>Z", focus_normal_win, opts("Move to normal split"))

------------------------------ NOTES --------------------------

---------------  ✍️ Markdown Preview Toggle
keymap.set("n", "<leader>mt", ":Markview Toggle<CR>", opts("Toggle Markdown Preview"))
keymap.set("n", "<leader>ms", ":Markview Start<CR>", opts("Start Markdown Preview"))
keymap.set("n", "<leader>me", ":Markview Enable<CR>", opts("Enable Markdown Preview Globally"))
keymap.set("n", "<leader>md", ":Markview Disable<CR>", opts("Disable Markdown Preview Globally"))
keymap.set("n", "<leader>ma", ":Markview attach<CR>", opts("Attach to Current Buffer"))
keymap.set("n", "<leader>mx", ":Markview detach<CR>", opts("Detach from Current Buffer"))
keymap.set("n", "<leader>mp", ":Markview Render<CR>", opts("Render Markdown Preview"))
keymap.set("n", "<leader>mc", ":Markview Clear<CR>", opts("Clear Markdown Preview"))

-- 🔄 Split View Mode
keymap.set("n", "<leader>mo", ":Markview splitOpen<CR>", opts("Open Split View"))
keymap.set("n", "<leader>mC", ":Markview splitClose<CR>", opts("Close Split View"))
keymap.set("n", "<leader>mT", ":Markview splitToggle<CR>", opts("Toggle Split View"))
keymap.set("n", "<leader>mr", ":Markview splitRedraw<CR>", opts("Redraw Split View"))

-- 🔍 Debugging / Logs
keymap.set("n", "<leader>mDx", ":MarkView traceExport<CR>", opts("Export Trace Logs"))
keymap.set("n", "<leader>mDs", ":MarkView traceShow<CR>", opts("Show Trace Logs"))

--------------- 📄 LaTeX (Vimtex)
-- ✍️ VimTeX Keybindings (Explicit)
keymap.set("n", "<leader>la", ":VimtexContextMenu<CR>", opts("Open VimTeX Context Menu"))
keymap.set("n", "<leader>lc", ":VimtexClean<CR>", opts("Clean Auxiliary Files"))
keymap.set("n", "<leader>lC", ":VimtexClean!<CR>", opts("Full Clean (Includes PDF)"))
keymap.set("n", "<leader>le", ":VimtexErrors<CR>", opts("Show VimTeX Errors"))
keymap.set("n", "<leader>lG", ":VimtexStatusAll<CR>", opts("Show Status for All VimTeX Sessions"))
keymap.set("n", "<leader>li", ":VimtexInfo<CR>", opts("Show VimTeX Info"))
keymap.set("n", "<leader>lI", ":VimtexInfo!<CR>", opts("Show Full VimTeX Info"))
keymap.set("n", "<leader>lk", ":VimtexStop<CR>", opts("Stop Current Compilation"))
keymap.set("n", "<leader>lK", ":VimtexStopAll<CR>", opts("Stop All VimTeX Sessions"))
keymap.set("n", "<leader>ll", ":VimtexCompile<CR>", opts("Start/Continue Compilation"))
keymap.set("n", "<leader>lL", ":VimtexCompileSelected<CR>", opts("Compile Selected Text"))
keymap.set("n", "<leader>lm", ":VimtexImapsList<CR>", opts("List VimTeX Input Mappings"))
keymap.set("n", "<leader>lo", ":VimtexCompileOutput<CR>", opts("Show Compilation Output"))
keymap.set("n", "<leader>lq", ":VimtexLog<CR>", opts("Show Log File"))
keymap.set("n", "<leader>ls", ":VimtexToggleMain<CR>", opts("Toggle Main File"))
keymap.set("n", "<leader>lt", ":VimtexTocOpen<CR>", opts("Open Table of Contents"))
keymap.set("n", "<leader>lT", ":VimtexTocToggle<CR>", opts("Toggle Table of Contents"))
keymap.set("n", "<leader>lv", ":VimtexView<CR>", opts("View PDF"))
keymap.set("n", "<leader>lx", ":VimtexReload<CR>", opts("Reload VimTeX Project"))
keymap.set("n", "<leader>lX", ":VimtexReloadState<CR>", opts("Reload VimTeX State"))

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
---------------------------------------START OF MY PERSONAL TWEAKS------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

function Replace_with_input()
	local old_char = vim.fn.input("Replace character: ")
	local new_char = vim.fn.input("Replace with: ")
	if old_char ~= "" and new_char ~= "" then
		vim.cmd(string.format("%%s/%s/%s/g", old_char, new_char))
	end
end

function Replace_with_confirmation()
	local old_char = vim.fn.input("Replace character: ")
	local new_char = vim.fn.input("Replace with: ")
	if old_char ~= "" and new_char ~= "" then
		-- Execute substitution with confirmation for each match
		vim.cmd(string.format("%%s/%s/%s/gc", old_char, new_char))
	end
end

-- Bind the function to <C-H>
keymap.set("n", "<C-g>", "<Cmd>lua Replace_with_confirmation()<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-h>", "<Cmd>lua Replace_with_input()<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>rc", "<Cmd>lua Replace_with_confirmation()<CR>", { noremap = true, silent = true, desc = "Replace with confirmation" })
keymap.set("n", "<leader>ry", "<Cmd>lua Replace_with_input()<CR>", { noremap = true, silent = true, desc = "Replace with input" })

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	callback = function()
		vim.keymap.del("n", "<Leader>rwp")
		vim.keymap.del("n", "<Plug>RestoreWinPosn")
	end,
})

keymap.set("n", "<C-j>", ":lua require('spectre').open()<CR>", opts("search and replace functions"))
vim.keymap.set("n", "<leader>rw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
	desc = "Search current word",
})
vim.keymap.set("v", "<leader>rw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
	desc = "Search current word",
})
keymap.set("n", "<leader>W", ":lua require('spectre').open()<CR>", opts("search and replace functions"))
-- leader>W for word operation.
vim.keymap.set("n", "<leader>nh", function() require("mini.notify").show_history() end, { desc = "Show mini.notify history" })

-- Lua function for interactive replacement
function ReplaceFrancois()
	local search_pattern = "/home/francois"
	local replacement = "$HOME"

	-- Run the substitute command interactively
	vim.cmd(string.format("%%s/%s/%s/gc", vim.fn.escape(search_pattern, "/"), vim.fn.escape(replacement, "/")))
end

-- Command to trigger the replacement function
vim.api.nvim_create_user_command("ReplaceFrancois", ReplaceFrancois, {})

----------------------------------------------------------- Identity keybinds (Manual of what to do)
-- In some group, there are id keybinds. This is for entire group. Basically, to show entire new functions

-- top/bottom/center - Center the screen on the current line, aligning it to the bottom of the window
-- no remaps, just a remainder for myself
keymap.set("n", "zt", "zt", { noremap = true, silent = true })
keymap.set("n", "zz", "zz", { noremap = true, silent = true })
keymap.set("n", "zb", "zb", { noremap = true, silent = true })
------------------------------------------ SYMBOL SEARCH FUNCTION FOR MACROS ---------------

-- Function to fetch symbols (LSP + buffer fallback)

local function get_local_variables()
	local parser = vim.treesitter.get_parser(0, "c") -- Treesitter for C
	local tree = parser:parse()[1]
	local root = tree:root()
	local locals = {}

	local function traverse(node)
		-- Look for function definitions
		if node:type() == "function_definition" then
			local function_name_node = node:child(1) -- Function name is usually the second child
			local function_name = function_name_node and vim.treesitter.get_node_text(function_name_node, 0) or "<unknown>"

			-- Find local variables inside function body
			local function_body = node:child(node:child_count() - 1) -- Usually last child is the function body

			if function_body and function_body:type() == "compound_statement" then
				for var_decl in function_body:iter_children() do
					if var_decl:type() == "declaration" then
						local var_name_node = var_decl:child(1) -- Variable name is usually second child
						if var_name_node and var_name_node:type() == "identifier" then
							local var_name = vim.treesitter.get_node_text(var_name_node, 0)
							table.insert(locals, { name = var_name, kind = "Local Variable", scope = function_name })
						end
					end
				end
			end
		end

		-- Recursively check all children
		for child in node:iter_children() do
			traverse(child)
		end
	end

	traverse(root)
	return locals
end

local function get_symbols()
	local symbols = {}

	-- 🔹 1. Fetch top-level and function-local symbols from LSP
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	local lsp_results = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
	if lsp_results then
		for _, server in pairs(lsp_results) do
			for _, item in pairs(server.result or {}) do
				-- Add top-level symbols
				table.insert(symbols, {
					name = item.name,
					kind = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown",
				})

				-- 🔹 If a symbol has children (e.g., function-local vars), add them
				if item.children then
					for _, child in pairs(item.children) do
						table.insert(symbols, {
							name = child.name,
							kind = vim.lsp.protocol.SymbolKind[child.kind] or "Local Variable",
						})
					end
				end
			end
		end
	end

	-- 🔹 2. Fetch Local Variables via Treesitter
	for _, local_var in ipairs(get_local_variables()) do
		table.insert(symbols, local_var)
	end

	-- 🔹 3. Try fetching workspace symbols (across imported files)
	local workspace_results = vim.lsp.buf_request_sync(0, "workspace/symbol", { query = "" }, 1000)
	if workspace_results then
		for _, server in pairs(workspace_results) do
			for _, item in pairs(server.result or {}) do
				table.insert(symbols, {
					name = item.name,
					kind = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown",
				})
			end
		end
	end

	-- 🔹 4. Fallback: Extract words from buffer if no LSP symbols
	if #symbols == 0 then
		local word_set = {}
		for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
			for word in line:gmatch("[A-Za-z_][A-Za-z0-9_]*") do
				if not word_set[word] then
					table.insert(symbols, { name = word, kind = "Buffer Word" })
					word_set[word] = true
				end
			end
		end
	end

	return symbols
end

-- Function to show symbols in Telescope and call `callback` with the selected symbol
local function select_symbol(callback)
	local symbols = get_symbols()

	if #symbols == 0 then
		_G.print_custom("No symbols found!")
		return
	end

	pickers
		.new({}, {
			prompt_title = "Select Symbol",
			finder = finders.new_table({
				results = symbols,
				entry_maker = function(entry)
					return {
						value = entry.name,
						display = entry.name .. " (" .. entry.kind .. ")",
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(_, map)
				map("i", "<CR>", function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and callback then
						callback(selection.value) -- Call the callback function with selected value
					end
				end)
				return true
			end,
		})
		:find()
end

local function get_variable_name(callback)
	select_symbol(callback) -- Calls select_symbol and passes `callback`
end

--------------------------------- WRITE FUNCTIONS MACRO --------------------------------------

_G.debug_utils = {}

local function get_indent()
	local indent_level = vim.fn.indent(".") -- Get indentation level in spaces
	local tab_width = vim.o.shiftwidth > 0 and vim.o.shiftwidth or vim.o.tabstop

	if vim.o.expandtab then
		return string.rep(" ", indent_level) -- Use spaces if expandtab is set
	else
		local num_tabs = math.floor(indent_level / tab_width)
		local num_spaces = indent_level % tab_width
		return string.rep("\t", num_tabs) .. string.rep(" ", num_spaces) -- Use actual tabs if expandtab is off
	end
end

-- Simple write function to print variable name and value.
function _G.debug_utils.write_function_simple()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local print_statement = string.format("%sprint(f'%s = {%s}')", indent, input, input)
			vim.api.nvim_put({ print_statement }, "l", true, true)
		end
	end)
end

-- Write function for NumPy variables to print shape and value.
function _G.debug_utils.write_function_numpy()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sprint(f'np.shape(%s) = {np.shape(%s)}')
%sprint(f'%s = \n{%s}\n')]],
				indent,
				input,
				input,
				indent,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

-- Function to write debug prints for max, mean, std dev of a variable
function _G.debug_utils.write_function_stats()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sprint(f"max(%s) = {np.max(%s)}, mean(%s) = {np.mean(%s)}, std(%s) = {np.std(%s)}")]],
				indent,
				input,
				input,
				input,
				input,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

-- Write function for NumPy variables to print shape and value (new line version).
function _G.debug_utils.write_function_np_newline()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sprint(f'np.shape(%s) = {np.shape(%s)}')
%sprint(f'%s = \n{%s}\n')]],
				indent,
				input,
				input,
				indent,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

function _G.debug_utils.write_function_newline()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local print_statement = string.format("%sprint(f'%s = \\n{%s}\\n')", indent, input, input)
			vim.api.nvim_put({ print_statement }, "l", true, true)
		end
	end)
end

-- Enhanced debug function for more robust NumPy variable checks.
function _G.debug_utils.write_function_debug()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			local debug_code = string.format(
				[[%sif DEBUG_:
%s print(f'type(%s) = {type(%s)}')
%s	try:
%s	 print(f'np.shape(%s) = {np.shape(%s)}')
%s	except Exception as e:
%s	 print('Some error about not having a shape:', e)
%s 	 print(f'%s = \n{%s}\n')]],
				indent,
				indent,
				input,
				input,
				indent,
				indent,
				input,
				input,
				indent,
				indent,
				indent,
				input,
				input
			)
			vim.api.nvim_put(vim.split(debug_code, "\n"), "l", true, true)
		end
	end)
end

-- Function to show symbols in Telescope and jump to the selected one
local function select_symbol_and_jump()
	local symbols = get_symbols()

	if #symbols == 0 then
		_G.print_custom("❌ No symbols found!")
		return
	end

	pickers
		.new({}, {
			prompt_title = "Select Symbol",
			finder = finders.new_table({
				results = symbols,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.name .. " (" .. entry.kind .. ")",
						ordinal = entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(_, map)
				map("i", "<CR>", function(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection and selection.value then
						vim.cmd("normal! gg") -- Move to top before searching
						vim.fn.search("\\<" .. selection.value.name .. "\\>", "w") -- Search for symbol
					end
				end)
				return true
			end,
		})
		:find()
end

select_and_write_function = function()
	builtin.treesitter({
		default_text = ":function:",
		attach_mappings = function(_, map)
			local insert_function_call = function(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection and selection.value then
					local func_name_and_symbol_type = selection.ordinal or selection.display or "unknown"
					-- local func_name = selection.display
					local func_name = vim.split(func_name_and_symbol_type, "%s+")[1]
					_G.print_custom("the function name is: \n" .. vim.inspect(func_name))
					vim.api.nvim_put({ func_name .. "()" }, "", true, true)
				end
			end

			map("i", "<CR>", insert_function_call)
			map("n", "<CR>", insert_function_call)

			return true
		end,
	})
end

---- Bind the functions to keymaps -----
keymap.set("n", "<leader>wfs", _G.debug_utils.write_function_simple, opts("Write Function Simple"))
keymap.set("n", "<leader>wfn", _G.debug_utils.write_function_numpy, opts("Write Function Numpy"))
keymap.set("n", "<leader>wfN", _G.debug_utils.write_function_np_newline, opts("Write Function Numpy NewLine"))
keymap.set("n", "<leader>wfl", _G.debug_utils.write_function_newline, opts("Write Function NewLine"))
keymap.set("n", "<leader>wfd", _G.debug_utils.write_function_debug, opts("Write Function Debug"))
keymap.set("n", "<leader>wfS", _G.debug_utils.write_function_stats, opts("Write Function Stats"))

keymap.set("n", "<leader>ss", get_function_calls, opts("jump to selected symbols"))
keymap.set("n", "<leader>ef", select_and_write_function, opts("select and write function"))
keymap.set("n", "<leader>er", select_and_write_function, opts("select and write function"))
--------------------------------- GENERAL UTILS MACRO --------------------------------------
function _G.general_utils_franck.not_invert()
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
		_G.print_custom("NotInvert: No matching word to invert")
	end
end

function _G.general_utils_franck.search_word(direction)
	-- Get the word under the cursor
	local word = vim.fn.expand("<cword>")
	if word == nil or word == "" then
		_G.print_custom("No word under cursor!")
		return
	end

	-- Perform the search
	local found = false
	if direction == "next" then
		found = vim.fn.search("\\V" .. vim.fn.escape(word, "\\"), "W") -- Case-sensitive forward search
	elseif direction == "prev" then
		found = vim.fn.search("\\V" .. vim.fn.escape(word, "\\"), "bW") -- Case-sensitive backward search
	else
		_G.print_custom("Invalid direction: Use 'next' or 'prev'")
		return
	end

	if found ~= 0 then
		_G.print_custom("Found word: " .. word)
	else
		_G.print_custom("Word not found: " .. word)
	end
end

-- Bind to functions for next and previous search
function _G.general_utils_franck.SearchNextWord() _G.general_utils_franck.search_word("next") end

function _G.general_utils_franck.SearchPrevWord() _G.general_utils_franck.search_word("prev") end

-- Function to copy the full file path
function _G.general_utils_franck.CopyFilePath()
	local path = vim.fn.expand("%:p") -- Get absolute file path
	vim.fn.setreg("+", path) -- Copy to system clipboard
	_G.print_custom("Copied file path: " .. path)
end

-- Function to copy the directory path
function _G.general_utils_franck.CopyDirPath()
	local dir = vim.fn.expand("%:p:h") -- Get directory path of current file
	vim.fn.setreg("+", dir) -- Copy to system clipboard
	_G.print_custom("Copied directory path: " .. dir)
end

function _G.general_utils_franck.cdHere()
	local file_path = vim.fn.expand("%:p")
	local dir_to_cd = nil

	if file_path ~= "" then
		-- Buffer has a file loaded, cd to its parent dir
		dir_to_cd = vim.fn.fnamemodify(vim.fn.resolve(file_path), ":p:h")
	else
		-- No file in buffer; check if first CLI argument is a dir
		local first_arg = vim.fn.argv(0)
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

	if tapi and tapi.tree and tapi.tree.change_root then
		tapi.tree.change_root(dir_to_cd) -- Sync Nvim-Tree, if available
	end

	_G.print_custom("Changed directory to: " .. dir_to_cd)
end

keymap.set("n", "<leader>cd", _G.general_utils_franck.cdHere, opts("cd to current dir (in tabs)"))

vim.api.nvim_create_user_command("CdHere", general_utils_franck.cdHere, { desc = "Cd to current working directory" })

keymap.set("n", "<leader>ni", _G.general_utils_franck.not_invert, opts("Invert true/false under cursor"))
keymap.set("n", "<Leader>cf", _G.general_utils_franck.CopyFilePath, opts("Copy file path to clipboard"))
keymap.set("n", "<Leader>cp", _G.general_utils_franck.CopyDirPath, opts("Copy directory path to clipboard"))
keymap.set("n", "<leader><Left>", _G.general_utils_franck.SearchPrevWord, opts("Search Previous occurance of this word"))
keymap.set("n", "<leader><Right>", _G.general_utils_franck.SearchNextWord, opts("Search next occurance of this word"))

keymap.set(
	"n",
	"<leader>rd",
	function() _G.print_custom("LSP Root Directory: " .. (_G.MyRootDir or "Not detected")) end,
	{ desc = "Print LSP Root Directory" }
)

----------------------------------------------- END OF CONFIG FILE

-- _G.print_custom("Vim configuration reloaded")
--print(vim.env.TERM)
