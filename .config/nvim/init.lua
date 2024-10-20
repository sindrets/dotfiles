_G.prequire = function(modname)
  local ok, mod = pcall(require, modname)
  if ok then return mod end
end

---Pretty print. Alias for `vim.inspect()`.
_G.pp = function(a, opt) print(vim.inspect(a, opt)) end

---LibUV
_G.uv = vim.loop

_G.Config = {
  fn = {},
  plugin = {},
  state = {},
}

Config.common = require("user.common")

---Path library.
_G.pl = Config.common.utils.pl

Config.lib = require("user.lib")
Config.term = require("user.modules.term")

Config.buf_cleaner = require("user.modules.buf_cleaner")
Config.buf_cleaner.enable(true)

local Cache = require("user.modules.cache")

Config.state.git = {
  rev_name_cache = Cache(),
}

local alias = require("user.modules.cmd_alias").alias
local api = vim.api
local lib = Config.lib
local utils = Config.common.utils

require("user")
api.nvim_create_autocmd("VimEnter", {
  callback = function() require("user.modules.winbar").init() end,
})

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
alias({ "gd", "DO" }, "DiffviewOpen")
alias("gl", "DiffviewFileHistory")
alias("Q", "q")
alias({ "Qa", "QA", "QA!" }, "qa")
alias({ "WQA", "WQa", "Wqa" }, "wqa")
alias("we", "w | e")
alias("ws", "w | so %")
alias("ftd", "filetype detect")
alias("N", "Neorg")
alias("nim", "Neorg inject-metadata")
-- Toggle conceallevel:
alias("tcl", "exe 'setl conceallevel=' . (&conceallevel == 0 ? 2 : 0)")
alias("do", "diffget")
alias("dp", "diffput")

-- FUNCTIONS

Config.fn.toggle_quickfix = lib.create_view_toggler({
  find = function()
    return utils.list_bufs({
      options = { buftype = "quickfix" },
      no_hidden = true,
      tabpage = 0,
    })[1]
  end,
  open = function()
    if #vim.fn.getloclist(0) > 0 then
      vim.cmd("belowright lope")
    else
      vim.cmd("belowright cope | wincmd J")
    end
  end,
  close = function()
    if vim.fn.win_gettype() == "quickfix" then
      vim.cmd("ccl")
    else
      vim.cmd("lcl")
    end
  end,
  focus = true,
  remember_height = true,
})

Config.fn.toggle_outline = lib.create_view_toggler({
  find = function() return utils.list_bufs({ pattern = "OUTLINE" })[1] end,
  open = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
      callback = function()
        vim.schedule(function() vim.cmd("wincmd =") end)
        return true
      end,
    })

    vim.cmd("Outline")
  end,
  close = function()
    vim.cmd("OutlineClose")
    vim.cmd("wincmd =")
  end,
  focus = true,
})

Config.fn.toggle_diagnostics = lib.create_view_toggler({
  find = function()
    return utils.list_bufs({
      options = { filetype = "trouble" },
      no_hidden = true,
      tabpage = 0,
    })[1]
  end,
  open = function() vim.cmd("Trouble diagnostics") end,
  close = function()
    local winid = vim.api.nvim_get_current_win()
    vim.cmd("wincmd p")
    vim.api.nvim_win_close(winid, false)
  end,
  focus = true,
  remember_height = true,
})

---@return string[]
local function get_messages()
  local ret = api.nvim_exec2("messages", { output = true })
  -- Filter out empty lines.
  return vim.tbl_filter(function(v) return v ~= "" end, vim.split(ret.output, "\n"))
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
