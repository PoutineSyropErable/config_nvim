-- Inline Debug Text
require('nvim-dap-virtual-text').setup({
  -- Display debug text as a comment
  commented = true,
  
  -- Customize virtual text
  display_callback = function(variable, buf, stackframe, node, options)
    if options.virt_text_pos == 'inline' then
      return ' = ' .. variable.value
    else
      return variable.name .. ' = ' .. variable.value
    end
  end,
})

