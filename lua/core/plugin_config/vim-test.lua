vim.cmd([[
  let test#strategy = "vimux"
]])

vim.keymap.set("n", "<leader>Tt", ":TestNearest<CR>")
vim.keymap.set("n", "<leader>TT", ":TestFile<CR>")
