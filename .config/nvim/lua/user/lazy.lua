--- @doc.ctx skipfile

local fmt = string.format

--- @return pebbles.Packed<any>
local function pack(...)
  return { n = select("#", ...), ... }
end

local lazy = {}

--- @class Config.lazy.LazyModule : any
--- @field __get fun(): unknown Load the module if needed, and return it.
--- @field __loaded boolean Indicates that the module has been loaded.
--- @field [string] any

--- @param spec string|function
--- @param wrap_values? boolean
--- @param on_load? fun(loaded)
local function create_loader(spec, wrap_values, on_load)
  local handler

  if on_load then
    handler = function(loaded)
      on_load(loaded)
      return loaded
    end
  end

  return function()
    if type(spec) == "string" then
      if wrap_values then
        return lazy.require(spec, handler)
      else
        if handler then
          return handler(require(spec))
        else
          return require(spec)
        end
      end
    elseif type(spec) == "function" then
      if wrap_values then
        return lazy.wrap({}, handler)
      else
        if handler then
          return handler(spec())
        else
          return spec()
        end
      end
    end
  end
end

--- Create a table the triggers a given handler every time it's accessed or
--- called, until the handler returns a table. Once the handler has returned a
--- table, any subsequent accessing of the wrapper will instead access the table
--- returned from the handler.
---
--- @param t any
--- @param handler fun(t: any): table?
--- @return Config.lazy.LazyModule
function lazy.wrap(t, handler)
  local export

  local ret = {
    __get = function()
      if export == nil then
        ---@cast handler function
        export = handler(t)
      end

      return export
    end,
    __loaded = function()
      return export ~= nil
    end,
  }

  return setmetatable(ret, {
    __index = function(_, key)
      if export == nil then ret.__get() end
      ---@cast export table
      return export[key]
    end,
    __newindex = function(_, key, value)
      if export == nil then ret.__get() end
      export[key] = value
    end,
    __call = function(_, ...)
      if export == nil then ret.__get() end
      ---@cast export table
      return export(...)
    end,
  })
end

--- Will only require the module after first either indexing, or calling it.
---
--- You can pass a handler function to process the module in some way before
--- returning it. This is useful i.e. if you're trying to require the result of
--- an exported function.
---
--- Example:
---
--- ```lua
--- local foo = require("bar")
--- local foo = lazy.require("bar")
---
--- local foo = require("bar").baz({ qux = true })
--- local foo = lazy.require("bar", function(module)
---    return module.baz({ qux = true })
--- end)
--- ```
--- @param require_path string
--- @param handler? fun(module: any): any
--- @return Config.lazy.LazyModule
function lazy.require(require_path, handler)
  local use_handler = type(handler) == "function"

  return lazy.wrap(require_path, function(s)
    if use_handler then
      ---@cast handler function
      return handler(require(s))
    end
    return require(s)
  end)
end

--- Lazily access a table value. If `x` is a string, it's treated as a lazy
--- require.
---
--- Example:
---
--- ```lua
--- -- table:
--- local foo = bar.baz.qux.quux
--- local foo = lazy.get(bar, "baz.qux.quux")
--- local foo = lazy.get(bar, { "baz", "qux", "quux" })
---
--- -- require:
--- local foo = require("bar").baz.qux.quux
--- local foo = lazy.get("bar", "baz.qux.quux")
--- local foo = lazy.get("bar", { "baz", "qux", "quux" })
--- ```
--- @param x table|string Either the table to be accessed, or a module require path.
--- @param access_path string|string[] Either a `.` separated string of table keys, or a list.
--- @return Config.lazy.LazyModule
function lazy.get(x, access_path)
  local keys = type(access_path) == "table"
      and access_path
      or vim.split(access_path --[[@as string ]], ".", { plain = true })

  local handler = function(module)
    local export = module

    for _, key in ipairs(keys) do
      export = export[key]
      assert(export ~= nil, fmt("Failed to lazy-access! No key '%s' in table!", key))
    end

    return export
  end

  if type(x) == "string" then
    return lazy.require(x, handler)
  else
    return lazy.wrap(x, handler)
  end
end

--- Lazily put a value or require a module into a table.
---
--- @param t any
--- @param key any
--- @param loader_spec string|fun(): unknown
function lazy.put(t, key, loader_spec)
  local wrapped = lazy.wrap(
    {},
    create_loader(loader_spec, false, function(loaded)
      rawset(t, key, loaded)
    end)
  )

  rawset(t, key, wrapped)

  return wrapped
end

--- Create a module with lazily resolved members, that aren't resolved before
--- the first time their key is accessed.
---
--- The lazy members can be declared through the `declarations: table<any,
--- string|function>` table, where the values can either be a require path
--- string, or a loader function that should return the loaded value once
--- called.
---
--- If `wrap_values=true` then the values will be loaded using either
--- `lazy.require()` or `lazy.wrap()` based on whether the declaration is
--- either a `string` or `function` respectively. This effectively further
--- defers the actual loading until the lazy members are accessed themselves.
---
--- ## Example
---
--- ```lua
--- -- With `wrap_values=false`:
---
--- local M = lz.module({ ---@diagnostic disable: assign-type-mismatch
---   foo = "some.require.path", ---@module "some.require.path"
---   bar = (function()
---     return require("some.require.path").bar
---   end) --[[@as Bar ]],
--- }) ---@diagnostic enable: assign-type-mismatch
---
--- M.foo
--- -- ^ will load the `foo` module
---
--- -- With `wrap_values=true`:
---
--- local M = lz.module({ --[[ ... ]] }, true)
---
--- M.foo
--- -- ^ still won't load `foo`
--- M.foo.quh
--- --   ^ will load the `foo` module
--- ```
---
--- @generic T : table
--- @param declarations T
--- @param wrap_values? boolean
--- @return T
function lazy.module(declarations, wrap_values)
  local module = {}

  return setmetatable(module, {
    __index = function(_, key)
      local spec = declarations[key]
      if spec == nil then return end
      local ret

      declarations[key] = nil

      if type(spec) == "string" then
        if wrap_values then
          ret = lazy.require(spec, function(loaded)
            module[key] = loaded
            return loaded
          end)
        else
          ret = require(spec)
        end

        module[key] = ret
      elseif type(spec) == "function" then
        if wrap_values then
          ret = lazy.wrap({}, function()
            local loaded = spec()
            module[key] = loaded
            return loaded
          end)
        else
          ret = spec()
        end

        module[key] = ret
      end

      return ret
    end
  })
end

local NilKey = {}

--- @generic F : function
--- @param func F
--- @return F memoized
function lazy.memo(func)
  local state = { arg = {} }

  return function(...)
    local args = pack(...)
    local cur_state = state

    for i = 1, args.n do
      local key = args[i]
      if key == nil then key = NilKey end

      if not cur_state.arg[key] then
        cur_state.arg[key] = { arg = {} }
      end

      cur_state = cur_state.arg[key]
    end

    if not cur_state.values then
      cur_state.values = pack(func(...))
    end

    return unpack(cur_state.values, 1, cur_state.values.n)
  end
end

return lazy
