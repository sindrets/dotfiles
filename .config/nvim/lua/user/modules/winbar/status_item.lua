local utils = Config.common.utils
local fmt = string.format

---@class user.winbar.StatusItem
---@operator call : user.winbar.StatusItem
---@field content string?
---@field hl string?
---@field children user.winbar.StatusItem[]?
local StatusItem = setmetatable({
  init = function() end,
}, {
  __call = function(t, ...)
    local self = setmetatable({}, { __index = t })
    self:init(...)
    return self
  end,
})

function StatusItem:init(x, hl)
  if type(x) == "table" then
    self.children = utils.vec_slice(x)
  elseif type(x) == "string" then
    self.content = x
  else
    error()
  end

  self.hl = hl
end

function StatusItem:render()
  local ret = ""

  if self.children then
    for _, child in ipairs(self.children) do
      ret = ret .. child:render()
    end
  else
    ret = ret .. fmt("%%#%s#", self.hl or "WinBar") .. self.content
  end

  return ret
end

function StatusItem:get_content()
  local ret = ""

  if self.children then
    for _, child in ipairs(self.children) do
      ret = ret .. child:get_content()
    end
  else
    ret = ret .. self.content
  end

  return ret
end

---@param item user.winbar.StatusItem
function StatusItem:add_child(item)
  if not self.children then self.children = {} end
  self.content = nil
  self.hl = nil
  table.insert(self.children, item)
end

function StatusItem:get_children()
  return self.children
end

return StatusItem
