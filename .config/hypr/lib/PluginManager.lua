--- @namespace hypr.user.lib
---
--- @using imminent
--- @using pebbles

local Path = require("imminent.fs.Path")
local Result = require("imminent.ds.Result")
local async = require("imminent")
local pb = require("imminent.pebbles")
local constants = require("lib.constants")
local utils = require("lib.utils")

local Ok, Err = Result.Ok, Result.Err

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

local function find_hyprpm_lib_files()
  --- @return Result<Array<fs.Path>>
  return async.Future.from(function()
    return async.fs.find(Path.from("/var/cache/hyprpm/$USER"):expand_env(), {
      type = "file",
      names = { "%.so$" },
      plain = false,
      max_depth = 3,
    })
      :await()
      :map(function(entries)
        return entries:map(function(entry)
          return entry.path
        end)
      end)
  end)
end

--- @param plugins PluginSpec[]
function PluginManager.setup(plugins)
  PluginManager.plugins = plugins
  PluginManager.load_plugin_files()
end

--- @private
--- @param name string
--- @param spec_lib_file? string
--- @param hyprpm_libs Lazy<Future<[Array<fs.Path>]>>
function PluginManager.resolve_lib_file(name, spec_lib_file, hyprpm_libs)
  --- @return ds.Result<fs.Path, string>
  return async.Future.from(function()
    if spec_lib_file then
      local lib_path = Path.from(spec_lib_file)
      if lib_path:is_readable():await() then
        return Ok(lib_path)
      end

      return Err(string.format("The given `lib_file` is not readable: %s", spec_lib_file))
    end

    local lib_path = Path.home():join(".cache/hyprland/plugins", name .. ".so"):unwrap()
    if lib_path:is_readable():await() then
      return Ok(lib_path)
    end

    local hyprpm_paths = hyprpm_libs:get():await()
    local hyprpm_lib_path = hyprpm_paths:find(function(path)
      return path:file_stem() == name
    end)

    if hyprpm_lib_path and hyprpm_lib_path:is_readable():await() then
      return Ok(hyprpm_lib_path)
    end

    return Err(string.format("No library file found for '%s'!", name))
  end)
end

function PluginManager.load_plugin_files()
  async.block_on(function()
    --- @return Future<[Array<fs.Path>]>
    local hyprpm_libs = utils.lazy(function()
      return find_hyprpm_lib_files():and_then(function(r)
        return r:unwrap_or(pb.Array.new())
      end)
    end)

    for _, spec in ipairs(PluginManager.plugins) do
      --- @cast spec PluginSpec
      local rspec = pb.assign({ enabled = true }, spec) --[[@as PluginSpec ]]
      if not rspec.enabled then goto continue end

      local name = rspec[1]
      local r_lib_file = PluginManager
        .resolve_lib_file(name, rspec.lib_file, hyprpm_libs)
        :await()

      if r_lib_file:is_err() then
        utils.notify(
          r_lib_file:fmt_context("loading library file for plugin '%s'", name):tostring(),
          { kind = "warn" }
        )
        goto continue
      end

      -- hl.exec_cmd(string.format("hyprctl plugin load '%s'", lib_file:tostring()))
      hl.plugin.load(r_lib_file:unwrap():to_os_path())
      -- TODO: loading can fail, but the API keeps that a secret from us...
      -- Assume loaded. Refactor this if the API improves.
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
