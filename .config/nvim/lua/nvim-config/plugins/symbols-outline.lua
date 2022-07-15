return function ()
  local hi_link = Config.common.hl.hi_link

  vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = false, -- experimental
    position = 'right',
    keymaps = {
      close = "q",
      goto_location = "<Cr>",
      focus_location = "o",
      hover_symbol = "<C-space>",
      rename_symbol = "r",
      code_actions = "<leader>.",
    },
    lsp_blacklist = {},
  }

  hi_link("FocusedSymbol", "Visual")
end
