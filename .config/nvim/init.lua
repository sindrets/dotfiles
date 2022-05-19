_G.Config = {
  common = require("nvim-config.common"),
  fn = {},
  plugin = {},
}

Config.lib = require("nvim-config.lib")

local lib = Config.lib
local utils = Config.common.utils
local api = vim.api

_G.pi = function(a, opt)
  print(vim.inspect(a, opt))
end

_G.uv = vim.loop

require("nvim-config")

Config.fn.toggle_term_split = lib.create_buf_toggler(
  function()
    return utils.find_buf_with_pattern("term_split", { no_hidden = true, tabpage = 0 })
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
    local bufid = utils.find_buf_with_pattern("term_split", { no_hidden = true, tabpage = 0 })
    if bufid then
      local wins = vim.fn.win_findbuf(bufid)
      if #wins > 0 then
        vim.api.nvim_win_hide(wins[1])
      end
    end
  end,
  { focus = true, height = 16, remember_height = true }
)

Config.fn.toggle_quickfix = lib.create_buf_toggler(
  function()
    return utils.find_buf_with_option("buftype", "quickfix", { no_hidden = true, tabpage = 0 })
  end,
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

Config.fn.toggle_outline = lib.create_buf_toggler(
  function() return utils.find_buf_with_pattern("OUTLINE") end,
  function() vim.cmd("SymbolsOutlineOpen") end,
  function()
    vim.cmd("SymbolsOutlineClose")
    vim.cmd("wincmd =")
  end
)

local function open_messages_win()
  vim.cmd("belowright sp")
  vim.cmd("wincmd J")
  local bufnr = utils.find_buf_with_var("bufid", "messages_window")
  if not bufnr then
    bufnr = api.nvim_create_buf(false, false)
    api.nvim_buf_set_name(bufnr, "Messages")
    api.nvim_buf_set_var(bufnr, "bufid", "messages_window")
  end
  local msgs = vim.api.nvim_exec("mes", true)
  local lines = vim.split(msgs, "\n", {})
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  api.nvim_set_current_buf(bufnr)
  api.nvim_win_set_height(0, math.min(math.max(#lines, 3), 14))
  utils.set_local(0, {
    list = false,
    winfixheight = true,
    buftype = "nofile",
    bufhidden = "delete",
    filetype = "log",
    signcolumn = "no",
    colorcolumn = {},
  })
  vim.cmd("norm! G")
end

function Config.fn.update_messages_win()
  local bufnr = utils.find_buf_with_var(
    "bufid",
    "messages_window",
    { no_hidden = true, tabpage = 0 }
  )
  if bufnr then
    local msgs = vim.api.nvim_exec("mes", true)
    local lines = vim.split(msgs, "\n", {})
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modified = false
    local winids = utils.win_find_buf(bufnr, 0)
    if #winids > 0 then
      api.nvim_set_current_win(winids[1])
      vim.cmd("norm! G")
    end
  else
    open_messages_win()
  end
end

return Config
