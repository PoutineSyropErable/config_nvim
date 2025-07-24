local M = {}

function M.setup(filetype)
  filetype = filetype or vim.bo.filetype

  local ok, _ = pcall(require, "lsp." .. filetype)
  if not ok then
    -- no language config found, silently fail
  end
end

-- Auto-load LSP config for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    M.setup(args.match)
  end,
})

return M

