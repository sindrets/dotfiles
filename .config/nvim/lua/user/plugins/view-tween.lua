return function()
  local vt = require("view_tween")
  local api = vim.api
  local km = vim.keymap

  local duration = 250

  km.set("n", "<C-u>", function()
    vt.scroll(0, -math.max(vim.wo.scroll, 16), duration)
  end)
  km.set("n", "<C-d>", function()
    vt.scroll(0, math.max(vim.wo.scroll, 16), duration)
  end)
  km.set("n", "<C-b>", function()
    vt.scroll(0, -api.nvim_win_get_height(0), duration * 2)
  end)
  km.set("n", "<C-f>", function()
    vt.scroll(0, api.nvim_win_get_height(0), duration * 2)
  end)
  km.set("n", "zt", vt.scroll_actions.cursor_top(duration * 2, true))
  km.set("n", "zb", vt.scroll_actions.cursor_bottom(duration * 2, true))
  km.set("n", "zz", vt.scroll_actions.cursor_center(duration, true))
end
