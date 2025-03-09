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
----------------------------------------- Clipboard
-- keymap.set("n", "<leader>y", '"+y', { noremap = true, silent = true })
-- keymap.set("v", "<leader>y", '"+y', { noremap = true, silent = true })
-- keymap.set("n", "<leader>yy", '"+yy', { noremap = true, silent = true })
keymap.set("n", "<leader>C", '"+yy', { noremap = true, silent = true })
keymap.set("v", "<leader>C", '"+yy', { noremap = true, silent = true })
keymap.set("n", "<leader>P", '"+p', { noremap = true, silent = true })
keymap.set("v", "<leader>P", '"+p', { noremap = true, silent = true })

keymap.set("n", "<C-c>", '"+y', { noremap = true, silent = true })
keymap.set("n", "<C-x>", '"+d', { noremap = true, silent = true })

keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true })
keymap.set("v", "<C-x>", '"+d', { noremap = true, silent = true })

keymap.set("", "<C-C>", '"+y', { noremap = true, silent = true })
keymap.set("", "<C-V>", '"+p', { noremap = true, silent = true })
-- Select all text (Help when vscode loads this)
keymap.set("", "<C-a>", "ggVG<CR>", { noremap = true, silent = true })
keymap.set("", "<C-w>a", "ggVG<CR>", { noremap = true, silent = true })

keymap.set("", "<C-c>", '"+y', { noremap = true, silent = true })
keymap.set("", "<C-x>", '"+d', { noremap = true, silent = true })
keymap.set("", "<C-V>", '"+p', { noremap = true, silent = true })
-- Bind Backspace to '_d' in visual mode (so it cut to the empty register = delete )
keymap.set("v", "<BS>", '"_d', { noremap = true, silent = true })

---------------------- Fixes
-- To have access to a way to increase an number
keymap.set("n", "<leader>u", "<C-a>", { noremap = true, silent = true })
-- Remap Ctrl+v to Ctrl+q in all modes so block visual mode works
keymap.set({ "" }, "<C-v>", "<C-q>", { noremap = true, silent = true })

----------------------Others ----------------------------
-- Function to get the current file path and copy to clipboard
function copy_current_file_path()
	local file_path = vim.fn.expand("%:p") -- Get the absolute path of the current file
	vim.fn.setreg("+", file_path) -- Copy to system clipboard (+ register)
	vim.api.nvim_echo({ { "File path copied: " .. file_path, "Normal" } }, false, {})
end

local function execute_current_file()
	local file_path = vim.api.nvim_buf_get_name(0) -- Get the full file path
	vim.cmd("! " .. vim.fn.shellescape(file_path)) -- Run it in the shell
end

function RunCurrentFile()
	local filepath = vim.api.nvim_buf_get_name(0) -- Get the full file path
	local file_ext = vim.fn.fnamemodify(filepath, ":e") -- Get the file extension

	if file_ext == "sh" then
		-- Run Bash script
		vim.cmd("!bash " .. vim.fn.shellescape(filepath))
	elseif file_ext == "c" then
		-- Compile and run C file
		local executable = vim.fn.shellescape(filepath:gsub("%.c$", ""))
		vim.cmd("!gcc " .. vim.fn.shellescape(filepath) .. " -o " .. executable .. " && " .. executable)
	elseif file_ext == "cpp" then
		-- Compile and run C file
		local executable = vim.fn.shellescape(filepath:gsub("%.cpp$", ""))
		vim.cmd("!g++ " .. vim.fn.shellescape(filepath) .. " -o " .. executable .. " && " .. executable)
	elseif file_ext == "py" then
		-- Run Python script
		vim.cmd("!python3 " .. vim.fn.shellescape(filepath))
	elseif file_ext == "java" then
		local home = vim.fn.expand("$HOME")
		local AutoMakeJava_location = "/Documents/University (Real)/Semester 10/Comp 303/AutomakeJava"
		local autoMakeScript = home .. AutoMakeJava_location .. "/mysrc/automake.py"
		vim.cmd("!python3 " .. vim.fn.shellescape(autoMakeScript) .. " " .. vim.fn.shellescape(filepath))
	else
		print("File type not supported for running with F4")
	end
end

-- Function to run the build script with the current file
local function run_build_script_with_file()
	local file_path = vim.api.nvim_buf_get_name(0) -- Get the full file path
	vim.cmd("!bash ./build.sh " .. vim.fn.shellescape(file_path))
end

-- Function to run the build test script with the current file
local function run_build_test_script()
	local file_path = vim.api.nvim_buf_get_name(0) -- Get the full file path
	vim.cmd("!bash ./build_test.sh " .. vim.fn.shellescape(file_path))
end

local function run_build_script() vim.cmd("!bash ./build.sh") end

keymap.set("n", "<F1>", copy_current_file_path, opts("Copy current file path"))
keymap.set("n", "<F2>", execute_current_file, opts("Stupidly execute current file"))
keymap.set("n", "<F4>", RunCurrentFile, opts("Run current file"))
keymap.set("n", "<F5>", run_build_script, opts("Run build script (No argument) - (build.sh)"))
keymap.set("n", "<F6>", run_build_script_with_file, opts("Run build script (with this file as argument) - (build.sh $thisFile)"))
keymap.set("n", "<F7>", run_build_test_script, opts("Run test script (with this file as argument) - (build_test.sh $thisFile)"))

