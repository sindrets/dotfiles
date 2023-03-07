local CacheEntry = require("user.modules.cache.cache_entry")

---@class user.Cache
---@operator call : user.Cache
---@field store table<any, user.CacheEntry>
local Cache = setmetatable({
  init = function() end,
}, {
  __call = function(t, ...)
    local self = setmetatable({}, { __index = t })
    self:init(...)
    return self
  end,
})

function Cache:init()
  self.store = {}
end

---@param key any
---@param data any
function Cache:put(key, data)
  self.store[key] = CacheEntry(data)
end

---@param key any
---@return any?
function Cache:get(key)
  local entry = self.store[key]

  if entry and entry:is_valid() then
    return entry:get_data()
  end
end

---Invalidate the cache entry associated with the given key if it exists.
---@param key any
function Cache:invalidate(key)
  local entry = self.store[key]
  if entry then entry:invalidate() end
end

---Delete invalid cache entries
function Cache:prune()
  for k, entry in pairs(self.store) do
    if not entry:is_valid() then
      self.store[k] = nil
    end
  end
end

return Cache
