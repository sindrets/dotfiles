return function ()
  local hi_link = Config.common.hl.hi_link

  require("symbols-outline").setup({
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = false, -- experimental
    position = 'right',
    relative_width = false,
    width = 50,
    autofold_depth = 0,
    auto_unfold_hover = false,
    keymaps = {
      close = "q",
      goto_location = "<Cr>",
      focus_location = "o",
      hover_symbol = "K",
      rename_symbol = "r",
      code_actions = "<leader>.",
      toggle_preview = "P",
      fold = "h",
      unfold = "l",
      fold_all = "zM",
      unfold_all = "zR",
      fold_reset = "R",
    },
    lsp_blacklist = {},
    symbol_blacklist = {},
    symbols = {
      File = { icon = "󰈔", hl = "@text.uri" },
      Module = { icon = "󰆧", hl = "@namespace" },
      Namespace = { icon = "󰅪", hl = "@namespace" },
      Package = { icon = "󰏗", hl = "@namespace" },
      Class = { icon = "", hl = "@type" },
      Method = { icon = "", hl = "@method" },
      Property = { icon = "", hl = "@method" },
      Field = { icon = "󰆨", hl = "@field" },
      Constructor = { icon = "", hl = "@constructor" },
      Enum = { icon = "", hl = "@type" },
      Interface = { icon = "", hl = "@type" },
      Function = { icon = "ƒ", hl = "@function" },
      Variable = { icon = "", hl = "@constant" },
      Constant = { icon = "", hl = "@constant" },
      String = { icon = "", hl = "@string" },
      Number = { icon = "", hl = "@number" },
      Boolean = { icon = "", hl = "@boolean" },
      Array = { icon = "", hl = "@constant" },
      Object = { icon = "⦿", hl = "@type" },
      Key = { icon = "", hl = "@type" },
      Null = { icon = "NULL", hl = "@type" },
      EnumMember = { icon = "", hl = "@field" },
      Struct = { icon = "", hl = "@type" },
      Event = { icon = "", hl = "@type" },
      Operator = { icon = "", hl = "@operator" },
      TypeParameter = { icon = "", hl = "@parameter" }
    }
  })

  hi_link("FocusedSymbol", "Visual")
end
