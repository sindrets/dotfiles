local oop = require("user.oop")

local uid_counter = 0
local function get_uid()
  uid_counter = uid_counter + 1
  return "user_comp_" .. uid_counter
end

---@class StatusComponent.provider
---@field get function|string
---@field opts table
---@field update string[]|function

---@class StatusComponent : user.Object
---@operator call : StatusComponent
---@field provider StatusComponent.provider
local StatusComponent = oop.create_class("StatusComponent")

function StatusComponent:init(opt)
  if type(opt.provider) ~= "table" then
    self.provider = { get = opt.provider }
  else
    self.provider = opt.provider
  end

  self.name = get_uid()
  self.enabled = opt.enabled
  self.icon = opt.icon
  self.hl = opt.hl
  self.truncate_hide = opt.truncate_hide
  self.priority = opt.priority
  self.left_sep = opt.left_sep
  self.right_sep = opt.right_sep

  local mt = getmetatable(self)

  function mt.__call(_, call_opt)
    call_opt = call_opt or {}
    return vim.tbl_extend("keep", call_opt, {
      name = self.name,
      provider = self:get_provider_spec(call_opt.provider_config),
      enabled = self.enabled,
      icon = self.icon,
      hl = self.hl,
      truncate_hide = self.truncate_hide,
      pritority = self.priority,
      left_sep = self.left_sep,
      right_sep = self.right_sep,
    })
  end
end

function StatusComponent:get_provider_spec(provider_config)
  return vim.tbl_extend("keep", provider_config or {}, {
    name = type(self.provider.get) == "string" and self.provider.get or self.name,
    opts = self.provider.opts,
    update = self.provider.update,
  })
end

function StatusComponent:set_name(name)
  self.name = name
end

return StatusComponent
