-- use :verbose map <key> to get information on a keybind
--run nvim with nvim <file> -V1 to get the information of where the file is
--inside nvimtree, do g? to get information

-- control+space for buffer completion on the other
------------------------------------- Setups for Split window management ----------------------------
local function opts(desc)
	return {
		desc = "nvim-tree: " .. desc,
		noremap = true,
		silent = true,
		nowait = true,
	}
end

-- Function to create key mapping options
local tapi = require("nvim-tree.api")

-----------------------------------------------ACTUAL START-------------------------------------------
-- Set the leader key if not already set
vim.g.mapleader = " " -- Assuming the leader key is set to space
local keymap = vim.keymap

----------------------------------------- Clipboard
vim.api.nvim_set_keymap("n", "<leader>y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>yy", '"+yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>C", '"+yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>p", '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>v", '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>C", '"+yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>p", '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>v", '"+p', { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-c>", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-x>", '"+d', { noremap = true, silent = true })

vim.api.nvim_set_keymap("v", "<C-c>", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-x>", '"+d', { noremap = true, silent = true })

vim.api.nvim_set_keymap("", "<C-C>", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("", "<C-V>", '"+p', { noremap = true, silent = true })
-- Select all text (Help when vscode loads this)
keymap.set("", "<C-a>", "ggVG<CR>", { noremap = true, silent = true })
keymap.set("", "<C-w>a", "ggVG<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rd", function()
	print("LSP Root Directory: " .. (_G.MyRootDir or "Not detected"))
end, { desc = "Print LSP Root Directory" })

vim.api.nvim_set_keymap("", "<C-c>", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("", "<C-x>", '"+d', { noremap = true, silent = true })
vim.api.nvim_set_keymap("", "<C-V>", '"+p', { noremap = true, silent = true })
-- Bind Backspace to '_d' in visual mode (so it cut to the empty register = delete )
vim.api.nvim_set_keymap("v", "<BS>", '"_d', { noremap = true, silent = true })

---------------------- Fixes
-- To have access to a way to increase an number
vim.api.nvim_set_keymap("n", "<leader>u", "<C-a>", { noremap = true, silent = true })
-- Remap Ctrl+v to Ctrl+q in all modes so block visual mode works
keymap.set({ "" }, "<C-v>", "<C-q>", { noremap = true, silent = true })

----------------------Others
-- Function to get the current file path and copy to clipboard
function copy_current_file_path()
	local file_path = vim.fn.expand("%:p") -- Get the absolute path of the current file
	vim.fn.setreg("+", file_path) -- Copy to system clipboard (+ register)
	vim.api.nvim_echo({ { "File path copied: " .. file_path, "Normal" } }, false, {})
end

-- Bind F1 to the function
vim.api.nvim_set_keymap("n", "<F1>", ":lua copy_current_file_path()<CR>", { noremap = true, silent = true })

vim.api.nvim_buf_get_name(0)
-- Run my build command (The basic (F5), and currently selected buffer one (F6))
-- vim.api.nvim_set_keymap("n", "<F6>", ':!bash ./build.sh "%:t"<CR>', { noremap = true, silent = true })

-- vim.api.nvim_set_keymap(
-- 	"n",
-- 	"<F4>",
-- 	':lua vim.cmd("! " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
-- 	{ noremap = true, silent = true }
-- )

vim.api.nvim_set_keymap("n", "<F4>", ":lua RunCurrentFile()<CR>", { noremap = true, silent = true })

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
	elseif file_ext == "py" then
		-- Run Python script
		vim.cmd("!python3 " .. vim.fn.shellescape(filepath))
	else
		print("File type not supported for running with F4")
	end
end

vim.api.nvim_set_keymap("n", "<F5>", ":!bash ./build.sh<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<F6>",
	':lua vim.cmd("!bash ./build.sh " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<F7>",
	':lua vim.cmd("!bash ./build_test.sh " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
	{ noremap = true, silent = true }
)

-- Key mapping to source the current file (Only works for reloading nvim configuration)
vim.api.nvim_set_keymap("n", "<leader>nr", ":source %<CR>", { noremap = true, silent = true })
-- Key mapping to toggle NvimTree
vim.api.nvim_set_keymap("n", "<leader>tt", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tf", ":NvimTreeFindFile<CR>")
-- Oil go backward with backspace
keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })
--keymap.set("n", "<BS>", require("oil").open, { desc = "Open parent directory" })

vim.api.nvim_set_keymap("n", "<leader>o", ":Oil<CR>", { noremap = true, silent = true })

--------------------- General keymaps
keymap.set("n", "<leader>wq", ":wa | qa<CR>") -- save and quit
keymap.set("n", "<leader>qq", ":q!<CR>") -- quit without saving
keymap.set("n", "<leader>bd", ": bd!<CR>", { noremap = true, silent = true, desc = ":bd close buffer" })
keymap.set("n", "<leader>ww", ":wa<CR>") -- save
keymap.set("n", "<leader>wa", ":wa<CR>") -- save all buffers
keymap.set("n", "gx", ":!open <c-r><c-a><CR>") -- open URL under cursor

----------------Split window management, split, resize
--there's a repeat of sh, it's fine. It's for inside nvim_tree, to open current file in a split
keymap.set("n", "<leader>sh", tapi.node.open.vertical, opts("Open: Vertical Split"))
keymap.set("n", "<leader>sv", tapi.node.open.horizontal, opts("Open: Horizontal Split"))
-- I'm used to have it the other way arround. Horizontal split. = Side by side. Though its a vertical line.
-- Too late, I'm used to it mixed up
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width
keymap.set("n", "<leader>sx", ":close<CR>") -- close split window
keymap.set("n", "<leader>sk", "<C-w>-") -- make split window height shorter
keymap.set("n", "<leader>si", "<C-w>+") -- make split windows height taller
keymap.set("n", "<leader>sl", "<C-w>>5") -- make split windows width bigger
keymap.set("n", "<leader>sj", "<C-w><5") -- make split windows width smaller
vim.keymap.set("n", "<C-w>f", ":MaximizerToggle<CR>", { noremap = true, silent = true })

---- Resize splits with Ctrl + arrow keys
vim.api.nvim_set_keymap("n", "<C-Up>", ":resize +5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Down>", ":resize -5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Left>", ":vertical resize -5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-Right>", ":vertical resize +5<CR>", { noremap = true, silent = true })

---- Resized splits with Alt + ijkl
vim.api.nvim_set_keymap("n", "<M-j>", ":vertical resize -5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-l>", ":vertical resize +5<CR>", { noremap = true, silent = true })
-- these two bellow might not work idk
vim.api.nvim_set_keymap("n", "<M-i>", ":resize 5<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<M-k>", ":resize -5<CR>", { noremap = true, silent = true })

--------------------------------------------------------------------------------------- Tab management
-- I don't use tabs
-- keymap.set("n", "<leader>to", ":tabnew<CR>")   -- open a new tab
-- keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close a tab
-- keymap.set("n", "<leader>tn", ":tabn<CR>")     -- next tab
-- keymap.set("n", "<leader>tp", ":tabp<CR>")     -- previous tab
-- keymap.set("n", "<leader>tb", ":tabp<CR>")     -- previous tab

--Navigate next and previous buffers ( like tabs but worse?)
vim.api.nvim_set_keymap("n", "<C-n>", ":bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-b>", ":bprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("", "<C-w>n", ":bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("", "<C-w>b", ":bprevious<CR>", { noremap = true, silent = true })

-- Keymap for creating a new tab using Ctrl+w c
keymap.set("n", "<C-w>c", ":tabnew<CR>", { noremap = true, silent = true })

--keymaps for splits (vertical and horizontal)
keymap.set("n", "<C-w>h", ":vsplit<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-w>v", ":split<CR>", { noremap = true, silent = true })

-- Keymap for closing the current tab using Ctrl+w X
keymap.set("n", "<C-w>x", ": w | bd!<CR>", { noremap = true, silent = true })
keymap.set("n", "<C-w>d", ":close<CR>", { noremap = true, silent = true })

-- Keymap for saving all
keymap.set("n", "<C-w>s", ":wa<CR>", { noremap = true, silent = true })
keymap.set("", "<C-S>", ":w<CR>", { noremap = true, silent = true })
keymap.set("", "<C-s>s", ":w<CR>", { noremap = true, silent = true })

-- Keymap for write and save all
keymap.set("", "<C-w>q", ":wa | qa!<CR>", { noremap = true, silent = true })
keymap.set("", "<C-w>Q", ":qa!<CR>", { noremap = true, silent = true })

----------------------------------------------- Diff keymaps
keymap.set("n", "<leader>cc", ":diffput<CR>") -- put diff from current to other during diff
keymap.set("n", "<leader>cj", ":diffget 1<CR>") -- get diff from left (local) during merge
keymap.set("n", "<leader>ck", ":diffget 3<CR>") -- get diff from right (remote) during merge
keymap.set("n", "<leader>cn", "]c") -- next diff hunk
keymap.set("n", "<leader>cp", "[c") -- previous diff hunk

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

-- Define key mappings using vim.keymap.set

vim.keymap.set({ "n", "x", "o" }, "rj", flash.jump, { desc = "Flash jump" })
vim.keymap.set("n", "rT", flash.toggle, { desc = "Toggle Flash Search" })
vim.keymap.set({ "n", "x", "o" }, "rt", flash.treesitter, { desc = "Flash Treesitter" })
vim.keymap.set("o", "ro", flash.remote, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "rs", flash.treesitter_search, { desc = "Treesitter Search" })

--------------------------------------------TREESJ
-- Key mappings for TreeSJ commands
vim.api.nvim_set_keymap("n", "<leader>jm", ":TSJToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>js", ":TSJSplit<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>jj", ":TSJJoin<CR>", { noremap = true, silent = true })

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

-------------------------------------------- Git
keymap.set("n", "<leader>lg", ":LazyGit<CR>")

---------------------- ----------------------Telescope
local builtin = require("telescope.builtin")
keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Variable/Symbols Information" })
keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })

keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
keymap.set("n", "<leader>fS", builtin.grep_string, { desc = "grep string" })
keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Current buffer fuzzy find" })

keymap.set("n", "<Space><Space>", builtin.oldfiles, {})
keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })

keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
keymap.set("n", "<leader>fH", ":nohlsearch<CR>")
keymap.set("n", "<leader>fi", builtin.lsp_incoming_calls, {})
keymap.set("n", "<leader>fm", function()
	builtin.treesitter({ default_text = ":method:" })
end)
keymap.set("n", "<leader>fn", "<cmd>Telescope neoclip<CR>", { desc = "Telescope Neoclip" })

keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search Git Commits" })
keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "Search Git Commits for Buffer" })

keymap.set("n", "<leader>fc", builtin.colorscheme, { desc = "Change Colors Scheme" })

vim.keymap.set("n", "<C-o>", "<C-o>", { desc = "Jump Backward in Jump List" })
vim.keymap.set("n", "<C-p>", "<C-i>", { desc = "Jump Forward in Jump List" })
vim.keymap.set("n", "<leader>jb", "<C-o>", { desc = "Jump Backward in Jump List" })
vim.keymap.set("n", "<leader>jf", "<C-i>", { desc = "Jump Forward in Jump List" })

-- ---------------------------------------------ufo
local ufo = require("ufo")
-- Key mappings
vim.keymap.set("n", "<leader>zR", ufo.openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "<leader>zM", ufo.closeAllFolds, { desc = "Close all folds" })
vim.keymap.set("n", "<leader>zK", function()
	local winid = ufo.peekFoldedLinesUnderCursor()
	if not winid then
		vim.lsp.buf.hover()
	end
end, { desc = "Peek Fold" })

