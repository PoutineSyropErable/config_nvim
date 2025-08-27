-- Set the leader key if not already set
vim.g.mapleader = " "
local keymap = vim.keymap
-- makes keymap seting easier
local function opts(desc) return { noremap = true, silent = true, desc = desc } end

local gu = require("_before.general_utils")
local notify_debug = gu.send_notification
local print_custom = gu.print_custom

-------- Apply 'jk' to exit insert mode and visual mode ----------
keymap.set("i", "jk", "<Esc>", opts("Exit Insert Mode"))
keymap.set("i", "JK", "<Esc>", opts("Exit Insert Mode"))
keymap.set("v", "jk", "<Esc>", opts("Exit Visual Mode"))
keymap.set("v", "JK", "<Esc>", opts("Exit Visual Mode"))

keymap.set("i", "jl", "<Esc>", opts("Exit Insert Mode"))
keymap.set("i", "JL", "<Esc>", opts("Exit Insert Mode"))
keymap.set("v", "jl", "<Esc>", opts("Exit Visual Mode"))
keymap.set("v", "JL", "<Esc>", opts("Exit Visual Mode"))

-- Map Enter in normal mode to add a new line (This breaks enter on a lot of things)
-- keymap.set("n", "<CR>", "o<Esc>", opts("Open a new line"))

---------------------------------------------------------REGULAR NAVIGATION
---------------------- remap of movement keys and insert, add start/end of line support
-------- USE    i
------------  j k l
-- rather than hjkl for movement, h is insert ---------------------------
keymap.set("n", "j", "h", opts("Move left (h mapped to j)"))
keymap.set("n", "l", "l", opts("Move right (l remains l)"))
keymap.set("n", "i", "k", opts("Move up (k mapped to i)"))
keymap.set("n", "k", "j", opts("Move down (j mapped to k)"))
keymap.set("n", "h", "i", opts("Enter insert mode"))

keymap.set("n", "J", "_", opts("Move to beginning of line"))
keymap.set("n", "L", "$", opts("Move to end of line"))
keymap.set("n", "I", "H", opts("Move to the top of the view port"))
keymap.set("n", "K", "L", opts("Move to the bottom of the view port"))
keymap.set("n", "H", "I", opts("Move to the start of the line (And go to insert mode)"))
keymap.set("n", "<leader>hd", "K", opts("Helper for K"))

keymap.set("v", "j", "h", opts("Move left (h mapped to j)"))
keymap.set("v", "l", "l", opts("Move right (l remains l)"))
keymap.set("v", "i", "k", opts("Move up (k mapped to i)"))
keymap.set("v", "k", "j", opts("Move down (j mapped to k)"))
keymap.set("v", "h", "i", opts("Insert Mode remains unchanged")) -- Insert Mode remains unchanged

keymap.set("v", "J", "_", opts("Move to beginning of line"))
keymap.set("v", "L", "$", opts("Move to end of line"))
keymap.set("v", "I", "H", opts("Move to top of the view port"))
keymap.set("v", "K", "L", opts("Move to bottom of the view port"))
keymap.set("v", "H", "I", opts("Move to the start of the line (and go into insert mode)"))
-- keymap.set("v", "h", "I", opts("Insert Mode remains unchanged"))
-- keymap.set("v", "a", "A", opts("Select till the end of line"))

-- "x mode does not exist"
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
keymap.set("n", "W", "W", { noremap = true, silent = true })
-- Map `s` to move to the end of the previous word
keymap.set("n", "s", "ge", { noremap = true, silent = true })
keymap.set("n", "S", "gE", { noremap = true, silent = true })

-- Map `e` to move to the end of the next word
keymap.set("n", "e", "e", { noremap = true, silent = true })
-- Map `q` to move to the start of the previous word
keymap.set("n", "q", "b", { noremap = true, silent = true })
keymap.set("n", "Q", "B", { noremap = true, silent = true })

