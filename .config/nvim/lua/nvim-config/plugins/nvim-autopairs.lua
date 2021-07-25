return function ()
  require('nvim-autopairs').setup({
      disable_filetype = { "TelescopePrompt" },
      break_line_filetype = nil, -- mean all file type
      html_break_line_filetype = {'html' , 'vue' , 'typescriptreact' , 'svelte' , 'javascriptreact'},
      ignored_next_char = "[%w%%%'%[%\"%.]",
      enable_check_bracket_line = true
    })

  require("nvim-autopairs.completion.compe").setup({
    map_cr = false, --  map <CR> on insert mode
    map_complete = true -- it will auto insert `(` after select function or method item
  })
end
