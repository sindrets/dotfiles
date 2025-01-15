local CacheEntry = require("user.modules.cache.cache_entry")
local oop = require("user.oop")

--- @class user.Cache
--- @field store table<any, user.CacheEntry?>
--- @overload fun(): user.Cache
local Cache = oop.create_class("Cache")

function Cache:init()
  self.store = {}
end

--- @param key any
--- @param data any
--- @param opts? user.CacheEntry.Opts
function Cache:put(key, data, opts)
  self.store[key] = CacheEntry(data, opts)
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
