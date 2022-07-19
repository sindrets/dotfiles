return function()
  -- Config defaults:
  -- ~/.local/share/nvim/site/pack/packer/start/nvim-bqf/lua/bqf/config.lua

  require("bqf").setup({
    preview = {
      auto_preview = false,
      border_chars = { '│', '│', '─', '─', '┌', '┐', '└', '┘', '█' },
      delay_syntax = 50,
      win_height = 15,
      win_vheight = 15,
      wrap = false,
      should_preview_cb = nil
    },
  })
end