-- aaa-bbb-ccc eee-fff-ggg xxx-yyy-zzz  111.222.333 cvb.zxc-asd_jkl
---  aaaaaaaaaaaaaaaa  bbbbbbbbbbbbbbbbbb cccccccccccccccc  kkkkkkkkk

-- Map `w` to move to the start of the next word
keymap.set("v", "w", "w", { noremap = true, silent = true })
-- Map `s` to move to the end of the previous word
keymap.set("v", "s", "ge", { noremap = true, silent = true })
keymap.set("v", "S", "gE", { noremap = true, silent = true })

-- Map `e` to move to the end of the next word
keymap.set("v", "e", "e", { noremap = true, silent = true })
-- Map `q` to move to the start of the previous word
keymap.set("v", "q", "b", { noremap = true, silent = true })
keymap.set("v", "Q", "B", { noremap = true, silent = true })

---------------------------------------------- Other useful keymaps:

----------------------------------------- Clipboard
-- keymap.set("v", "<leader>y", '"+y', { noremap = true, silent = true })
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
keymap.set("n", "<leader>y", "<C-a>", { noremap = true, silent = true })
-- Remap Ctrl+v to Ctrl+q in all modes so block visual mode works
keymap.set({ "" }, "<C-v>", "<C-q>", { noremap = true, silent = true })

----------------------Others ----------------------------
-- Function to get the current file path and copy to clipboard
local function copy_current_file_path()
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
		local autoMakeScript = home .. AutoMakeJava_location .. "/src/automake.py"
		vim.cmd("!python3 " .. vim.fn.shellescape(autoMakeScript) .. " " .. vim.fn.shellescape(filepath))
	else
		print_custom("File type not supported for running with F4")
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
local function run_do_all()
	local proj_root = gu.find_project_root(true)
	if not proj_root then
		vim.notify("❌ Project root not found", vim.log.levels.ERROR)
		return
	end

	--"proj_root = " .. proj_root)

	local all_cmd = "cd " .. vim.fn.shellescape(proj_root) .. " && bash ./aaa_do_all.sh"
	print_custom("all cmd = " .. all_cmd, vim.log.levels.INFO)

	local output = vim.fn.system(all_cmd)
	vim.notify("Output:\n" .. output, vim.log.levels.INFO)
end

keymap.set("n", "<F1>", copy_current_file_path, opts("Copy current file path"))
keymap.set("n", "<F2>", execute_current_file, opts("Stupidly execute current file"))
-- keymap.set("n", "<F3>", run_do_all, opts("Run do all script (build, run, and more) {./aaa_doall.sh}"))
keymap.set("n", "<F4>", RunCurrentFile, opts("Run current file"))
keymap.set("n", "<F5>", run_build_script, opts("Run build script (No argument) - (build.sh)"))
keymap.set("n", "<F6>", run_build_script_with_file, opts("Run build script (with this file as argument) - (build.sh $thisFile)"))
keymap.set("n", "<F7>", run_build_test_script, opts("Run test script (with this file as argument) - (build_test.sh $thisFile)"))
keymap.set("n", "<F8>", run_do_all, opts("Run do all script (build, run, and more) {./aaa_doall.sh}"))

local oil_open = function() require("oil").open() end

