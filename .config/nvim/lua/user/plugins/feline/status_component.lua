--- @namespace user.plugins.feline

local pb = Config.common.pb

local next_id = (function()
  local counter = 0
  return function() counter = counter + 1; return "user_comp_" .. counter end
end)()

--- @class StatusComponent.Provider
--- @field get (fun(): string?)|string
--- @field opts? table
--- @field update? Config.common.au.VimEvent[]|fun(): Config.common.au.VimEvent[]

--- @class StatusComponent.Data
--- @field name string
--- @field enabled boolean|fun(): boolean
--- @field icon? (fun(): (table|string)?)|string
--- @field hl (table|fun(): table)?
--- @field truncate_hide boolean
--- @field priority number
--- @field left_sep string?
--- @field right_sep string?
--- @field provider StatusComponent.Provider

--- @class StatusComponent
--- @field name string
--- @field enabled boolean|fun(): boolean
--- @field icon? (fun(): (table|string)?)|string
--- @field hl (table|fun(): table)?
--- @field truncate_hide boolean
--- @field priority number
--- @field left_sep string?
--- @field right_sep string?
--- @field provider StatusComponent.Provider
--- @overload fun(): StatusComponent.Data
local StatusComponent = {}

--- @private
StatusComponent.__proto = { __index = StatusComponent }

--- @class StatusComponent.new.Opts
--- @field provider string|(fun(): string)|StatusComponent.Provider
--- @field enabled (boolean|fun(): boolean)?
--- @field icon? (fun(): (table|string)?)|string
--- @field hl (table|fun(): table)?
--- @field truncate_hide boolean?
--- @field priority number?
--- @field left_sep string?
--- @field right_sep string?

--- @param opts StatusComponent.new.Opts
--- @return StatusComponent
function StatusComponent.new(opts)
  local self = setmetatable({}, StatusComponent.__proto)

  if type(opts.provider) ~= "table" then
    self.provider = { get = opts.provider }
  else
    self.provider = opts.provider
  end

  self.name = next_id()
  self.enabled = opts.enabled
  self.icon = opts.icon
  self.hl = opts.hl
  self.truncate_hide = not not opts.truncate_hide
  self.priority = opts.priority
  self.left_sep = opts.left_sep
  self.right_sep = opts.right_sep

  return self
end

function StatusComponent:get_provider_spec(provider_config)
  return pb.assign(
    {
      name = type(self.provider.get) == "string" and self.provider.get or self.name,
      opts = self.provider.opts,
      update = self.provider.update,
    },
    provider_config or {}
  )
end

function StatusComponent:set_name(name) self.name = name end

--- @param opts? table
--- @return StatusComponent.Data
function StatusComponent:serialize(opts)
  opts = opts or {}

  return pb.assign(
    {
      name = self.name,
      provider = self:get_provider_spec(opts.provider_config),
      enabled = self.enabled,
      icon = self.icon,
      hl = self.hl,
      truncate_hide = self.truncate_hide,
      pritority = self.priority,
      left_sep = self.left_sep,
      right_sep = self.right_sep,
    },
    opts
  )
end

StatusComponent.__proto.__call = StatusComponent.serialize

return StatusComponent
