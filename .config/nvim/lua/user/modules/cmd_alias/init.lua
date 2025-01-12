local pb = require("imminent.pebbles")
local lazy = require("user.lazy")

local arg_parser = lazy.require("diffview.arg_parser") ---@module "diffview.arg_parser"

local Iter = pb.Iter

local store = {}

local M = {}

---@private
---Expand an alias if it's the first arg in the command line.
---@return string
function M.expand(alias)
  local expanded = store[alias]
  local cmd_type = vim.fn.getcmdtype()

  if not expanded or cmd_type ~= ":" then return alias end

  local cmd_line = vim.fn.getcmdline()

  if cmd_line:match("^%s*%S+") then
    local cur_pos = vim.fn.getcmdpos()
    local ctx = arg_parser.scan(cmd_line, { allow_quoted = false, cur_pos = cur_pos })

    if ctx.argidx == 1 then
      return expanded
    end
  end

  return alias
end

---Create a command-line abbreviation that only expands when the alias is the
---first arg in the command line.
---@param alias string|string[]
---@param substitute string
function M.alias(alias, substitute)
  if type(alias) ~= "table" then alias = { alias } end

  for _, name in ipairs(alias) do
    store[name] = substitute

    vim.cmd(
      ("cnoreabbrev <expr> %s v:lua.require('user.modules.cmd_alias').expand('%s')")
      :format(name, pb.pick(1, name:gsub("'", "\\'")))
    )
  end
end

--- @param chars string[]
--- @return string[] variants
local function istr_recurse(chars)
  local c = chars[1]

  if #chars == 1 then
    if c:match("%a") then
      return { c:lower(), c:upper() }
    else
      return { c }
    end
  end

  return Iter
    .new(istr_recurse(pb.slice(chars, 2)))
    :flat_map(function(variant)
      if c:match("%a") then
        return { c:lower() .. variant, c:upper() .. variant }
      else
        return c .. variant
      end
    end)
    :totable()
end

--- Get all case variations of a given string.
---
--- @param s string
--- @return string[] variants
local function istr(s)
  return istr_recurse(pb.split(s, "."))
end

--- Case-insensitive alias.
---
--- @param ialias string|string[]
--- @param substitute string
function M.ialias(ialias, substitute)
  if type(ialias) ~= "table" then ialias = { ialias } end

  local alias_variants = Iter
    .new(ialias)
    :flat_map(function(name) return istr(name) end)
    :unique()
    :totable()

  M.alias(alias_variants, substitute)
end

---Remove an alias.
---@param alias any
function M.unalias(alias)
  store[alias] = nil
  vim.cmd(("silent! cunabbrev %s"):format(alias))
end

--- Case-insensitive unalias.
---
--- @param ialias string
function M.iunalias(ialias)
  for _, variant in ipairs(istr(ialias)) do
    M.unalias(variant)
  end
end

return M