-- Key mapping to source the current file (Only works for reloading nvim configuration)
keymap.set("n", "<leader>sr", ":source %<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>tt", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
keymap.set("n", "+", ":Oil<CR>", { noremap = true, silent = true })

--- Weird stuff

local toggle_invisible_char = function()
	vim.opt.list = not vim.opt.list:get()
	print("List mode: " .. (vim.opt.list:get() and "ON" or "OFF"))
end

local toggle_linting = function()
	if vim.g.linting_enabled then
		vim.diagnostic.enable()
		print("🔍 Linting Enabled")
	else
		vim.diagnostic.enable(false)
		print("🚫 Linting Disabled")
	end
	vim.g.linting_enabled = not vim.g.linting_enabled
end

keymap.set("n", " leader>.F", ":NvimTreeFindFile<CR>", opts("Find current file in NvimTree"))
keymap.set("n", "<leader>.s", "<C-t>", opts("Toggle tag stack"))

keymap.set("n", "<leader>.t", ":TestNearest<CR>", opts("Run nearest test"))
keymap.set("n", "<leader>.T", ":TestFile<CR>", opts("Run test file"))

keymap.set("n", "<leader>.c", ":AnsiEsc<CR>", opts("Toggle ANSI escape highlighting"))
keymap.set("n", "<leader>.h", ":lua require('nvim-highlight-colors').toggle()<CR>", opts("Toggle ANSI color parsing"))

keymap.set("n", "<leader>.i", toggle_invisible_char, opts("Toggle invisible characters"))
vim.keymap.set("n", "<leader>.l", toggle_linting, opts("Toggle Lint"))

--------------------- General keymaps
local bufremove = require("mini.bufremove") -- Load once
keymap.set("n", "<leader>wq", ":wa | qa<CR>") -- save and quit
-- keymap.set("n", "<leader>qq", ":q!<CR>") -- quit without saving
vim.keymap.set("n", "<leader>q", function() bufremove.delete(0, false) end, opts("Close current buffer"))
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
-- I don't use tabs (but hey)
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

local has_bufferline, _ = pcall(require, "bufferline")
local has_barbar, _ = pcall(require, "barbar")

local function goto_buffer(_) end
if has_bufferline then
	-- print("Using Bufferline")
	-- Bufferline keymaps
	vim.keymap.set("n", "<C-n>", "<Cmd>BufferLineCycleNext<CR>", opts("Next buffer (Bufferline)"))
	vim.keymap.set("n", "<C-b>", "<Cmd>BufferLineCyclePrev<CR>", opts("Previous buffer (Bufferline)"))
	vim.keymap.set("n", "<leader>B", "<Cmd>BufferLineMovePrev<CR>", opts("Move buffer left (Bufferline)"))
	vim.keymap.set("n", "<leader>N", "<Cmd>BufferLineMoveNext<CR>", opts("Move buffer right (Bufferline)"))

	goto_buffer = function(buf_num) vim.cmd("BufferLineGoToBuffer " .. buf_num) end
elseif has_barbar then
	-- print("Using Barbar")
	-- Barbar keymaps
	vim.keymap.set("n", "<C-n>", "<Cmd>BufferNext<CR>", opts("Next buffer (Barbar)"))
	vim.keymap.set("n", "<C-b>", "<Cmd>BufferPrevious<CR>", opts("Previous buffer (Barbar)"))
	vim.keymap.set("n", "<leader>B", "<Cmd>BufferMovePrevious<CR>", opts("Move buffer left (Barbar)"))
	vim.keymap.set("n", "<leader>N", "<Cmd>BufferMovePrevious<CR>", opts("Move buffer left (Barbar)"))

	goto_buffer = function(buf_num) vim.cmd("BufferGoto " .. buf_num) end
else
	print("Neither Bufferline nor Barbar is installed!")
end

-- Bind <leader>1 to <leader>0 for buffer switching
for i = 1, 9 do
	keymap.set("n", "<leader>" .. i, function() goto_buffer(i) end, opts("Go to buffer " .. i))
end
keymap.set("n", "<leader>0", function() goto_buffer(10) end, opts("Go to buffer 10"))

-- Keymaps for splits (vertical and horizontal)
keymap.set("n", "<C-w>h", ":vsplit<CR>", opts("Vertical split"))
keymap.set("n", "<C-w>v", ":split<CR>", opts("Horizontal split"))

-- Keymap for closing the current tab using Ctrl+w X
keymap.set("n", "<C-w>d", ":close<CR>", opts("Close window"))

-- Keymap for saving all
keymap.set("n", "<C-w>s", ":wa<CR>", opts("Save all files"))
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
		print("No window available for index " .. index)
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
		print("No visible windows to switch to")
	end
end, opts("Move to last visible window"))

------------------------------------------------- Sessions keymaps
keymap.set("n", "<leader>pl", function() require("nvim-possession").list() end, opts("📌list sessions"))
keymap.set("n", "<leader>pc", function() require("nvim-possession").new() end, opts("📌create new session"))
keymap.set("n", "<leader>pu", function() require("nvim-possession").update() end, opts("📌update current session"))
keymap.set("n", "<leader>pd", function() require("nvim-possession").delete() end, opts("📌delete selected session"))

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

