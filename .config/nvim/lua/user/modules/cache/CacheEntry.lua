--- @namespace user.modules.cache
--- @using imminent

local lz = require("user.lazy")

local Option = lz.require("imminent.ds.Option") ---@module "imminent.ds.Option"

--- @class CacheEntry<T>
--- @field private data T
--- @field private valid boolean
--- @field private timestamp integer
--- @field private expires integer
--- @overload fun<T>(data: T, opts?: CacheEntry.new.Opts): CacheEntry<T>
local CacheEntry = {}

--- @alias CacheEntry.new.Opts
--- # (ms)
--- | { ttl: int }
--- # (ns)
--- | { expires: int }

--- @generic T
--- @param data T
--- @param opts? CacheEntry.new.Opts
--- @return CacheEntry<T>
function CacheEntry.new(data, opts)
  opts = opts or {} --[[@as CacheEntry.new.Opts ]]

  local self = setmetatable({}, { __index = CacheEntry })
  self.data = data
  self.valid = true
  self:resolve_lifetime(opts)

  return self
end

--- Create a new stale cache entry.
---
--- @return CacheEntry<any>
function CacheEntry.Stale()
  local ret = CacheEntry.new(nil)
  ret:invalidate()

  return ret
end

--- @private
--- @param opts CacheEntry.new.Opts
function CacheEntry:resolve_lifetime(opts)
  self.timestamp = uv.hrtime() --[[@as int ]]

  assert(not (opts.ttl and opts.expires), "Fields `ttl` and `expires` are mutually exclusive!")

  if opts.ttl then
    self.expires = self.timestamp + (opts.ttl * 1000000)
  elseif opts.expires then
    self.expires = opts.expires
  else
    self.expires = math.huge --[[@as int ]]
  end
end

--- @private
function CacheEntry:update_status()
  if self.valid and uv.hrtime() > self.expires then
    self.valid = false
  end
end

--- Invalidate the cache entry.
---
function CacheEntry:invalidate()
  self.valid = false
end

--- Check if the cache entry is valid.
---
--- @return boolean
function CacheEntry:is_valid()
  if not self.valid then return false end
  self:update_status()

  return self.valid
end

--- (Mutative) Update and replace the data in the cache entry, optionally also
--- update it's lifetime.
---
--- @param data T
--- @param opts? CacheEntry.new.Opts
function CacheEntry:update(data, opts)
  self.data = data
  self:resolve_lifetime(opts or { expires = self.expires })
end

--- @return ds.Option<T>
function CacheEntry:get()
  if self:is_valid() then
    return Option.Some(self.data)
  end

  return Option.None()
end

--- Unwrap the contained, valid data.
---
--- ## Raises
---
--- Raises an error if the cache entry is stale.
---
function CacheEntry:unwrap()
  if not self:is_valid() then
    error("Tried to unwrap a stale cache entry!")
  end

  return self.data
end

return CacheEntry
