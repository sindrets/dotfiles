--- @namespace user.modules.term
--- @using imminent
--- @using pebbles

local api = vim.api
local pb = Config.common.pb

local id_counter = 0

local function next_id()
  id_counter = id_counter + 1
  return id_counter
end

--- @return string
local function get_shell()
  return vim.o.shell
end

--- @class Terminal
--- @field id int
--- @field jobid int
--- @field bufnr int
--- @field display_name? string
--- @field bufname string
--- @field cmd string[]?
--- @field cwd fs.Path
--- @field keymaps table<string, table<string, string|function>>
local Terminal = {}

Terminal.bufopts = {
  undolevels = -1,
}

Terminal.winopts = {
  nu = false,
  rnu = false,
  list = false,
  signcolumn = "yes:1",
}

--- @class Terminal.init.Opts
--- @field cmd? string[]
--- @field name? string
--- @field bufnr? int
--- @field cwd? string|fs.Path
--- @field keymaps? table<string, table<string, string|function>>

---@param opts Terminal.init.Opts
function Terminal.new(opts)
  opts = opts or {}
  local self = setmetatable({}, { __index = Terminal })
  self.cmd = opts.cmd
  self.display_name = opts.name
  local cwd --- @type fs.Path?

  if opts.cwd then
    cwd = (
      type(opts.cwd) == "string"
        and Path.from(opts.cwd --[[@as string ]])
        or opts.cwd --[[@as fs.Path ]]
    )
      :absolute()

    assert(
      cwd:is_readable():block_on() and cwd:is_dir():block_on(),
      "The terminal cwd must be a valid readable directory!"
    )
  end

  self.id = next_id()
  self.cwd = cwd or Path.cwd()
  self.keymaps = opts.keymaps or {}
  self.bufnr = opts.bufnr or self:create_buffer()

  return self
end

--- Check whether or not the terminal job is running.
---
--- @return boolean
function Terminal:is_alive()
  return self.jobid and pb.pick(1, pcall(vim.fn.jobpid, self.jobid))
end

--- Spawn the terminal job.
function Terminal:spawn()
  if self:is_alive() then return end

  api.nvim_buf_call(self.bufnr, function()
    local cmd = self.cmd or { get_shell(), }

    self.jobid = vim.fn.termopen(cmd, {
      detach = 1,
      cwd = self.cwd:absolute():tostring(),
    })

    if self.bufname then
      api.nvim_buf_set_name(self.bufnr, self.bufname)
    end
  end)
end

--- @class Terminal.send.Opts
--- Automatically append carriage returns to the end of each command. (default:
--- `true`)
--- @field auto_cr? boolean

--- Send one or multiple commands to the terminal.
---
--- @param cmd string|string[]
--- @param opts? Terminal.send.Opts
function Terminal:send(cmd, opts)
  opts = pb.extend({ auto_cr = true }, opts or {}) --[[@as Terminal.send.Opts ]]
  --- @cast opts -?

  if type(cmd) ~= "table" then cmd = { cmd } end
  --- @cast cmd string[]

  vim.fn.chansend(
    self.jobid,
    pb.iter(cmd)
      :map(function(v) return v .. (opts.auto_cr and "\n" or "") end)
      :join(opts.auto_cr and "" or " ")
  )

  if api.nvim_get_current_buf() ~= self.bufnr then
    api.nvim_buf_call(self.bufnr, function()
      vim.cmd("norm! G")
    end)
  end
end

--- @private
--- @return int bufnr
function Terminal:create_buffer()
  local bufnr = api.nvim_create_buf(false, false)
  self.bufname = pb.format(
    "termsplit://{id}/{display_name}",
    {
      id = self.id,
      display_name = self.display_name or string.format("terminal (%s)", self.id),
    }
  )

  api.nvim_buf_call(bufnr, function()
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
