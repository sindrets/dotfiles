local utils = Config.common.utils
local fmt = string.format

---@class user.winbar.StatusItem.state
---@field valid boolean
---@field rendered_string string
---@field content_string string

---@class user.winbar.StatusItem
---@operator call : user.winbar.StatusItem
---@field content string?
---@field hl string?
---@field children user.winbar.StatusItem[]?
---@field state user.winbar.StatusItem.state
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
  self.state = { valid = false }
end

function StatusItem:invalidate()
  self.state.valid = false
end

function StatusItem:is_valid()
  return self.state.valid
end

function StatusItem:render()
  if not self:is_valid() then
    self:_update()
  end

  return self.state.rendered_string
end

function StatusItem:get_content()
  if not self:is_valid() then
    self:_update()
  end

  return self.state.content_string
end

---@param item user.winbar.StatusItem
function StatusItem:add_child(item)
  if not self.children then self.children = {} end
  self.content = nil
  self.hl = nil
  table.insert(self.children, item)
  self:invalidate()
end

function StatusItem:get_children()
  return self.children
end

---@private
function StatusItem:_render()
  local ret = ""

  if self.children then
    for _, child in ipairs(self.children) do
      ret = ret .. child:_render()
    end
  else
    ret = ret .. fmt("%%#%s#", self.hl or "WinBar") .. (self.content:gsub("%%", "%%%%"))
  end

  return ret
end

---@private
function StatusItem:_content()
  local ret = ""

  if self.children then
    for _, child in ipairs(self.children) do
      ret = ret .. child:_content()
    end
  else
    ret = ret .. self.content
  end

  return ret
end

---@private Render and update state.
function StatusItem:_update()
  if self:is_valid() then return end
  local rs = ""
  local cs = ""

  if self.children then
    for _, child in ipairs(self.children) do
      rs = rs .. child:_render()
      cs = cs .. child:_content()
    end
  else
    rs = rs .. self:_render()
    cs = cs .. self:_content()
  end

  self.state.rendered_string = rs
  self.state.content_string = cs
  self.state.valid = true
end

return StatusItem
