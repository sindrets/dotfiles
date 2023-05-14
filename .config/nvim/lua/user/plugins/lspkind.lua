return function ()
  -- commented options are defaults
  require('lspkind').init({
      with_text = true,
      symbol_map = {
        Method = "  ",
        Function = "  ",
        Variable = "[]",
        Field = "  ",
        TypeParameter = "<󰊄>",
        Constant = " 󰇽 ",
        Class = " 󰌗 ",
        Interface = " 󰔡",
        Struct = "  ",
        Event = "  ",
        Operator = " 󰆕 ",
        Module = " 󰅩 ",
        Property = "  ",
        Enum = " 󰕘 ",
        Reference = "  ",
        Keyword = " 󰉨 ",
        File = "  ",
        Folder = " 󰝰 ",
        Color = "  ",
        Unit = " 󰑭 ",
        Snippet = " 󰃐 ",
        Text = "  ",
        Constructor = "  ",
        Value = " 󰎠 ",
        EnumMember = "  "
      },
    })
end
