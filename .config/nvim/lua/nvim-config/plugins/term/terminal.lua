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

---@class Terminal
---@field id integer
---@field jobid integer
---@field bufnr integer
---@field name string
---@field cwd string
---@field keymaps table
local Terminal
Terminal = setmetatable({}, {
  init = function() --[[ stub ]] end,
  __call = function(_, ...)
    local this = setmetatable({}, vim.tbl_extend("keep", Terminal, {
      __index = function(t, k)
        return getmetatable(t)[k]
      end,
    }))

    this:init(...)

    return this
  end,
}) --[[@as Terminal ]]

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
---@field cwd string
---@field keymaps table

---@param opt Terminal.init.Opt
function Terminal:init(opt)
  opt = opt or {}
  local cwd

  if opt.cwd then
    cwd = pl:vim_fnamemodify(opt.cwd, ":p")

    assert(
      pl:readable(cwd) and pl:is_dir(cwd),
      "The terminal cwd must be a valid readable directory!"
    )
  else
    cwd = uv.cwd()
  end

  self.id = get_uid()
  self.cwd = cwd
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
      cwd = pl:vim_fnamemodify(self.cwd, ":p"),
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
