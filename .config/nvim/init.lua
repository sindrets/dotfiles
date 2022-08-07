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
  common = require("nvim-config.common"),
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

Config.lib = require("nvim-config.lib")
Config.term = require("nvim-config.plugins.term")

local alias = require("nvim-config.plugins.cmd_alias").alias
local api = vim.api
local lib = Config.lib
local utils = Config.common.utils

require("nvim-config")

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
alias("Qa", "qa")
alias("QA", "qa")
alias("we", "w | e")
alias("ftd", "filetype detect")

-- FUNCTIONS

Config.fn.toggle_quickfix = lib.create_buf_toggler(
  function()
    return utils.find_buf_with_option("buftype", "quickfix", { no_hidden = true, tabpage = 0 })
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
  function() return utils.find_buf_with_pattern("OUTLINE") end,
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
  end, vim.split(msgs, "\n", {})) --[[@as string[] ]]
end

local function open_messages_win()
  vim.cmd("belowright sp")
  vim.cmd("wincmd J")
  local bufnr = utils.find_buf_with_var("bufid", "messages_window")

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
  local bufnr = utils.find_buf_with_var("bufid", "messages_window", {
    no_hidden = true,
    tabpage = 0,
  })

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
