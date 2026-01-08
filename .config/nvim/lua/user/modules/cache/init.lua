--- @namespace user.modules.cache

local CacheEntry = require('user.modules.cache.CacheEntry')

--- @class Cache
--- @field store table<any, CacheEntry?>
--- @overload fun(): Cache
local Cache = {}

function Cache.new()
  local self = setmetatable({}, { __index = Cache })
  self.store = {}

  return self
end

--- @param key any
--- @param data any
--- @param opts? CacheEntry.Opts
function Cache:put(key, data, opts)
  self.store[key] = CacheEntry.new(data, opts)
end

--- Check if the cache contains a valid entry for the given key.
---
--- @param key any
--- @return boolean
function Cache:has(key)
  local entry = self.store[key]

  return not not (entry and entry:is_valid())
end

--- @param key any
--- @return any?
function Cache:get(key)
  local entry = self.store[key]

  if entry and entry:is_valid() then
    return entry:get_data()
  end
end

--- Invalidate the cache entry associated with the given key if it exists.
--- @param key any
function Cache:invalidate(key)
  local entry = self.store[key]
  if entry then entry:invalidate() end
end

--- Delete invalid cache entries
function Cache:prune()
  for k, entry in pairs(self.store) do
    if not entry:is_valid() then
      self.store[k] = nil
    end
  end
end

return Cache
