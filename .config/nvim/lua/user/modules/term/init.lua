local lazy = require("user.lazy")
local utils = Config.common.utils

---@type Terminal
local Terminal = lazy.require("user.modules.term.terminal")
---@type TermSplit
local TermSplit = lazy.require("user.modules.term.term_split")

local api = vim.api

local M = {}

---@class TermState
---@field terminals Terminal[]
---@field cur_term Terminal
---@field term_split TermSplit
Config.state.term = {
  terminals = {},
}

local state = Config.state.term

---@private
---Prune invalid terminals from state.
function M.prune()
  state.terminals = utils.tbl_fmap(state.terminals, function(v)
    ---@cast v Terminal
    return api.nvim_buf_is_valid(v.bufnr) and v or nil
  end)
end

---Set the current terminal in the TermSplit.
---@param term Terminal
---@param focus boolean Open and set the TermSplit as the current window.
function M.set_term(term, focus)
  state.cur_term = term
  state.term_split:set_buf(term.bufnr)

  if focus then
    state.term_split:open(focus)
  end
end

---@private
function M.add_term(term)
  table.insert(state.terminals, term)
end

---@private
function M.remove_term(term)
  local idx = utils.vec_indexof(state.terminals, term)

  if idx > -1 then
    table.remove(state.terminals, idx)
  end
end

---@class term.new.Opt
---@field cmd string|string[] One or multiple commands to run immediately in the new terminal.
---@field cwd string The initial working directory.
---@field focus boolean Bring focus to the new terminal. (default: true)

---Create a new terminal and set it as the current terminal in the TermSplit.
---@param opt term.new.Opt
---@return Terminal?
function M.new(opt)
  opt = vim.tbl_extend("keep", opt or {}, { focus = true }) --[[@as term.new.Opt ]]

  if opt.cwd then
    opt.cwd = pl:vim_fnamemodify(opt.cwd, ":p")

    if not (pl:readable(opt.cwd) and pl:is_dir(opt.cwd)) then
      utils.err("The terminal cwd must be a valid readable directory!")
      return
    end
  end

  local term = Terminal({
    cwd = opt.cwd,
    keymaps = {
      t = {
        ["<M-p>"] = M.prev,
        ["<M-n>"] = M.next,
      },
      n = {
        ["<M-p>"] = M.prev,
        ["<M-n>"] = M.next,
      },
    }
  }) --[[@as Terminal ]]
  term:spawn()

  M.add_term(term)
  M.set_term(term, opt.focus)

  if opt.cmd then
    vim.schedule(function()
      term:send(opt.cmd)
    end)
  end

  return term
end

---Go to the previous terminal.
---@param focus boolean
---@return Terminal?
function M.prev(focus)
  if not M.ensure_term() then return end

  if not state.cur_term or not state.cur_term:is_alive() then
    M.set_term(state.terminals[1], focus)
    return state.cur_term
  end

  local idx = utils.vec_indexof(state.terminals, state.cur_term)

  if idx > -1 then
    local term = state.terminals[(idx - 2) % #state.terminals + 1]
    M.set_term(term, focus)
    return state.cur_term
  end
end

---Go to the next terminal.
---@param focus boolean
---@return Terminal?
function M.next(focus)
  if not M.ensure_term() then return end

  if not state.cur_term or not state.cur_term:is_alive() then
    M.set_term(state.terminals[1], focus)
    return state.cur_term
  end

  local idx = utils.vec_indexof(state.terminals, state.cur_term)

  if idx > -1 then
    local term = state.terminals[(idx) % #state.terminals + 1]
    M.set_term(term, focus)
    return state.cur_term
  end
end

---Send one or multiple commands to the current terminal.
---@param cmd string|string[]
function M.send(cmd)
  if state.cur_term then
    state.cur_term:send(cmd)
  end
end

---@private
function M.ensure_term()
  M.prune()

  return #state.terminals > 0
end

-- Create a new terminal and open the TermSplit.
-- :TermNew [cwd]
-- @param {string} [cwd] - The initial working directory.
api.nvim_create_user_command("TermNew", function(e)
  M.new({ cwd = e.fargs[1] ~= "" and e.fargs[1] or nil })
end, { nargs = "*", complete = "dir" })

-- Open the TermSplit.
api.nvim_create_user_command("TermOpen", function()
  state.term_split:open(true)
end, { bar = true })

-- Close the TermSplit.
api.nvim_create_user_command("TermClose", function()
  state.term_split:close()
end, { bar = true })

-- Toggle the TermSplit.
-- :TermToggle[!]
-- @param [!] - Toggle without bringing focus to the split window.
api.nvim_create_user_command("TermToggle", function(e)
  state.term_split:toggle({ focus_mode = not e.bang, focus = not e.bang })
end, { bar = true, bang = true })

-- Go to the previous terminal.
api.nvim_create_user_command("TermPrev", function ()
  M.prev(false)
end, { bar = true })

-- Go to the next terminal.
api.nvim_create_user_command("TermNext", function ()
  M.next(false)
end, { bar = true })

-- Send a range of lines or the given args to the current terminal. If a range
-- is given, the args are ignored.
-- :[range]TermSend [args]
-- @param [range] - The line range to send.
-- @param {...string} [args] - The command to send.
api.nvim_create_user_command("TermSend", function(e)
  local lines

  if e.range > 0 then
    lines = api.nvim_buf_get_lines(0, e.line1 - 1, e.line2, false)
  elseif e.args ~= "" then
    lines = { e.args }
  end

  if lines then
    state.term_split:open()
    M.send(lines)
  end
end, {
  range = true,
  nargs = "*",
  complete = function(arg_lead)
    local exp = vim.fn.expand(arg_lead) --[[@as string ]]

    if exp == "" or exp == arg_lead then
      exp = nil
    else
      exp = utils.str_quote(exp, { only_if_whitespace = true, prefer_single = true })
    end

    return utils.vec_join(exp, vim.fn.getcompletion(arg_lead, "shellcmd"))
  end,
})

state.term_split = TermSplit()

M.Terminal = Terminal
M.TermSplit = TermSplit

return M
