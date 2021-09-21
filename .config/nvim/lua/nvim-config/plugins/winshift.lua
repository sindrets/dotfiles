return function()
  require("winshift").setup({
    highlight_moving_win = true,
    focused_hl_group = "LspReferenceRead",
    moving_win_options = {
      wrap = false,
      cursorline = false,
      cusorcolumn = false,
      colorcolumn = "",
    }
  })
end
