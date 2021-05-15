local lib = require'nvim-config.lib'
local utils = require'nvim-config.utils'

require'nvim-config'

ToggleTermSplit = lib.create_buf_toggler(
  function ()
    return utils.find_buf_with_pattern("term_split")
  end,
  function ()
    vim.cmd("belowright sp")
    local bufid = utils.find_buf_with_pattern("term_split")
    if bufid then
      vim.api.nvim_set_current_buf(bufid)
    else
      vim.cmd("term")
      vim.bo.buflisted = false
      vim.api.nvim_buf_set_name(0, "term_split")
    end
    vim.cmd("startinsert")
  end,
  function ()
    local bufid = utils.find_buf_with_pattern("term_split")
    if bufid then
      local wins = vim.fn.win_findbuf(bufid)
      if #wins > 0 then
        vim.api.nvim_win_hide(wins[1])
      end
    end
  end,
  { focus = true, height = 16, remember_height = true }
  )