--
-- Key mapping to source the current file (Only works for reloading nvim configuration)
keymap.set("n", "<leader>sr", ":source %<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>tt", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
keymap.set("n", "-", oil_open, { desc = "Open parent directory" })
keymap.set("n", "+", ":Oil<CR>", { noremap = true, silent = true })

--- Weird stuff

local toggle_invisible_char = function()
	-- vim.opt.list = not vim.opt.list:get()
	vim.o.list = not vim.o.list

	print_custom("List mode: " .. (vim.o.list and "ON" or "OFF"))
end

local toggle_linting = function()
	if vim.g.linting_enabled then
		vim.diagnostic.enable()
		print_custom("🔍 Linting Enabled")
	else
		vim.diagnostic.enable(false)
		print_custom("🚫 Linting Disabled")
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
keymap.set("n", "<leader>.l", toggle_linting, opts("Toggle Lint and diagnostic"))

local function get_tab_name(tabnr)
	local ok, name = pcall(vim.api.nvim_tabpage_get_var, tabnr, "name")
	return ok and name or tabnr -- Fallback if name is missing
end

local function get_current_tab_name()
	local tabnr = vim.api.nvim_get_current_tabpage()
	local tab_name = get_tab_name(tabnr)
	print_custom("Current Tab Name: " .. tab_name)
end

keymap.set("n", "<leader>.N", get_current_tab_name, opts("Show current tab name"))

keymap.set("n", "<leader>fH", ":nohlsearch<CR>") -- No description needed for raw command

-- Jump List Navigation
keymap.set("n", "<C-o>", "<C-o>", opts("Jump Backward in Jump List"))
keymap.set("n", "<C-p>", "<C-i>", opts("Jump Forward in Jump List"))
keymap.set("n", "<leader>jb", "<C-o>", opts("Jump Backward in Jump List"))
keymap.set("n", "<leader>jf", "<C-i>", opts("Jump Forward in Jump List"))

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

keymap.set("n", "<C-g>", "<Cmd>lua Replace_with_confirmation()<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-h>", "<Cmd>lua Replace_with_input()<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>rc", "<Cmd>lua Replace_with_confirmation()<CR>", { noremap = true, silent = true, desc = "Replace with confirmation" })
keymap.set("n", "<leader>ry", "<Cmd>lua Replace_with_input()<CR>", { noremap = true, silent = true, desc = "Replace with input" })

local gu_path = "_before.general_utils"

keymap.set("n", "<leader>ni", function() require(gu_path).not_invert() end, opts("Invert true/false under cursor"))
keymap.set("n", "<Leader>cf", function() require(gu_path).CopyFilePath() end, opts("Copy file path to clipboard"))
keymap.set("n", "<Leader>cp", function() require(gu_path).CopyDirPath() end, opts("Copy directory path to clipboard"))
keymap.set("n", "<leader>cd", function() require(gu_path).cdHere() end, opts("cd to current dir (in tabs)"))

keymap.set("n", "<leader>/", function() require(gu_path).SearchPrevWord() end, opts("Search Previous occurance of this word"))
keymap.set("n", "<leader>*", function() require(gu_path).SearchNextWord() end, opts("Search Next occurance of this word"))

vim.keymap.set("n", "<leader><left>", function() require(gu_path).search_current_word(true) end, { desc = "Search word under cursor backward" })
vim.keymap.set("n", "<leader><right>", function() require(gu_path).search_current_word(false) end, { desc = "Search word under cursor forward" })

vim.api.nvim_create_user_command("CdHere", function() require(gu_path).cdHere() end, { desc = "Cd to current working directory" })

keymap.set("n", "<C-w>=", "<C-w>=") -- make split windows equal width
keymap.set("n", "<C-w>h", ":vsplit<CR>", opts("Vertical split"))
keymap.set("n", "<C-w>v", ":split<CR>", opts("Horizontal split"))

keymap.set("n", "<C-Up>", ":resize +5<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-Down>", ":resize -5<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-Left>", ":vertical resize -5<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-Right>", ":vertical resize +5<CR>", { noremap = true, silent = true })

keymap.set("n", "<C-w>f", ":MaximizerToggle<CR>", { noremap = true, silent = true })

-- Toggle word wrapping for writing text vs coding
function ToggleWrap()
	if vim.wo.wrap then
		-- Currently ON → turn OFF
		vim.wo.wrap = false
		vim.wo.linebreak = false
		vim.wo.breakindent = false
		print("Word wrap OFF (coding mode)")
	else
		-- Currently OFF → turn ON
		vim.wo.wrap = true
		vim.wo.linebreak = true
		vim.wo.breakindent = true
		print("Word wrap ON (writing mode)")
	end
end

-- Map it to <leader>w for convenience
vim.keymap.set("n", "<leader>.w", ToggleWrap, { desc = "Toggle word wrap" })
