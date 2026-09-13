--- @namespace hypr.user.lib

local async = require("imminent")
local pb = require("imminent.pebbles")

local utils = {}

--- @class notify.Opts
--- @field title? string
--- @field duration_ms? number
--- @field kind? "info"|"warn"|"error"

--- @param msg string
--- @param opts? notify.Opts
function utils.notify(msg, opts)
  opts = pb.assign(
    { title = "Hyprland config" },
    opts
  ) --[[@as notify.Opts ]]

  local cmd_options = {} --- @type string[]

  if opts.duration_ms then
    pb.append(cmd_options, "--expire-time", tostring(opts.duration_ms))
  end

  if opts.kind then
    local icon_name = ({
      info = "dialog-information",
      warn = "dialog-warning",
      error = "dialog-error",
    })[opts.kind]
    if icon_name then pb.append(cmd_options, "--icon", icon_name) end
  end

  local cmd =  pb.concat("notify-send", cmd_options, assert(opts.title), msg)

  async.spawn(async.Job.new({ cmd = cmd }):wait())
end

return utils
