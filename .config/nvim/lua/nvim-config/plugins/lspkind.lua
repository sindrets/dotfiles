return function ()
  -- commented options are defaults
  require('lspkind').init({
      with_text = true,
      symbol_map = {
        Method = "  ",
        Function = "  ",
        Variable = "[]",
        Field = "  ",
        TypeParameter = "<>",
        Constant = "  ",
        Class = "  ",
        Interface = " 蘒",
        Struct = "  ",
        Event = "  ",
        Operator = "  ",
        Module = "  ",
        Property = "  ",
        Enum = " 練 ",
        Reference = "  ",
        Keyword = "  ",
        File = "  ",
        Folder = " ﱮ ",
        Color = "  ",
        Unit = " 塞 ",
        Snippet = "  ",
        Text = "  ",
        Constructor = "  ",
        Value = "  ",
        EnumMember = "  "
      },
    })
end
