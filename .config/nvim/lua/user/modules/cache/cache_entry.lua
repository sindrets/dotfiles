---@class user.CacheEntry
---@operator call : user.CacheEntry
---@field data any
---@field valid boolean
---@field timestamp integer
local CacheEntry = setmetatable({
  init = function() end,
}, {
  __call = function(t, ...)
    local self = setmetatable({}, { __index = t })
    self:init(...)
    return self
  end,
})

function CacheEntry:init(data)
  self.data = data
  self.valid = true
  self.timestamp = uv.hrtime()
end

function CacheEntry:invalidate()
  self.valid = false
end

function CacheEntry:is_valid()
  return self.valid
end

function CacheEntry:get_data()
  return self.data
end

return CacheEntry
