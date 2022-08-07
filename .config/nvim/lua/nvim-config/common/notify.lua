local configs = {
  git = {
    title = "git",
    icon = "",
  },
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
