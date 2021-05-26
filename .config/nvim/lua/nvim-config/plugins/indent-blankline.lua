return function ()
  vim.g.indent_blankline_char = '▏'
  -- vim.g.indent_blankline_space_char = ' '
  vim.g.indent_blankline_space_char_blankline = '⠀'
  vim.g.indent_blankline_use_treesitter = true
  vim.g.indent_blankline_show_trailing_blankline_indent = false
  vim.g.indent_blankline_show_current_context = true
  vim.g.indent_blankline_buftype_exclude = {'terminal'}
  vim.g.indent_blankline_filetype_exclude = {
    'help',
    'startify',
    'dashboard',
    'packer',
    'neogitstatus',
    'man',
    'sagasignature',
    'sagahover',
    'lspsagafinder',
    'LspSagaCodeAction',
    'TelescopePrompt',
    'NvimTree',
    'Trouble',
    'DiffviewFiles'
  }
  vim.g.indent_blankline_context_patterns = {
    'class', 'return', 'function', 'method', '^if', '^while', 'jsx_element',
    '^for', '^object', '^table', 'block', 'arguments', 'if_statement',
    'else_clause', 'jsx_element', 'jsx_self_closing_element',
    'try_statement', 'catch_clause', 'import_statement'
  }

  -- vim.cmd([[hi! IndentBlanklineContextChar guifg=fg]])
end
