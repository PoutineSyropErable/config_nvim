-- This file is for git diffs, git mergetool, git merge conflict. Git Splits. 3 Splits. 3 diffs

vim.cmd([[
  autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete
  augroup fugitive_autoclose
    autocmd!
    autocmd QuitPre * if &diff | diffoff! | endif
  augroup END
]])

-- Set Fugitive as the Git mergetool
vim.g.fugitive_mergetool = 1
vim.g.fugitive_no_maps = 1

-- vim.cmd([[
--   command! Gvdiffsplit Gvdiffsplit!
-- ]])
