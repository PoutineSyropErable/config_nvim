local function opts(desc) return { noremap = true, silent = true, desc = desc } end
local keymap = vim.keymap

keymap.set("n", "<C-k>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", opts("switch to a particular session"))
keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", opts("Create or Switch to session 0"))
keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>", opts("Create or switch to session 1"))
keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>", opts("Create or switch to session 2"))
keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>", opts("Create or switch to session 3"))
-- These are for session commands, which i dont use. So learn what they are about.
-- They aren't about create or switchgint to session n
