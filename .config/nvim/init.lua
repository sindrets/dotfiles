_G.Config = {
  common = require("nvim-config.common"),
}

Config.lib = require("nvim-config.lib")

local lib = Config.lib
local utils = Config.common.utils
local api = vim.api

_G.pi = function(a, opt)
  print(vim.inspect(a, opt))
end

require'nvim-config'

ToggleTermSplit = lib.create_buf_toggler(
  function()
    return utils.find_buf_with_pattern("term_split")
  end,
  function()
    vim.cmd("100 wincmd j")
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
  function()
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

ToggleQF = lib.create_buf_toggler(
  function() return utils.find_buf_with_option("buftype", "quickfix") end,
  function() vim.cmd("100 wincmd j | belowright cope") end,
  function()
    if vim.fn.win_gettype() == "quickfix" then
      vim.cmd("ccl")
    else
      vim.cmd("lcl")
    end
  end,
  { focus = true, remember_height = true }
)

ToggleSymbolsOutline = lib.create_buf_toggler(
  function() return utils.find_buf_with_pattern("OUTLINE") end,
  function() vim.cmd("SymbolsOutlineOpen") end,
  function()
    vim.cmd("SymbolsOutlineClose")
    vim.cmd("wincmd =")
  end
)

function OpenMessagesWin()
  local msgs = vim.api.nvim_exec("mes", true)
  local lines = vim.split(msgs, "\n")
  vim.cmd("belowright new")
  vim.cmd("wincmd J")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.api.nvim_buf_set_var(0, "bufid", "messages_window")
  vim.cmd("setl nolist winfixheight buftype=nofile bh=delete ft=log scl=no | f Messages")
  vim.cmd("res " .. math.min(math.max(#lines, 3), 14))
  vim.cmd("norm! G")
end

function UpdateMessagesWin()
  local bufid = utils.find_buf_with_var("bufid", "messages_window")
  if bufid then
    local msgs = vim.api.nvim_exec("mes", true)
    local lines = vim.split(msgs, "\n")
    vim.api.nvim_buf_set_lines(bufid, 0, -1, false, lines)
    vim.bo[bufid].modified = false
    local winids = vim.fn.win_findbuf(bufid)
    if #winids > 0 then
      api.nvim_set_current_win(winids[1])
      vim.cmd("norm! G")
    end
  else
    OpenMessagesWin()
  end
end

return Config
