local api = vim.api

local M = {}

--#region TYPES

---@class HiSpec
---@field fg string
---@field bg string
---@field ctermfg integer
---@field ctermbg integer
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

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param trans boolean Translate the syntax group (follows links). True by default.
function M.get_fg(groups, trans)
  if type(trans) ~= "boolean" then trans = true end

  if type(groups) == "table" then
    local v
    for _, group in ipairs(groups) do
      v = M.get_hl_attr(group, "fg", trans)
      if v then return v end
    end
    return
  end

  return M.get_hl_attr(groups, "fg", trans)
end

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param trans boolean Translate the syntax group (follows links). True by default.
function M.get_bg(groups, trans)
  if type(trans) ~= "boolean" then trans = true end

  if type(groups) == "table" then
    local v
    for _, group in ipairs(groups) do
      v = M.get_hl_attr(group, "bg", trans)
      if v then return v end
    end
    return
  end

  return M.get_hl_attr(groups, "bg", trans)
end

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param trans boolean Translate the syntax group (follows links). True by default.
function M.get_gui(groups, trans)
  if type(trans) ~= "boolean" then trans = true end
  if type(groups) ~= "table" then groups = { groups } end

  local hls
  for _, group in ipairs(groups) do
    hls = {}
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
      if M.get_hl_attr(group, attr, trans) == "1" then
        table.insert(hls, attr)
      end
    end

    if #hls > 0 then
      return table.concat(hls, ",")
    end
  end
end

---@param group string Syntax group name.
---@param opt HiSpec
function M.hi(group, opt)
  local use_tc = vim.o.termguicolors
  local g = use_tc and "gui" or "cterm"

  if not use_tc then
    opt = Config.common.utils.tbl_clone(opt)
    opt.fg = opt.ctermfg or opt.fg
    opt.bg = opt.ctermbg or opt.bg
  end

  vim.cmd(string.format(
    "hi %s %s %s %s %s %s %s",
    opt.default and "def" or "",
    group,
    opt.fg and (g .. "fg=" .. opt.fg) or "",
    opt.bg and (g .. "bg=" .. opt.bg) or "",
    opt.gui and (g .. "=" .. opt.gui) or "",
    opt.sp and ("guisp=" .. opt.sp) or "",
    opt.blend and ("blend=" .. opt.blend) or ""
  ))
end

---@param from string Syntax group name.
---@param to? string Syntax group name. (default: `"NONE"`)
---@param opt? HiLinkSpec
function M.hi_link(from, to, opt)
  opt = vim.tbl_extend("keep", opt or {}, {
    force = true,
  })
  vim.cmd(string.format(
    "hi%s %s link %s %s",
    opt.force and "!" or "",
    opt.default and "default" or "",
    from,
    to or "NONE"
  ))
end

---Clear highlighting for a given syntax group, or all groups if no group is
---given.
---@param group? string
function M.hi_clear(group)
  vim.cmd(string.format("hi clear %s", group or ""))
end

return M
