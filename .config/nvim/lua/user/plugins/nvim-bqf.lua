return function()
  -- Config defaults:
  -- ~/.local/share/nvim/lazy/nvim-bqf/lua/bqf/config.lua

  require("bqf").setup({
    preview = {
      auto_preview = false,
      border = "single",
      delay_syntax = 50,
      winblend = 0,
      win_height = 15,
      win_vheight = 15,
      wrap = false,
      buf_label = true,
      should_preview_cb = nil
    },
  })
end
