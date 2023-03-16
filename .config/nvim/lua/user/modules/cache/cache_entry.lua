---@class user.CacheEntry
---@operator call : user.CacheEntry
---@field data any
---@field valid boolean
---@field timestamp integer
---@field expires integer
local CacheEntry = setmetatable({
  init = function() end,
}, {
  __call = function(t, ...)
    local self = setmetatable({}, { __index = t })
    self:init(...)
    return self
  end,
})

---@class user.CacheEntry.opts
---@field lifetime integer # (ms)
---@field expires integer # (ns)

---@param data any
---@param opts? user.CacheEntry.opts
function CacheEntry:init(data, opts)
  opts = opts or {}
  self.data = data
  self.valid = true
  self.timestamp = uv.hrtime()

  assert(not (opts.lifetime and opts.expires), "Fields `lifetime` and `expires` are incompatible!")

  if opts.lifetime then
    self.expires = self.timestamp + (opts.lifetime * 1000000)
  elseif opts.expires then
    self.expires = opts.expires
  end
end

function CacheEntry:invalidate()
  self.valid = false
end

function CacheEntry:is_valid()
  if not self.valid then return false end

  if self.expires then
    if uv.hrtime() > self.expires then
      self:invalidate()
      return false
    end
  end

  return true
end

function CacheEntry:get_data()
  return self.data
end

return CacheEntry
