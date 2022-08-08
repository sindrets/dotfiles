local lazy = require("user.lazy")

---@module "diffview.arg_parser"
local arg_parser = lazy.require("diffview.arg_parser")

local utils = Config.common.utils

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

  if cmd_line:match("%s*%S+") then
    local cur_pos = vim.fn.getcmdpos()
    local _, argidx = arg_parser.scan_ex_args(cmd_line, cur_pos)

    if argidx == 1 then
      return expanded
    end
  end

  return alias
end

---Create a command-line abbreviation that only expands when the alias is the
---first arg in the command line.
---@param alias string
---@param substitute string
function M.alias(alias, substitute)
  store[alias] = substitute

  vim.cmd(
    ("cnoreabbrev <expr> %s v:lua.require('user.modules.cmd_alias').expand('%s')")
    :format(alias, utils.pick(1, alias:gsub("'", "\\'")))
  )
end

---Remove an alias.
---@param alias any
function M.unalias(alias)
  store[alias] = nil
  vim.cmd(("silent! cunabbrev %s"):format(alias))
end

return M
