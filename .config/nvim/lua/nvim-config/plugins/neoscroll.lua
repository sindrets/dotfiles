return function ()
  local neoscroll = require("neoscroll")

  Config.plugin.neoscroll = {}
  local M = Config.plugin.neoscroll

  neoscroll.setup({
    -- All these keys will be mapped. Pass an empty table ({}) for no mappings
    mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', 'zt', 'zz', 'zb' },
    easing_function = "quadratic",  -- Default easing function
    hide_cursor = true,             -- Hide cursor while scrolling
    stop_eof = true,                -- Stop at <EOF> when scrolling downwards
    respect_scrolloff = false,      -- Stop scrolling when the cursor reaches the scrolloff margin of the file
    cursor_scrolls_alone = true     -- The cursor will keep on scrolling even if the window cannot scroll further
  })

  function M.run(opr, ...)
    local last = vim.o.eventignore
    vim.opt.eventignore = "all"
    neoscroll[opr](...)
    vim.opt.eventignore = last
    vim.cmd("do WinScrolled")
  end

  local time = 180
  vim.keymap.set("n", "<C-u>", function()
    M.run("scroll", -math.max(vim.wo.scroll, 16), true, time)
  end)
  vim.keymap.set("n", "<C-d>", function()
    M.run("scroll", math.max(vim.wo.scroll, 16), true, time)
  end)
  vim.keymap.set("n", "<C-b>", function()
    M.run("scroll", -vim.api.nvim_win_get_height(0), true, time * 2)
  end)
  vim.keymap.set("n", "<C-f>", function()
    M.run("scroll", vim.api.nvim_win_get_height(0), true, time * 2)
  end)
  vim.keymap.set("n", "zt", function() M.run("zt", time) end)
  vim.keymap.set("n", "zz", function() M.run("zz", time) end)
  vim.keymap.set("n", "zb", function() M.run("zb", time) end)
end
