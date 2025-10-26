local oop = require("user.oop")

local Path = Config.common.utils.Path
local utils = Config.common.utils
local api = vim.api

local uid_counter = 0

local function get_uid()
  uid_counter = uid_counter + 1
  return uid_counter
end

local function get_shell()
  return vim.o.shell
end

---@class Terminal : user.Object
---@field id integer
---@field jobid integer
---@field bufnr integer
---@field name string
---@field cwd imminent.fs.Path
---@field keymaps table
local Terminal = oop.create_class("Terminal")

Terminal.bufopts = {
  undolevels = -1,
}

Terminal.winopts = {
  nu = false,
  rnu = false,
  list = false,
  signcolumn = "yes:1",
}

---@class Terminal.init.Opt
---@field bufnr integer
---@field cwd string|imminent.fs.Path
---@field keymaps table

---@param opt Terminal.init.Opt
function Terminal:init(opt)
  opt = opt or {}
  local cwd --- @type imminent.fs.Path?

  if opt.cwd then
    cwd = (
      type(opt.cwd) == "string"
        and Path.from(opt.cwd --[[@as string ]])
        or opt.cwd --[[@as imminent.fs.Path ]]
    )
      :absolute()

    assert(
      cwd:is_readable():block_on() and cwd:is_dir():block_on(),
      "The terminal cwd must be a valid readable directory!"
    )
  end

  self.id = get_uid()
  self.cwd = cwd or Path.cwd()
  self.keymaps = opt.keymaps or {}
  self.bufnr = opt.bufnr or self:create_buffer()
end

---Check whether or not the terminal job is running.
---@return boolean
function Terminal:is_alive()
  return self.jobid and utils.pick(1, pcall(vim.fn.jobpid, self.jobid))
end

---Spawn the terminal job.
function Terminal:spawn()
  if self:is_alive() then return end

  api.nvim_buf_call(self.bufnr, function()
    local cmd = { get_shell(), }

    self.jobid = vim.fn.termopen(cmd, {
      detach = 1,
      cwd = self.cwd:absolute():tostring(),
    })

    if self.name then
      api.nvim_buf_set_name(self.bufnr, self.name)
    end
  end)
end

---Send one or multiple commands to the terminal.
---@param cmd string|string[]
function Terminal:send(cmd)
  if type(cmd) ~= "table" then
    cmd = { cmd }
  end

  cmd = vim.tbl_map(function(v)
    return v .. "\n"
  end, cmd) --[[@as vector ]]

  vim.fn.chansend(self.jobid, table.concat(cmd, ""))

  if api.nvim_get_current_buf() ~= self.bufnr then
    api.nvim_buf_call(self.bufnr, function()
      vim.cmd("norm! G")
    end)
  end
end

---@private
---@return integer bufnr
function Terminal:create_buffer()
  local bufnr = api.nvim_create_buf(false, false)
  self.name = ("termsplit://%d/terminal (%d)"):format(self.id, self.id)

  api.nvim_buf_call(bufnr, function ()
    for k, v in pairs(Terminal.bufopts) do
      vim.opt_local[k] = v
    end
  end)

  for _, mode in ipairs({ "t", "n", "i", "v", "x" }) do
    for lhs, rhs in pairs(self.keymaps[mode] or {}) do
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
    end
  end

  return bufnr
end

return Terminal
