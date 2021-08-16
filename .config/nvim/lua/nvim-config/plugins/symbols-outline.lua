return function ()
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

  vim.api.nvim_exec([[
    augroup SymbolsOutlineConfig
      au!
      au FileType Outline set nolist winfixwidth signcolumn=no
    augroup END
    ]], false)
end