keymap.set("n", "<leader>fs", all_document_symbols, opts("All Variable/Symbols Information (Document)"))
keymap.set("n", "<leader>fS", all_workspace_symbols, opts("All Variable/Symbols Information (Workspace)"))

keymap.set("n", "<leader>fk", builtin.keymaps, opts("Find Keymaps"))

keymap.set("n", "<leader>fg", builtin.live_grep, opts("Live Grep"))
keymap.set("n", "<leader>fw", function() builtin.live_grep({ default_text = vim.fn.expand("<cword>") }) end, opts("Live grep current word"))

keymap.set("n", "<leader>fG", builtin.grep_string, opts("Grep String"))
keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, opts("Current Buffer Fuzzy Find"))

keymap.set("n", "<leader>f<leader>", builtin.oldfiles, {})
keymap.set("n", "<leader>ff", builtin.find_files, opts("Find Files"))
keymap.set("n", "<leader>fb", builtin.buffers, opts("Buffers"))
keymap.set("n", "<leader>fB", telescope.extensions.scope.buffers, opts("Telescope File Browser"))
keymap.set("n", "<leader><leader>", telescope.extensions.file_browser.file_browser, opts("Telescope File Browser"))

keymap.set("n", "<leader>fh", builtin.help_tags, opts("Help Tags"))
keymap.set("n", "<leader>fH", ":nohlsearch<CR>") -- No description needed for raw command
keymap.set("n", "<leader>fi", builtin.lsp_incoming_calls, opts("Incoming calls (Those who call this functions)"))
keymap.set("n", "<leader>fm", function() builtin.treesitter({ default_text = ":method:" }) end, opts("Find Methods with Treesitter"))
keymap.set("n", "<leader>fn", "<cmd>Telescope neoclip<CR>", opts("Telescope Neoclip"))

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
			print("LSP function '" .. fn .. "' not available")
		end
	end
end

local function safe_telescope_call(fn)
	return function()
		local ok, telescope_builtin = pcall(require, "telescope.builtin")
		if ok and telescope_builtin[fn] then
			telescope_builtin[fn]()
		else
			print("Telescope function '" .. fn .. "' not available")
		end
	end
end

-- Go to current function
local ts_utils = require("nvim-treesitter.ts_utils")
local function goto_current_function()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }

	vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(_, result)
		if not result then
			print("No LSP symbols found.")
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
			print("---- DEBUG INFO ----")
			print("🔹 Full Line:", line_content)
			print("🔹 LSP Start Character:", target_col)

			-- Attempt to extract function name from the line
			local function_name = string.match(line_content, "([_%w]+)%s*%(")

			if function_name then
				local col = string.find(line_content, function_name) - 1
				print("🔹 Detected Function Name:", function_name, "at column:", col)
				vim.api.nvim_win_set_cursor(0, { target_line, col })
			else
				print("❌ Function name not found using regex. Using fallback LSP position.")
				vim.api.nvim_win_set_cursor(0, { target_line, target_col })
			end
		else
			print("❌ No function found.")
		end
	end)
end

-- LSP Hover
keymap.set("n", "$", vim.lsp.buf.hover, opts("Hover Information"))
keymap.set("n", "<C-d>", function() vim.lsp.util.scroll(4) end, opts("Scroll down on hover"))
keymap.set("n", "<C-e>", function() vim.lsp.util.scroll(-4) end, opts("Scroll up on however"))
vim.keymap.set("n", "¢", function()
	vim.lsp.buf.hover()

	-- Defer switching focus to ensure the hover window is created
	vim.defer_fn(function()
		-- Force `wincmd w` to work properly
		vim.cmd("wincmd w")
	end, 500) -- Small delay to allow hover to open
end, opts("hover and switch"))

-- LSP Actions
keymap.set("n", "<leader>Lr", safe_lsp_call("rename"), opts("Rename symbol in all occurrences"))
keymap.set("n", "<leader>La", safe_lsp_call("code_action"), opts("Show available code actions"))

-- LSP Definitions & References
keymap.set("n", "gd", safe_telescope_call("lsp_definitions"), opts("Go to definition"))
keymap.set("n", "gD", safe_lsp_call("declaration"), opts("Go to declaration"))
keymap.set("n", "gI", safe_telescope_call("lsp_implementations"), opts("Find implementations"))
keymap.set("n", "gr", safe_telescope_call("lsp_references"), opts("Find references"))

keymap.set("n", "gf", goto_current_function, opts("Go to current function"))
keymap.set("n", "gh", goto_current_function, opts("Go to current function"))
keymap.set("n", "gi", builtin.lsp_incoming_calls, opts("Incoming calls (Those who call this functions)"))
keymap.set("n", "ge", builtin.lsp_incoming_calls, opts("Incoming calls (Those who call this functions)"))
keymap.set("n", "go", builtin.lsp_outgoing_calls, opts("Outcoming calls (Those this function calls)"))
keymap.set("n", "gw", builtin.lsp_outgoing_calls, opts("Outcoming calls (Those this function calls)"))

