return function()
  require("winshift").setup({
    highlight_moving_win = true,
    focused_hl_group = "LspReferenceRead",
    keymaps = {
      disable_defaults = false,
      win_move_mode = {
        ["h"] = "left",
        ["j"] = "down",
        ["k"] = "up",
        ["l"] = "right",
        ["H"] = "far_left",
        ["J"] = "far_down",
        ["K"] = "far_up",
        ["L"] = "far_right",
        ["<left>"] = "left",
        ["<down>"] = "down",
        ["<up>"] = "up",
        ["<right>"] = "right",
        ["<S-left>"] = "far_left",
        ["<S-down>"] = "far_down",
        ["<S-up>"] = "far_up",
        ["<S-right>"] = "far_right",
      },
    },
    moving_win_options = {
      wrap = false,
      cursorline = false,
      cursorcolumn = false,
      colorcolumn = "",
    },
  })
end
