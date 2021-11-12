return function ()
  require('neoscroll').setup({
    -- All these keys will be mapped. Pass an empty table ({}) for no mappings
    mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', 'zt', 'zz', 'zb' },
    easing_function = "quadratic",  -- Default easing function
    hide_cursor = true,             -- Hide cursor while scrolling
    stop_eof = true,                -- Stop at <EOF> when scrolling downwards
    respect_scrolloff = false,      -- Stop scrolling when the cursor reaches the scrolloff margin of the file
    cursor_scrolls_alone = true     -- The cursor will keep on scrolling even if the window cannot scroll further
  })

  local time = 180
  local mappings = {
    ["<C-u>"] = { 'scroll', { '-math.max(vim.wo.scroll, 16)', 'true', time } },
    ["<C-d>"] = { 'scroll', { 'math.max(vim.wo.scroll, 16)', 'true', time } },
    ["<C-b>"] = { 'scroll', { '-vim.api.nvim_win_get_height(0)', 'true', time * 2 } },
    ["<C-f>"] = { 'scroll', { 'vim.api.nvim_win_get_height(0)', 'true', time * 2 } },
    ["zt"] = { 'zt', { time } },
    ["zz"] = { 'zz', { time } },
    ["zb"] = { 'zb', { time } },
  }

  require("neoscroll.config").set_mappings(mappings)
end
