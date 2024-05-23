return function ()
  local hi_link = Config.common.hl.hi_link

  require("outline").setup({
    guides = {
      enabled = true
    },
    keymaps = {
      close = "q",
      goto_location = "<Cr>",
      peek_location = "o",
      code_actions = "<leader>.",
      fold = { "zc", "h" },
      fold_all = "zM",
      unfold = { "zo", "l" },
      unfold_all = "zR",
      fold_toggle = { "za", "<tab>" },
      fold_reset = "R",
      hover_symbol = "K",
      rename_symbol = "r",
      toggle_preview = "P",
    },
    outline_items = {
      highlight_hovered_item = true
    },
    outline_window = {
      position = "right",
      relative_width = false,
      width = 50
    },
    preview_window = {
      auto_preview = false
    },
    provider = {
      lsp = {
        blacklist_clients = {}
      }
    },
    symbol_folding = {
      auto_unfold_hover = false,
      autofold_depth = 0
    },
    symbols = {
      icons = {
        Array = { hl = "@constant", icon = "" },
        Boolean = { hl = "@boolean", icon = "" },
        Class = { hl = "@type", icon = "" },
        Constant = { hl = "@constant", icon = "" },
        Constructor = { hl = "@constructor", icon = "" },
        Enum = { hl = "@type", icon = "" },
        EnumMember = { hl = "@field", icon = "" },
        Event = { hl = "@type", icon = "" },
        Field = { hl = "@field", icon = "󰆨" },
        File = { hl = "@text.uri", icon = "󰈔" },
        Function = { hl = "@function", icon = "ƒ" },
        Interface = { hl = "@type", icon = "" },
        Key = { hl = "@type", icon = "" },
        Method = { hl = "@method", icon = "" },
        Module = { hl = "@namespace", icon = "󰆧" },
        Namespace = { hl = "@namespace", icon = "󰅪" },
        Null = { hl = "@type", icon = "NULL" },
        Number = { hl = "@number", icon = "" },
        Object = { hl = "@type", icon = "⦿" },
        Operator = { hl = "@operator", icon = "" },
        Package = { hl = "@namespace", icon = "󰏗" },
        Property = { hl = "@method", icon = "" },
        String = { hl = "@string", icon = "" },
        Struct = { hl = "@type", icon = "" },
        TypeParameter = { hl = "@parameter", icon = "" },
        Variable = { hl = "@constant", icon = " "}
      }
    }
  })

  hi_link("OutlineCurrent", "Visual")
end