-- LSP Information
keymap.set("n", "<leader>Lg", safe_lsp_call("hover"), opts("Show LSP hover info"))
keymap.set("n", "<leader>Ls", safe_lsp_call("signature_help"), opts("Show function signature help"))

-- Workspace Folder Management
keymap.set("n", "<leader>LA", safe_lsp_call("add_workspace_folder"), opts("Add workspace folder"))
keymap.set("n", "<leader>LR", safe_lsp_call("remove_workspace_folder"), opts("Remove workspace folder"))
keymap.set("n", "<leader>Ll", function()
	if vim.lsp.buf.list_workspace_folders then
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	else
		print("LSP function 'list_workspace_folders' not available")
	end
end, opts("List workspace folders"))

-- Diagnostics
keymap.set("n", "<leader>LD", safe_lsp_call("diagnostic.open_float"), opts("Show diagnostic in floating window")) -- Changed from `<leader>Ll`
keymap.set("n", "<leader>Lp", safe_lsp_call("diagnostic.goto_prev"), opts("Go to previous diagnostic"))
keymap.set("n", "<leader>Ln", safe_lsp_call("diagnostic.goto_next"), opts("Go to next diagnostic"))

-- Auto Formatting
keymap.set({ "n", "v" }, "<leader>Lf", function()
	if vim.lsp.buf.format then
		vim.lsp.buf.format({ async = true })
	else
		print("LSP function 'format' not available")
	end
end, opts("Format buffer using LSP"))

-- More LSP Commands on <leader>l...
local d = "More LSP Commands on <leader>L... (Also disables search highlight)"
keymap.set("n", "<leader>lz", ":noh<CR>", opts(d))
keymap.set("n", "<leader>gz", ":noh<CR>", opts(d))

---------------------------------------------------------- Git
-- Lazygit
keymap.set("n", "<leader>lg", ":LazyGit<CR>", { desc = "Open LazyGit" })

-- Git History (Telescope)
keymap.set("n", "<leader>gC", builtin.git_commits, { desc = "Search Git Commits (Telescope)" })
keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "Search Buffer Commits (Telescope)" })

-- Git Status (Fugitive)
keymap.set("n", "<leader>gf", ":Git<CR>", { desc = "Git status (Fugitive)" })

-- Git Mergetool
keymap.set("n", "<leader>gm", ":Gvdiffsplit!<CR>", { desc = "Open Git Mergetool" })

-- Reset file to Git index version
keymap.set("n", "<leader>gr", ":Gread<CR>", { desc = "Reset file to index version" })

-- Stage current file
keymap.set("n", "<leader>gs", ":Gwrite<CR>", { desc = "Stage current file" })

-- Git Add All
keymap.set("n", "<leader>ga", ":Git add .<CR>", { desc = "Stage all changes (git add .)" })
-- Git commit
keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit (Fugitive)" })
-- Git Push Current Branch
keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Push current branch to remote" })

-- Git log
keymap.set("n", "<leader>gl", ":Git log --oneline<CR>", { desc = "Show Git log" })

-- Git blame (Avoids `<leader>gb` conflict)
keymap.set("n", "<leader>gB", ":Git blame<CR>", { desc = "Git blame (Fugitive)" })

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
	print("Output buffer not found!")
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
		print("No adjacent buffer found to the " .. direction)
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
		print("No adjacent window found to the " .. direction)
	end
end
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
		print("Output buffer not found!")
	end
end

keymap.set("n", "<leader>kp", push_to_output, opts("Put current hunk into the final output buffer"))

-- Jump to next conflict
keymap.set("n", "<leader>kn", "]c", opts("Jump to next conflict"))

-- Jump to previous conflict
keymap.set("n", "<leader>kN", "[c", opts("Jump to previous conflict"))
keymap.set("n", "<leader>kv", "[c", opts("Jump to previous conflict"))

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
		print("Current buffer is not LOCAL, BASE, or REMOTE. Cannot apply hunk.")
	end
end

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

-- ---------------------------------------------ufo
local ufo = require("ufo")

-- Open/Close All Folds
keymap.set("n", "<leader>zR", ufo.openAllFolds, { desc = "Open all folds" })
keymap.set("n", "<leader>zM", ufo.closeAllFolds, { desc = "Close all folds" })

-- Open/Close Fold Under Cursor
keymap.set("n", "<leader>zr", function() ufo.openFoldsExceptKinds({}) end, { desc = "Open fold under cursor" })

keymap.set("n", "<leader>zm", function() ufo.closeFoldsWith(1) end, { desc = "Close fold under cursor" })

-- Peek Folded Lines
keymap.set("n", "<leader>zK", function()
	local winid = ufo.peekFoldedLinesUnderCursor()
	if not winid then
		vim.lsp.buf.hover()
	end
end, { desc = "Peek Fold" })

-- Jump to Next/Previous Closed Fold
keymap.set("n", "<leader>zn", function() vim.fn.search("^\\zs.\\{-}\\ze\\n\\%($\\|\\s\\{2,}\\)", "W") end, { desc = "Jump to next closed fold" })

