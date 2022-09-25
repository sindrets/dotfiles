local ok, impatient = pcall(require, "impatient")

if ok then
  impatient.enable_profile()
end

---Pretty print. Alias for `vim.inspect()`.
_G.pp = function(a, opt)
  print(vim.inspect(a, opt))
end

---LibUV
_G.uv = vim.loop

_G.Config = {
  common = require("user.common"),
  fn = {},
  plugin = {},
  state = {
    git = {
      rev_name_cache = {},
    },
  },
}

---Path library.
_G.pl = Config.common.utils.pl

Config.lib = require("user.lib")
Config.term = require("user.modules.term")

local alias = require("user.modules.cmd_alias").alias
local api = vim.api
local lib = Config.lib
local utils = Config.common.utils

require("user")

-- COMMAND ALIASES

alias("brm", "BRemove")
alias("sch", "Scratch")
alias("wins", "Windows")
alias("hh", "HelpHere")
alias("mh", "ManHere")
alias("gh", "Git ++curwin")
alias("T", "Telescope")
alias("gs", "Telescope git_status")
alias("gb", "Telescope git_branches")
alias("gl", "Telescope git_commits")
alias("Q", "q")
alias({ "Qa", "QA" }, "qa")
alias("we", "w | e")
alias("ws", "w | so %")
alias("ftd", "filetype detect")
alias("N", "Neorg")
alias("nim", "Neorg inject-metadata")
-- Toggle conceallevel:
alias("tcl", "exe 'setl conceallevel=' . (&conceallevel == 0 ? 2 : 0)")

-- FUNCTIONS

Config.fn.toggle_quickfix = lib.create_buf_toggler(
  function()
    return utils.list_bufs({
      options = { buftype = "quickfix" },
      no_hidden = true,
      tabpage = 0,
    })[1]
  end,
  function()
    if #vim.fn.getloclist(0) > 0 then
      vim.cmd("belowright lope")
    else
      vim.cmd("100 wincmd j | belowright cope")
    end
  end,
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
  function() return utils.list_bufs({ pattern = "OUTLINE" })[1] end,
  function() vim.cmd("SymbolsOutlineOpen") end,
  function()
    vim.cmd("SymbolsOutlineClose")
    vim.cmd("wincmd =")
  end
)

---@return string[]
local function get_messages()
  local msgs = vim.api.nvim_exec("message", true)
  -- Filter out empty lines.
  return vim.tbl_filter(function(v)
    return v ~= ""
  end, vim.split(msgs, "\n"))
end

local function open_messages_win()
  vim.cmd("belowright sp")
  vim.cmd("wincmd J")
  local bufnr = utils.list_bufs({ vars = { bufid = "messages_window" } })[1]

  if not bufnr then
    bufnr = api.nvim_create_buf(false, false)
    api.nvim_buf_set_name(bufnr, "Messages")
    api.nvim_buf_set_var(bufnr, "bufid", "messages_window")
  end

  local lines = get_messages()
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
  local bufnr = utils.list_bufs({
    vars = { bufid = "messages_window" },
    no_hidden = true,
    tabpage = 0,
  })[1]

  if bufnr then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, get_messages())
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
