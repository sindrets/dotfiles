local api = vim.api

local M = {}

--#region TYPES

---@class HiSpec
---@field fg string
---@field bg string
---@field gui string
---@field sp string
---@field blend integer
---@field default boolean

---@class HiLinkSpec
---@field force boolean
---@field default boolean

--#endregion

---@param name string Syntax group name.
---@param attr string Attribute name.
---@param trans? boolean Translate the syntax group (follows links).
function M.get_hl_attr(name, attr, trans)
  local id = api.nvim_get_hl_id_by_name(name)
  if id and trans then
    id = vim.fn.synIDtrans(id)
  end
  if not id then
    return
  end

  local value = vim.fn.synIDattr(id, attr)
  if not value or value == "" then
    return
  end

  return value
end

---@param group_name string Syntax group name.
---@param trans? boolean Translate the syntax group (follows links). True by default.
function M.get_fg(group_name, trans)
  if type(trans) ~= "boolean" then trans = true end
  return M.get_hl_attr(group_name, "fg", trans)
end

---@param group_name string Syntax group name.
---@param trans? boolean Translate the syntax group (follows links). True by default.
function M.get_bg(group_name, trans)
  if type(trans) ~= "boolean" then trans = true end
  return M.get_hl_attr(group_name, "bg", trans)
end

---@param group_name string Syntax group name.
---@param trans? boolean Translate the syntax group (follows links). True by default.
function M.get_gui(group_name, trans)
  if type(trans) ~= "boolean" then trans = true end
  local hls = {}
  local attributes = {
    "bold",
    "italic",
    "reverse",
    "standout",
    "underline",
    "undercurl",
    "strikethrough"
  }

  for _, attr in ipairs(attributes) do
    if M.get_hl_attr(group_name, attr, trans) == "1" then
      table.insert(hls, attr)
    end
  end

  if #hls > 0 then
    return table.concat(hls, ",")
  end
end

---@param group string Syntax group name.
---@param opt HiSpec
function M.hi(group, opt)
  vim.cmd(string.format(
    "hi %s %s %s %s %s %s %s",
    opt.default and "def" or "",
    group,
    opt.fg and ("guifg=" .. opt.fg) or "",
    opt.bg and ("guibg=" .. opt.bg) or "",
    opt.gui and ("gui=" .. opt.gui) or "",
    opt.sp and ("guisp=" .. opt.sp) or "",
    opt.blend and ("blend=" .. opt.blend) or ""
  ))
end

---@param from string Syntax group name.
---@param to? string Syntax group name. (default: `"NONE"`)
---@param opt? HiLinkSpec
function M.hi_link(from, to, opt)
  opt = opt or {}
  vim.cmd(string.format(
    "hi%s %s link %s %s",
    opt.force and "!" or "",
    opt.default and "default" or "",
    from,
    to or "NONE"
  ))
end

return M
