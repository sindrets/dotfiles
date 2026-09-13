--- @namespace hypr.user.lib
---
--- @using imminent
--- @using pebbles

local Path = require("imminent.fs.Path")
local async = require("imminent")
local pb = require("imminent.pebbles")
local constants = require("lib.constants")
local utils = require("lib.utils")

local PluginManager = {}

--- @type PluginSpec[]
PluginManager.plugins = {}
--- @type table<string, PluginState>
PluginManager.state = {}

local get_plugin_config_paths = pb.once(function()
  --- @return Array<fs.Path>
  return async.Future.from(function()
    return async.fs.ls(constants.CONF_DIR .. "/plugins", { max_depth = 1 })
      :await()
      :unwrap()
      :map(function(entry)
        return entry.path:extension() == "lua" and
          entry.path or
          pb.None
      end)
  end)
end)

--- @param plugins PluginSpec[]
function PluginManager.setup(plugins)
  PluginManager.plugins = plugins
  PluginManager.load_plugin_files()
end

function PluginManager.load_plugin_files()
  async.block_on(function()
    for _, spec in ipairs(PluginManager.plugins) do
      --- @cast spec PluginSpec
      local rspec = pb.assign({ enabled = true }, spec) --[[@as PluginSpec ]]
      if not rspec.enabled then goto continue end

      local name = rspec[1]
      local lib_file = rspec.lib_file and
        Path.from(rspec.lib_file) or
        Path.home():join(".cache/hyprland/plugins", name .. ".so"):unwrap()

      if not lib_file:is_readable():await() then
        utils.notify(
          string.format("Missing library file for plugin (%s): %s", name, lib_file:tostring()),
          { kind = "warn" }
        )
        goto continue
      end

      -- hl.exec_cmd(string.format("hyprctl plugin load '%s'", lib_file:tostring()))
      hl.plugin.load(lib_file:to_os_path())
      PluginManager.state[name] = { loaded = true }

      ::continue::
    end
  end)
end

function PluginManager.load_plugin_configs()
  async.block_on(function()
    for _, spec in ipairs(PluginManager.plugins) do
      --- @cast spec PluginSpec
      local name = spec[1]
      local state = PluginManager.state[name]
      if not state or not state.loaded then goto continue end

      local config_path = get_plugin_config_paths():await():find(function(p)
        return p:file_stem() == name
      end)

      if config_path then
        local ok, err = pcall(dofile, config_path:to_os_path())
        if not ok then
          utils.notify(
            string.format("Failed to source plugin config (%s): %s", name, err),
            { kind = "error", duration_ms = 10000 }
          )
        end
      end

      ::continue::
    end
  end)
end

--- @param name string
--- @return boolean
function PluginManager.is_loaded(name)
  return not not pb.get(PluginManager.state, { name, "loaded" })
end

--- @generic T
--- @param name string
--- @param value T
--- @param fallback T|nil
--- @return T
function PluginManager.if_loaded(name, value, fallback)
  if PluginManager.is_loaded(name) then
    return value
  else
    return fallback
  end
end

return PluginManager


--- @class PluginSpec
--- @field [1] string
--- @field enabled? boolean
--- @field lib_file? string

--- @class PluginState
--- @field loaded boolean
