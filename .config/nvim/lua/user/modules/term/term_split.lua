local oop = require("user.oop")
local lazy = require("user.lazy")

local utils = Config.common.utils

local Terminal = lazy.require("user.modules.term.terminal") ---@type Terminal
local term_lib = lazy.require("user.modules.term") ---@module "user.modules.term"

local api = vim.api
local state = Config.state.term

local function save_actual()
  state.actual_curwin = api.nvim_get_current_win()
  state.actual_curbuf = api.nvim_get_current_buf()
end

local function clear_actual()
  state.actual_curwin = nil
  state.actual_curbuf = nil
end

---@alias TermSplit.Position "left"|"top"|"right"|"bottom"

---@class TermSplit.Config
---@field position TermSplit.Position
---@field width integer
---@field height integer

---@class TermSplit : user.Object
---@field winid integer
---@field bufnr integer
---@field config TermSplit.Config
---@field last_width integer
---@field last_height integer
local TermSplit = oop.create_class("TermSplit")

TermSplit.winopts = {
  winfixwidth = true,
  winfixheight = true,
}

function TermSplit:init(position)
  self.config = {
    position = position or "bottom",
    width = 100,
    height = 16,
  }
end

---@private
---Load the assigned buffer into the window. Creates a new terminal is no
---buffer is assigned.
function TermSplit:load_buf()
  assert(self:is_open())

  local actual_curwin = state.actual_curwin or api.nvim_get_current_win()

  if api.nvim_win_get_buf(self.winid) == self.bufnr then
    return
  end

  if not (self.bufnr and api.nvim_buf_is_valid(self.bufnr)) then
    local term = term_lib.prev(false)

    if not term then
      term = term_lib.new({ focus = false }) --[[@as Terminal ]]
    end

    self.bufnr = term.bufnr
  end

  api.nvim_win_set_buf(self.winid, self.bufnr)

  api.nvim_win_call(self.winid, function()
    for k, v in pairs(Terminal.winopts) do
      vim.opt_local[k] = v
    end
  end)

  if actual_curwin == self.winid then
    -- HACK: This is the only way I found to reliably update the terminal
    -- buffer such that the terminal window dimensions are updated and the
    -- cursorline is disabled when terminal mode is entered.
    --
    -- Things that don't work:
    --    • Manually triggering BufEnter / WinEnter / TermEnter
    --    • Stopping insertmode / terminal mode before changing buffers.
    --    • Toggling insertmode without scheduling. Possibly an internal
    --      machanism that prevents this.
    --
    --  Things to explore:
    --    • Resizing the terminal window. Resizing the window always updates
    --      the terminal buffer, however there's a whole series of other jank
    --      involved with this solution (window rendering becoming off by 1
    --      cell, statusline disappearing...).
    vim.cmd("stopinsert")
    vim.schedule(function()
      vim.cmd("startinsert")
    end)
  end
end

---@param tabpage? integer
---@return boolean
function TermSplit:is_open(tabpage)
  local valid = self.winid and api.nvim_win_is_valid(self.winid)

  if not valid then
    self.winid = nil
  elseif tabpage then
    return vim.tbl_contains(api.nvim_tabpage_list_wins(tabpage), self.winid)
  end

  return valid
end

---@return boolean
function TermSplit:is_focused()
  return self:is_open() and api.nvim_get_current_win() == self.winid
end

---Open the window and load the assigned terminal buffer.
---@param focus? boolean Set the opened window as the current window.
function TermSplit:open(focus)
  save_actual()

  if self:is_open(0) then
    self:load_buf()

  else
    -- Window might be open in another tabpage. Close it.
    self:close()

    local pos = self.config.position
    local form = vim.tbl_contains({ "top", "bottom" }, pos) and "row" or "col"
    local split_dir = vim.tbl_contains({ "top", "left" }, pos) and "aboveleft" or "belowright"
    local split_cmd = form == "row" and "sp" or "vsp"

    api.nvim_win_call(0, function()
      vim.cmd(split_dir .. " " .. split_cmd)
      self.winid = api.nvim_get_current_win()
      self:load_buf()
      local dir = ({ left = "H", bottom = "J", top = "K", right = "L" })[pos]
      vim.cmd("wincmd " .. dir)

      local w = self.last_width or math.min(self.config.width, vim.o.columns / 2)
      local h = self.last_height or math.min(self.config.height, vim.o.lines / 2)

      if form == "row" then
        vim.cmd("resize " .. h)
      else
        vim.cmd("vert resize " .. w)
      end
    end)

    utils.set_local(self.winid, TermSplit.winopts)
  end

  clear_actual()

  if focus then
    api.nvim_set_current_win(self.winid)
    vim.cmd("startinsert")
  end
end

---Close the window.
function TermSplit:close()
  if not self:is_open() then return end

  local cur_pos = utils.detect_win_pos(self.winid)

  -- Remember the window position
  if cur_pos ~= "unknown" then
    self.config.position = cur_pos
  end

  self.last_width = api.nvim_win_get_width(self.winid)
  self.last_height = api.nvim_win_get_height(self.winid)

  if api.nvim_get_current_win() == self.winid then
    -- Go to the last accessed window before closing.
    vim.cmd("wincmd p")
  end

  api.nvim_win_close(self.winid, false)
end

---@class TerminalSplit.toggle.Opt
---@field focus boolean Set the window as the current window.
---@field focus_mode boolean If the window is open but unfocused: bring focus to the window instead of closing it. (implies `focus`)

---Toggle the window.
---@param opt TerminalSplit.toggle.Opt
function TermSplit:toggle(opt)
  opt = opt or {}

  if opt.focus_mode then opt.focus = true end

  local should_close = utils.ternary(
    opt.focus_mode,
    { self.is_focused, self },
    { self.is_open, self, 0 }
  )

  if should_close then
    self:close()
  else
    self:open(opt.focus)
  end
end

---Set the assigned terminal buffer.
---@param bufnr integer Buffer number.
function TermSplit:set_buf(bufnr)
  self.bufnr = bufnr

  if self:is_open() then
    local manage_state = not state.actual_curwin

    if manage_state then
      save_actual()
    end

    self:load_buf()

    if manage_state then
      clear_actual()
    end
  end
end

return TermSplit