keymap.set("n", "<leader>zp", function() vim.fn.search("^\\zs.\\{-}\\ze\\n\\%($\\|\\s\\{2,}\\)", "bW") end, { desc = "Jump to previous closed fold" })

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
keymap.set("n", "<leader>bb", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", { desc = "Toggle breakpoint at current line" })
keymap.set(
	"n",
	"<leader>bc",
	"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
	{ desc = "Set conditional breakpoint" }
)
keymap.set(
	"n",
	"<leader>bl",
	"<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>",
	{ desc = "Set log point (executes a log message instead of stopping execution)" }
)
keymap.set("n", "<leader>br", "<cmd>lua require'dap'.clear_breakpoints()<cr>", { desc = "Clear all breakpoints" })
keymap.set("n", "<leader>ba", "<cmd>Telescope dap list_breakpoints<cr>", { desc = "List all breakpoints (Telescope UI)" })

-- Debugging Execution
keymap.set("n", "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", { desc = "Start/continue debugging session" })
keymap.set("n", "<leader>dj", "<cmd>lua require'dap'.step_over()<cr>", { desc = "Step over (skip function calls)" })
keymap.set("n", "<leader>dk", "<cmd>lua require'dap'.step_into()<cr>", { desc = "Step into function calls" })
keymap.set("n", "<leader>do", "<cmd>lua require'dap'.step_out()<cr>", { desc = "Step out of current function" })

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

-- Debugging Stop/Disconnect
keymap.set("n", "<leader>dd", function()
	require("dap").disconnect()
	require("dapui").close()
end, { desc = "Disconnect debugger (keep process running)" })

keymap.set("n", "<leader>dt", function()
	require("dap").terminate()
	require("dapui").close()
end, { desc = "Terminate debugging session (kill process)" })

-- Debugging Tools
keymap.set("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", { desc = "Toggle debugger REPL" })
keymap.set("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<cr>", { desc = "Re-run last debugging session" })
keymap.set("n", "<leader>di", function() require("dap.ui.widgets").hover() end, { desc = "Hover to inspect variable under cursor" })

keymap.set("n", "<leader>d?", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end, { desc = "Show debugging scopes (floating window)" })

-- Telescope DAP Integrations
keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<cr>", { desc = "Show stack frames (Telescope UI)" })
keymap.set("n", "<leader>dh", "<cmd>Telescope dap commands<cr>", { desc = "List DAP commands (Telescope UI)" })
keymap.set(
	"n",
	"<leader>de",
	function() require("telescope.builtin").diagnostics({ default_text = ":E:" }) end,
	{ desc = "Show errors and diagnostics (Telescope UI)" }
)

----------------------------------------------------- Terminal (PICK ONE) ---------------------------
-------- Float Term: --------
keymap.set(
	"n",
	"<leader>tm",
	"<cmd>:FloatermNew --height=0.8 --width=0.9 --wintype=float --name=floaterm1 --position=center --autoclose=2<CR>",
	{ desc = "Open FloatTerm" }
)

keymap.set("n", "<leader>tp", "<cmd>FloatermPrev<CR>")
keymap.set("n", "<leader>tn", "<cmd>FloatermNext<CR>")

-------- ToggleTerm: ---------
local Terminal = require("toggleterm.terminal").Terminal

-- Toggle floating terminal
keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", opts("Floating Terminal"))

-- Toggle horizontal split terminal
keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=horizontal<CR>", opts("Horizontal Terminal"))

-- Toggle vertical split terminal
keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=vertical<CR>", opts("Vertical Terminal"))

local bottom_right_float = Terminal:new({
	direction = "float",
	float_opts = {
		border = "rounded", -- Rounded border for aesthetics
		width = math.floor(vim.o.columns * 0.45), -- 40% of screen width
		height = math.floor(vim.o.lines * 0.45), -- 40% of screen height
		row = math.floor(vim.o.lines * 0.55), -- Start at 60% down (bottom)
		col = math.floor(vim.o.columns * 0.55), -- Start at 60% across (right)
	},
	hidden = true,
})

keymap.set("n", "<leader>tb", function() bottom_right_float:toggle() end, opts("Floating Bottom-Left Terminal"))

-- Terminal Mode Navigation
function _set_terminal_keymaps()
	local opts = { buffer = 0 }
	keymap.set("t", "<esc>", [[<C-\><C-n>]], opts) -- Exit terminal mode with ESC
	keymap.set("t", "jk", [[<C-\><C-n>]], opts) -- Alternative ESC
	keymap.set("t", "qq", [[<C-\><C-n>:q<CR>]], { noremap = true, silent = true })
end

vim.cmd("autocmd! TermOpen term://* lua _set_terminal_keymaps()")

keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
keymap.set("t", "jk", "<C-\\><C-n>", { noremap = true, silent = true })

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
	keymap.set("", "<C-s>j", nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-s>k", nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-s>i", nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-s>l", nvim_tmux_nav.NvimTmuxNavigateRight)
	keymap.set("", "<C-s>,", nvim_tmux_nav.NvimTmuxNavigateLastActive)
	keymap.set("", "<C-s>Space", nvim_tmux_nav.NvimTmuxNavigateNext)

	keymap.set("", "<C-s><Left>", nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-s><Down>", nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-s><Up>", nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-s><Right>", nvim_tmux_nav.NvimTmuxNavigateRight)

	keymap.set("", "<C-w>j", nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-w>k", nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-w>i", nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-w>l", nvim_tmux_nav.NvimTmuxNavigateRight)

	keymap.set("", "<C-w><Left>", nvim_tmux_nav.NvimTmuxNavigateLeft)
	keymap.set("", "<C-w><Down>", nvim_tmux_nav.NvimTmuxNavigateDown)
	keymap.set("", "<C-w><Up>", nvim_tmux_nav.NvimTmuxNavigateUp)
	keymap.set("", "<C-w><Right>", nvim_tmux_nav.NvimTmuxNavigateRight)
end

------------------------------ NOTES --------------------------
local function ro(description) return { noremap = true, silent = true, desc = description } end

---------------  ✍️ Markdown Preview Toggle
keymap.set("n", "<leader>mt", ":MarkView Toggle<CR>", ro("Toggle Markdown Preview"))
keymap.set("n", "<leader>ms", ":MarkView Start<CR>", ro("Start Markdown Preview"))
keymap.set("n", "<leader>me", ":MarkView Enable<CR>", ro("Enable Markdown Preview Globally"))
keymap.set("n", "<leader>md", ":MarkView Disable<CR>", ro("Disable Markdown Preview Globally"))
keymap.set("n", "<leader>ma", ":MarkView attach<CR>", ro("Attach to Current Buffer"))
keymap.set("n", "<leader>mx", ":MarkView detach<CR>", ro("Detach from Current Buffer"))
keymap.set("n", "<leader>mp", ":MarkView Render<CR>", ro("Render Markdown Preview"))
keymap.set("n", "<leader>mc", ":MarkView Clear<CR>", ro("Clear Markdown Preview"))

-- 🔄 Split View Mode
keymap.set("n", "<leader>mo", ":MarkView splitOpen<CR>", ro("Open Split View"))
keymap.set("n", "<leader>mC", ":MarkView splitClose<CR>", ro("Close Split View"))
keymap.set("n", "<leader>mT", ":MarkView splitToggle<CR>", ro("Toggle Split View"))
keymap.set("n", "<leader>mr", ":MarkView splitRedraw<CR>", ro("Redraw Split View"))

-- 🔍 Debugging / Logs
keymap.set("n", "<leader>mtx", ":MarkView traceExport<CR>", ro("Export Trace Logs"))
keymap.set("n", "<leader>mts", ":MarkView traceShow<CR>", ro("Show Trace Logs"))

--------------- 📄 LaTeX (Vimtex)
-- ✍️ VimTeX Keybindings (Explicit)
keymap.set("n", "<leader>la", ":VimtexContextMenu<CR>", ro("Open VimTeX Context Menu"))
keymap.set("n", "<leader>lc", ":VimtexClean<CR>", ro("Clean Auxiliary Files"))
keymap.set("n", "<leader>lC", ":VimtexClean!<CR>", ro("Full Clean (Includes PDF)"))
keymap.set("n", "<leader>le", ":VimtexErrors<CR>", ro("Show VimTeX Errors"))
keymap.set("n", "<leader>lG", ":VimtexStatusAll<CR>", ro("Show Status for All VimTeX Sessions"))
keymap.set("n", "<leader>li", ":VimtexInfo<CR>", ro("Show VimTeX Info"))
keymap.set("n", "<leader>lI", ":VimtexInfo!<CR>", ro("Show Full VimTeX Info"))
keymap.set("n", "<leader>lk", ":VimtexStop<CR>", ro("Stop Current Compilation"))
keymap.set("n", "<leader>lK", ":VimtexStopAll<CR>", ro("Stop All VimTeX Sessions"))
keymap.set("n", "<leader>ll", ":VimtexCompile<CR>", ro("Start/Continue Compilation"))
keymap.set("n", "<leader>lL", ":VimtexCompileSelected<CR>", ro("Compile Selected Text"))
keymap.set("n", "<leader>lm", ":VimtexImapsList<CR>", ro("List VimTeX Input Mappings"))
keymap.set("n", "<leader>lo", ":VimtexCompileOutput<CR>", ro("Show Compilation Output"))
keymap.set("n", "<leader>lq", ":VimtexLog<CR>", ro("Show Log File"))
keymap.set("n", "<leader>ls", ":VimtexToggleMain<CR>", ro("Toggle Main File"))
keymap.set("n", "<leader>lt", ":VimtexTocOpen<CR>", ro("Open Table of Contents"))
keymap.set("n", "<leader>lT", ":VimtexTocToggle<CR>", ro("Toggle Table of Contents"))
keymap.set("n", "<leader>lv", ":VimtexView<CR>", ro("View PDF"))
keymap.set("n", "<leader>lx", ":VimtexReload<CR>", ro("Reload VimTeX Project"))
keymap.set("n", "<leader>lX", ":VimtexReloadState<CR>", ro("Reload VimTeX State"))

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
---------------------------------------START OF MY PERSONAL TWEAKS------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-------- Apply 'jk' to exit insert mode and visual mode ----------
keymap.set("i", "jk", "<Esc>", { noremap = true })
keymap.set("v", "jk", "<Esc>", { noremap = true })
keymap.set("i", "JK", "<Esc>", { noremap = true })
keymap.set("v", "JK", "<Esc>", { noremap = true })

keymap.set("i", "jl", "<Esc>", { noremap = true })
keymap.set("v", "jl", "<Esc>", { noremap = true })
keymap.set("i", "JL", "<Esc>", { noremap = true })
keymap.set("v", "JK", "<Esc>", { noremap = true })

-- Map Enter in normal mode to add a new line
keymap.set("n", "<CR>", "o<Esc>", { noremap = true, silent = true })

---------------------------------------------------------REGULAR NAVIGATION
---------------------- remap of movement keys and insert, add start/end of line support
-------- USE    i
------------  j k l
-- rather then hjkl for movement, h is insert ---------------------------
keymap.set("n", "j", "h", { noremap = true, silent = true })
keymap.set("n", "l", "l", { noremap = true, silent = true })
keymap.set("n", "i", "k", { noremap = true, silent = true })
keymap.set("n", "k", "j", { noremap = true, silent = true })
keymap.set("n", "h", "i", { noremap = true, silent = true }) -- Insert Mode remains unchanged

keymap.set("x", "j", "h", { noremap = true, silent = true })
keymap.set("x", "l", "l", { noremap = true, silent = true })
keymap.set("x", "i", "k", { noremap = true, silent = true })
keymap.set("x", "k", "j", { noremap = true, silent = true })
keymap.set("x", "h", "i", { noremap = true, silent = true }) -- Keep Insert mode

keymap.set("v", "J", "_", { noremap = true, silent = true })
keymap.set("v", "L", "$", { noremap = true, silent = true })
keymap.set("v", "I", "H", { noremap = true, silent = true })
keymap.set("v", "K", "L", { noremap = true, silent = true })
keymap.set("v", "H", "I", { noremap = true, silent = true })
keymap.set("v", "h", "I", { noremap = true, silent = true })
keymap.set("v", "a", "A", { noremap = true, silent = true })

keymap.set("n", "J", "_", { noremap = true, silent = true })
keymap.set("n", "L", "$", { noremap = true, silent = true })
keymap.set("n", "I", "H", { noremap = true, silent = true })
keymap.set("n", "K", "L", { noremap = true, silent = true })
keymap.set("n", "H", "I", { noremap = true, silent = true })
keymap.set("n", "<leader>hd", "K", { noremap = true, silent = true })
-- K was help on cursor

------------------------------------------------------PAGE NAVIGATION
-- Map Enter in normal mode to add a new line
keymap.set("n", "<CR>", "o<Esc>", { noremap = true, silent = true })

-- map Ctrl+d to scroll down 1/2 screen
keymap.set("n", "<C-d>", "<C-d>", { noremap = true, silent = true })
-- map Ctrl+f to scroll up 1/2 screen
keymap.set("n", "<C-e>", "<C-u>", { noremap = true, silent = true })
keymap.set("v", "<C-e>", "<C-u>", { noremap = true, silent = true })

--scroll down/up one line (change the viewport)
keymap.set("n", "<C-f>", "<C-e>", { noremap = true, silent = true })
keymap.set("n", "<C-r>", "<C-y>", { noremap = true, silent = true })

--repair redo:
keymap.set("n", "<C-y>", "<C-r>", { noremap = true, silent = true })
keymap.set("n", "R", "<C-r>", { noremap = true, silent = true })

--repair "enter replace mode"
keymap.set("n", "<leader>R", "R", { noremap = true, silent = true })

-------------------------------------------------Tabs and indent
-- Map Tab to indent line forward
keymap.set("n", "<Tab>", ">>", { noremap = true, silent = true })
-- Map Shift+Tab to indent line backward
keymap.set("n", "<S-Tab>", "<<", { noremap = true, silent = true })
-- Map Tab to indent line forward
keymap.set("v", "<Tab>", ">>", { noremap = true, silent = true })
-- Map Shift+Tab to indent line backward
keymap.set("v", "<S-Tab>", "<<", { noremap = true, silent = true })

-------------------------------MACROS
-- Map `b` start a macro
keymap.set("n", "b", "q", { noremap = true, silent = true })
-- Use  that symbol if on keyboard for better maccro playing (on ca fr laptop keyboards)
keymap.set("n", "«", "@", { noremap = true, silent = true })

---------------------------WORD NAVIGATION:
------------------------------------------- REMAP of  e,q for end of word.
------------------------------------------- REMAP of w,s for start of word
-- Map `w` to move to the start of the next word
keymap.set("n", "w", "w", { noremap = true, silent = true })
-- Map `s` to move to the start of the previous word
keymap.set("n", "s", "b", { noremap = true, silent = true })
keymap.set("n", "S", "B", { noremap = true, silent = true })

-- Map `s` to move to the end of the next word
keymap.set("n", "e", "e", { noremap = true, silent = true })
-- Map `q` to move to the end of the previous word
keymap.set("n", "q", "ge", { noremap = true, silent = true })
keymap.set("n", "Q", "gE", { noremap = true, silent = true })

-- aaa-bbb-ccc eee-fff-ggg xxx-yyy-zzz  111.222.333 cvb.zxc-asd_jkl

-- Map `w` to move to the start of the next word
keymap.set("v", "w", "w", { noremap = true, silent = true })
-- Map `s` to move to the start of the previous word
keymap.set("v", "s", "b", { noremap = true, silent = true })
keymap.set("v", "S", "B", { noremap = true, silent = true })

-- Map `s` to move to the end of the next word
keymap.set("v", "e", "e", { noremap = true, silent = true })
-- Map `q` to move to the end of the previous word
keymap.set("v", "q", "ge", { noremap = true, silent = true })
keymap.set("v", "Q", "gE", { noremap = true, silent = true })

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

	-- 🔹 2. Try fetching workspace symbols (across imported files)
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

	-- 🔹 3. Fallback: Extract words from buffer if no LSP symbols
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
		print("No symbols found!")
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
%sprint(f'%s = {%s}')]],
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

-- Print variable value on a new line for better readability.
function _G.debug_utils.write_function_newline()
	get_variable_name(function(input)
		if input and input ~= "" then
			local indent = get_indent()
			vim.api.nvim_put({ indent .. string.format("print(f'%s = \n{%s}\n')", input, input) }, "l", true, true)
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
%s	print(f'type(%s) = {type(%s)}')
%s	try:
%s		print(f'np.shape(%s) = {np.shape(%s)}')
%s	except Exception as e:
%s		print('Some error about not having a shape:', e)
%s	print(f'%s = \n{%s}\n')]],
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

---- Bind the functions to keymaps -----
keymap.set("n", "<leader>wfs", _G.debug_utils.write_function_simple, { noremap = true, silent = true, desc = "Write Function Simple" })
keymap.set("n", "<leader>wfn", _G.debug_utils.write_function_numpy, { noremap = true, silent = true, desc = "Write Function Numpy" })
keymap.set("n", "<leader>wfN", _G.debug_utils.write_function_np_newline, { noremap = true, silent = true, desc = "Write Function Numpy NewLine" })
keymap.set("n", "<leader>wfl", _G.debug_utils.write_function_newline, { noremap = true, silent = true, desc = "Write Function NewLine" })
keymap.set("n", "<leader>wfd", _G.debug_utils.write_function_debug, { noremap = true, silent = true, desc = "Write Function Debug" })
--------------------------------- GENERAL UTILS MACRO --------------------------------------
_G.general_utils_franck = {}
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
		print("NotInvert: No matching word to invert")
	end
end

function _G.general_utils_franck.search_word(direction)
	-- Get the word under the cursor
	local word = vim.fn.expand("<cword>")
	if word == nil or word == "" then
		print("No word under cursor!")
		return
	end

	-- Perform the search
	local found = false
	if direction == "next" then
		found = vim.fn.search("\\V" .. vim.fn.escape(word, "\\"), "W") -- Case-sensitive forward search
	elseif direction == "prev" then
		found = vim.fn.search("\\V" .. vim.fn.escape(word, "\\"), "bW") -- Case-sensitive backward search
	else
		print("Invalid direction: Use 'next' or 'prev'")
		return
	end

	if found ~= 0 then
		print("Found word: " .. word)
	else
		print("Word not found: " .. word)
	end
end

-- Bind to functions for next and previous search
function _G.general_utils_franck.SearchNextWord() _G.general_utils_franck.search_word("next") end

function _G.general_utils_franck.SearchPrevWord() _G.general_utils_franck.search_word("prev") end

-- Function to copy the full file path
function _G.general_utils_franck.CopyFilePath()
	local path = vim.fn.expand("%:p") -- Get absolute file path
	vim.fn.setreg("+", path) -- Copy to system clipboard
	print("Copied file path: " .. path)
end

-- Function to copy the directory path
function _G.general_utils_franck.CopyDirPath()
	local dir = vim.fn.expand("%:p:h") -- Get directory path of current file
	vim.fn.setreg("+", dir) -- Copy to system clipboard
	print("Copied directory path: " .. dir)
end

function _G.general_utils_franck.cdHere()
	local file_dir = vim.fn.expand("%:p:h") -- Get directory of current file
	vim.cmd("tcd " .. file_dir)
	tapi.tree.change_root(file_dir) -- Sync Nvim-Tree
	print("Changed directory to: " .. file_dir)
end

vim.keymap.set("n", "<leader>cd", _G.general_utils_franck.cdHere, opts("cd to current dir (in tabs)"))

keymap.set("n", "<leader>ni", _G.general_utils_franck.not_invert, opts("Invert true/false under cursor"))
keymap.set("n", "<Leader>cf", _G.general_utils_franck.CopyFilePath, opts("Copy file path to clipboard"))
keymap.set("n", "<Leader>cp", _G.general_utils_franck.CopyDirPath, opts("Copy directory path to clipboard"))
keymap.set("n", "<leader><Left>", _G.general_utils_franck.SearchPrevWord, opts("Search Previous occurance of this word"))
keymap.set("n", "<leader><Right>", _G.general_utils_franck.SearchNextWord, opts("Search next occurance of this word"))

keymap.set("n", "<leader>rd", function() print("LSP Root Directory: " .. (_G.MyRootDir or "Not detected")) end, { desc = "Print LSP Root Directory" })
----------------------------------------------- END OF CONFIG FILE

-- print("Vim configuration reloaded")
--print(vim.env.TERM)
