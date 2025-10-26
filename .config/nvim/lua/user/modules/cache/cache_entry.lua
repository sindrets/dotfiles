local oop = require("user.oop")

--- @class user.CacheEntry
--- @field data any
--- @field valid boolean
--- @field timestamp integer
--- @field expires integer
--- @overload fun(data: any, opts?: user.CacheEntry.Opts): user.CacheEntry
local CacheEntry = oop.create_class("CacheEntry")

--- @class user.CacheEntry.Opts
--- @field ttl integer # (ms)
--- @field expires integer # (ns)

--- @param data any
--- @param opts? user.CacheEntry.Opts
function CacheEntry:init(data, opts)
  opts = opts or {}
  self.data = data
  self.valid = true
  self.timestamp = uv.hrtime()

  assert(not (opts.ttl and opts.expires), "Fields `ttl` and `expires` are incompatible!")

  if opts.ttl then
    self.expires = self.timestamp + (opts.ttl * 1000000)
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