---------------------------------------------LSP
keymap.set("n", "<leader>gg", "<cmd>lua vim.lsp.buf.hover()<CR>")
-- keymap.set("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
keymap.set("n", "gd", "<Cmd>Telescope lsp_definitions<CR>", { noremap = true, silent = true })

keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
keymap.set("n", "<leader>gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
keymap.set("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
keymap.set("n", "<leader>gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
keymap.set("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>")
keymap.set("n", "<leader>gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
keymap.set("n", "<leader>rr", "<cmd>lua vim.lsp.buf.rename()<CR>")
keymap.set("n", "<leader>gf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>")
keymap.set("v", "<leader>gf", "<cmd>lua vim.lsp.buf.format({async = true})<CR>")
keymap.set("n", "<leader>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
keymap.set("n", "<leader>gl", "<cmd>lua vim.diagnostic.open_float()<CR>")
keymap.set("n", "<leader>gp", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
keymap.set("n", "<leader>gn", "<cmd>lua vim.diagnostic.goto_next()<CR>")
keymap.set("n", "<leader>tr", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
-- keymap.set("i", "<C-Space>", "<cmd>lua vim.lsp.buf.completion()<CR>")
--^^ deprecated

---------------------------------------------------------------- Harpoon
keymap.set("n", "<leader>ha", require("harpoon.mark").add_file)
keymap.set("n", "<leader>hh", require("harpoon.ui").toggle_quick_menu)
keymap.set("n", "<leader>h1", function()
	require("harpoon.ui").nav_file(1)
end)
keymap.set("n", "<leader>h2", function()
	require("harpoon.ui").nav_file(2)
end)
keymap.set("n", "<leader>h3", function()
	require("harpoon.ui").nav_file(3)
end)
keymap.set("n", "<leader>h4", function()
	require("harpoon.ui").nav_file(4)
end)
keymap.set("n", "<leader>h5", function()
	require("harpoon.ui").nav_file(5)
end)
keymap.set("n", "<leader>h6", function()
	require("harpoon.ui").nav_file(6)
end)
keymap.set("n", "<leader>h7", function()
	require("harpoon.ui").nav_file(7)
end)
keymap.set("n", "<leader>h8", function()
	require("harpoon.ui").nav_file(8)
end)
keymap.set("n", "<leader>h9", function()
	require("harpoon.ui").nav_file(9)
end)

-------------------------------------------------------Filetype-specific keymaps
-- from https://github.com/bcampolo/nvim-starter-kit/blob/python/.config/nvim/lua/core/keymaps.lua
-- hence check ftplugin directory in that github thing
keymap.set("n", "<leader>go", function()
	if vim.bo.filetype == "python" then
		vim.api.nvim_command("PyrightOrganizeImports")
	end
end)

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
keymap.set("n", "<leader>di", function()
	require("dap.ui.widgets").hover()
end, { desc = "Hover to inspect variable under cursor" })

keymap.set("n", "<leader>d?", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end, { desc = "Show debugging scopes (floating window)" })

-- Telescope DAP Integrations
keymap.set("n", "<leader>df", "<cmd>Telescope dap frames<cr>", { desc = "Show stack frames (Telescope UI)" })
keymap.set("n", "<leader>dh", "<cmd>Telescope dap commands<cr>", { desc = "List DAP commands (Telescope UI)" })
keymap.set("n", "<leader>de", function()
	require("telescope.builtin").diagnostics({ default_text = ":E:" })
end, { desc = "Show errors and diagnostics (Telescope UI)" })

---------------------------------- Terminal
----Float Term:
vim.keymap.set(
	"n",
	"<leader>tm",
	"<cmd>:FloatermNew --height=0.8 --width=0.9 --wintype=float --name=floaterm1 --position=center --autoclose=2<CR>",
	{ desc = "Open FloatTerm" }
)

keymap.set("n", "<leader>tp", "<cmd>FloatermPrev<CR>")
keymap.set("n", "<leader>tn", "<cmd>FloatermNext<CR>")

---- Terminal Mappings
local term_map = require("terminal.mappings")

-- Send selected text to terminal
keymap.set({ "n", "x" }, "<leader>Ms", term_map.operator_send, { expr = true, desc = "Send selection to terminal" })

-- Toggle terminal visibility
keymap.set("n", "<leader>Mo", term_map.toggle, { desc = "Toggle terminal" })
keymap.set("n", "<leader>MO", term_map.toggle({ open_cmd = "enew" }), { desc = "Toggle terminal in new buffer" })

-- Run command in terminal
keymap.set("n", "<leader>Mr", term_map.run, { desc = "Run command in terminal" })
keymap.set("n", "<leader>MR", term_map.run(nil, { layout = { open_cmd = "enew" } }), { desc = "Run command in a new buffer" })

-- Kill the current terminal session
keymap.set("n", "<leader>Mk", term_map.kill, { desc = "Kill terminal session" })

-- Cycle between open terminals
keymap.set("n", "<leader>M]", term_map.cycle_next, { desc = "Cycle to next terminal" })
keymap.set("n", "<leader>M[", term_map.cycle_prev, { desc = "Cycle to previous terminal" })

-- Move terminal to different locations
keymap.set("n", "<leader>Ml", term_map.move({ open_cmd = "belowright vnew" }), { desc = "Move terminal to right split" })
keymap.set("n", "<leader>ML", term_map.move({ open_cmd = "botright vnew" }), { desc = "Move terminal to far-right split" })
keymap.set("n", "<leader>Mh", term_map.move({ open_cmd = "belowright new" }), { desc = "Move terminal to bottom split" })
keymap.set("n", "<leader>MH", term_map.move({ open_cmd = "botright new" }), { desc = "Move terminal to far-bottom split" })
keymap.set("n", "<leader>Mf", term_map.move({ open_cmd = "float" }), { desc = "Move terminal to floating window" })

vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "jk", "<C-\\><C-n>", { noremap = true, silent = true })

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

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--------------------------------START OF MY PERSONAL TWEAKS-------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-------- Apply 'jk' to exit insert mode and visual mode ----------
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("v", "jk", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("i", "JK", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("v", "JK", "<Esc>", { noremap = true })

vim.api.nvim_set_keymap("i", "jl", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("v", "jl", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("i", "JL", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("v", "JK", "<Esc>", { noremap = true })

-- Map Enter in normal mode to add a new line
vim.api.nvim_set_keymap("n", "<CR>", "o<Esc>", { noremap = true, silent = true })

---------------------------------------------------------REGULAR NAVIGATION
---------------------- remap of movement keys and insert, add start/end of line support
-------- USE    i
------------  j k l
-- rather then hjkl for movement, h is insert ---------------------------
vim.api.nvim_set_keymap("n", "j", "v:count1 .. 'h'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "l", "v:count1 .. 'l'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "i", "v:count1 .. 'k'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "k", "v:count1 .. 'j'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "h", "i", { noremap = true, silent = true }) -- No count needed for Insert Mode

vim.api.nvim_set_keymap("v", "j", "v:count1 .. 'h'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "l", "v:count1 .. 'l'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "i", "v:count1 .. 'k'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "k", "v:count1 .. 'j'", { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "h", "i", { noremap = true, silent = true }) -- No count needed for Insert Mode

vim.api.nvim_set_keymap("v", "J", "_", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "L", "$", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "I", "H", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "K", "L", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "H", "I", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "J", "_", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "L", "$", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "I", "H", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "K", "L", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "H", "I", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>hd", "K", { noremap = true, silent = true })
-- K was help on cursor

------------------------------------------------------PAGE NAVIGATION
-- Map Enter in normal mode to add a new line
vim.api.nvim_set_keymap("n", "<CR>", "o<Esc>", { noremap = true, silent = true })

-- map Ctrl+d to scroll down 1/2 screen
vim.api.nvim_set_keymap("n", "<C-d>", "<C-d>", { noremap = true, silent = true })
-- map Ctrl+f to scroll up 1/2 screen
vim.api.nvim_set_keymap("n", "<C-e>", "<C-u>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-e>", "<C-u>", { noremap = true, silent = true })

--scroll down/up one line (change the viewport)
vim.api.nvim_set_keymap("n", "<C-f>", "<C-e>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-r>", "<C-y>", { noremap = true, silent = true })

--repair redo:
vim.api.nvim_set_keymap("n", "<C-y>", "<C-r>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "R", "<C-r>", { noremap = true, silent = true })

--repair "enter replace mode"
vim.api.nvim_set_keymap("n", "<leader>R", "R", { noremap = true, silent = true })

-------------------------------------------------Tabs and indent
-- Map Tab to indent line forward
vim.api.nvim_set_keymap("n", "<Tab>", ">>", { noremap = true, silent = true })
-- Map Shift+Tab to indent line backward
vim.api.nvim_set_keymap("n", "<S-Tab>", "<<", { noremap = true, silent = true })
-- Map Tab to indent line forward
vim.api.nvim_set_keymap("v", "<Tab>", ">>", { noremap = true, silent = true })
-- Map Shift+Tab to indent line backward
vim.api.nvim_set_keymap("v", "<S-Tab>", "<<", { noremap = true, silent = true })

-------------------------------MACROS
-- Map `b` start a macro
vim.api.nvim_set_keymap("n", "b", "q", { noremap = true, silent = true })
-- Use  that symbol if on keyboard for better maccro playing (on ca fr laptop keyboards)
vim.api.nvim_set_keymap("n", "«", "@", { noremap = true, silent = true })

---------------------------WORD NAVIGATION:
------------------------------------------- REMAP of  e,q for end of word.
------------------------------------------- REMAP of w,s for start of word
-- Map `w` to move to the start of the next word
vim.api.nvim_set_keymap("n", "w", "w", { noremap = true, silent = true })
-- Map `s` to move to the start of the previous word
vim.api.nvim_set_keymap("n", "s", "b", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "S", "B", { noremap = true, silent = true })

-- Map `s` to move to the end of the next word
vim.api.nvim_set_keymap("n", "e", "e", { noremap = true, silent = true })
-- Map `q` to move to the end of the previous word
vim.api.nvim_set_keymap("n", "q", "ge", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "Q", "gE", { noremap = true, silent = true })

-- aaa-bbb-ccc eee-fff-ggg xxx-yyy-zzz  111.222.333 cvb.zxc-asd_jkl

-- Map `w` to move to the start of the next word
vim.api.nvim_set_keymap("v", "w", "w", { noremap = true, silent = true })
-- Map `s` to move to the start of the previous word
vim.api.nvim_set_keymap("v", "s", "b", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "S", "B", { noremap = true, silent = true })

-- Map `s` to move to the end of the next word
vim.api.nvim_set_keymap("v", "e", "e", { noremap = true, silent = true })
-- Map `q` to move to the end of the previous word
vim.api.nvim_set_keymap("v", "q", "ge", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "Q", "gE", { noremap = true, silent = true })

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
vim.api.nvim_set_keymap("n", "<C-g>", "<Cmd>lua Replace_with_confirmation()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<Cmd>lua Replace_with_input()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>rc",
	"<Cmd>lua Replace_with_confirmation()<CR>",
	{ noremap = true, silent = true, desc = "Replace with confirmation" }
)
vim.api.nvim_set_keymap("n", "<leader>ry", "<Cmd>lua Replace_with_input()<CR>", { noremap = true, silent = true, desc = "Replace with input" })

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
vim.api.nvim_set_keymap("n", "zt", "zt", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "zz", "zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "zb", "zb", { noremap = true, silent = true })
------------------------------------------ SYMBOL SEARCH FUNCTION FOR MACROS ---------------
local telescope = require("telescope.builtin")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

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
vim.keymap.set("n", "<leader>wfs", _G.debug_utils.write_function_simple, { noremap = true, silent = true, desc = "Write Function Simple" })
vim.keymap.set("n", "<leader>wfn", _G.debug_utils.write_function_numpy, { noremap = true, silent = true, desc = "Write Function Numpy" })
vim.keymap.set("n", "<leader>wfN", _G.debug_utils.write_function_np_newline, { noremap = true, silent = true, desc = "Write Function Numpy NewLine" })
vim.keymap.set("n", "<leader>wfl", _G.debug_utils.write_function_newline, { noremap = true, silent = true, desc = "Write Function NewLine" })
vim.keymap.set("n", "<leader>wfd", _G.debug_utils.write_function_debug, { noremap = true, silent = true, desc = "Write Function Debug" })
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
function _G.general_utils_franck.SearchNextWord()
	_G.general_utils_franck.search_word("next")
end

function _G.general_utils_franck.SearchPrevWord()
	_G.general_utils_franck.search_word("prev")
end

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

vim.keymap.set("n", "<leader>ni", _G.general_utils_franck.not_invert, { noremap = true, silent = true, desc = "Invert true/false under cursor" })
vim.keymap.set("n", "<Leader>cf", _G.general_utils_franck.CopyFilePath, { desc = "Copy file path to clipboard" })
vim.keymap.set("n", "<Leader>cd", _G.general_utils_franck.CopyDirPath, { desc = "Copy directory path to clipboard" })
vim.keymap.set("n", "<leader><Left>", _G.general_utils_franck.SearchPrevWord, { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Right>", _G.general_utils_franck.SearchNextWord, { noremap = true, silent = true })

----------------------------------------------- END OF CONFIG FILE

-- print("Vim configuration reloaded")
--print(vim.env.TERM)
