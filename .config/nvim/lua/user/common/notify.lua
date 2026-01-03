local configs = {
  git = {
    title = "Git",
    icon = "󰊢",
  },
  config = {
    title = "Config",
    icon = "",
  },
  shell = {
    title = "Shell",
    icon = "",
  }
}

local levels = {
  trace = vim.log.levels.TRACE,
  debug = vim.log.levels.DEBUG,
  info = vim.log.levels.INFO,
  warn = vim.log.levels.WARN,
  error = vim.log.levels.ERROR,
}

local this = {
  cur = {},
}

---@class Notify.Opt
---@field title? string
---@field icon? string
---@field [string] any

---@class Notify
---@overload fun(msg: string, opt?: Notify.Opt)
---@field trace Notify
---@field debug Notify
---@field info Notify
---@field warn Notify
---@field error Notify
---@field [string] Notify
local notify = setmetatable(this, {
  __index = function(_, k)
    if configs[k] then
      this.cur.config = configs[k]
    elseif levels[k] then
      this.cur.level = levels[k]
    end

    return this
  end,
  __call = function(_, msg, opt)
    opt = vim.tbl_deep_extend("force", this.cur.config or {}, opt or {})
    vim.notify(msg, this.cur.level or vim.log.levels.INFO, opt)
    this.cur.config = nil
    this.cur.level = nil
  end,
})

return notify
