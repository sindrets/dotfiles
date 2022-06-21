local api = vim.api

local M = {}

--#region TYPES

---@class HiSpec
---@field fg string
---@field bg string
---@field gui string
---@field ctermfg integer
---@field ctermbg integer
---@field cterm string
---@field sp string
---@field blend integer
---@field default boolean
---@field unlink boolean

---@class HiLinkSpec
---@field force boolean
---@field default boolean

--#endregion

---@param name string Syntax group name.
---@param attr string Attribute name.
---@param no_trans? boolean Don't translate the syntax group (follow links).
function M.get_hl_attr(name, attr, no_trans)
  local id = api.nvim_get_hl_id_by_name(name)
  if id and not no_trans then
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
---@param no_trans? boolean Don't translate the syntax group (follow links).
function M.get_fg(groups, no_trans)
  no_trans = not not no_trans

  if type(groups) == "table" then
    local v
    for _, group in ipairs(groups) do
      v = M.get_hl_attr(group, "fg", no_trans)
      if v then return v end
    end
    return
  end

  return M.get_hl_attr(groups, "fg", no_trans)
end

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param no_trans? boolean Don't translate the syntax group (follow links).
function M.get_bg(groups, no_trans)
  no_trans = not not no_trans

  if type(groups) == "table" then
    local v
    for _, group in ipairs(groups) do
      v = M.get_hl_attr(group, "bg", no_trans)
      if v then return v end
    end
    return
  end

  return M.get_hl_attr(groups, "bg", no_trans)
end

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param no_trans? boolean Don't translate the syntax group (follow links).
function M.get_gui(groups, no_trans)
  no_trans = not not no_trans
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
      if M.get_hl_attr(group, attr, no_trans) == "1" then
        table.insert(hls, attr)
      end
    end

    if #hls > 0 then
      return table.concat(hls, ",")
    end
  end
end

---@param groups string|string[] Syntax group name or a list of group names.
---@param opt HiSpec
function M.hi(groups, opt)
  if type(groups) ~= "table" then
    groups = { groups }
  end

  for _, group in ipairs(groups) do
    if opt.unlink then
      vim.cmd(("hi! link %s NONE"):format(group))
    end

    vim.cmd(string.format(
      "hi %s %s %s %s %s %s %s",
      opt.default and "default" or "",
      group,
      opt.fg and ("guifg=" .. opt.fg) or "",
      opt.bg and ("guibg=" .. opt.bg) or "",
      opt.gui and ("gui=" .. opt.gui) or "",
      opt.ctermfg and ("ctermfg=" .. opt.ctermfg) or "",
      opt.ctermbg and ("ctermbg=" .. opt.ctermbg) or "",
      opt.cterm and ("cterm=" .. opt.cterm) or "",
      opt.sp and ("guisp=" .. opt.sp) or "",
      opt.blend and ("blend=" .. opt.blend) or ""
    ))
  end
end

---@param from string|string[] Syntax group name or a list of group names.
---@param to? string Syntax group name. (default: `"NONE"`)
---@param opt? HiLinkSpec
function M.hi_link(from, to, opt)
  opt = vim.tbl_extend("keep", opt or {}, {
    force = true,
  })
  ---@cast opt HiLinkSpec

  if type(from) ~= "table" then
    from = { from }
  end

  for _, f in ipairs(from) do
    vim.cmd(string.format(
      "hi%s %s link %s %s",
      (opt.force and not opt.default) and "!" or "",
      opt.default and "default" or "",
      f,
      to or "NONE"
    ))
  end
end

---Clear highlighting for a given syntax group, or all groups if no group is
---given.
---@param groups? string
---@param unlink? boolean Additionally unlink the groups.
function M.hi_clear(groups, unlink)
  if type(groups) ~= "table" then
    groups = { groups or "" }
  end
  for _, g in ipairs(groups) do
    vim.cmd(string.format("hi clear %s", g))
    if unlink then
      vim.cmd(string.format("hi link %s NONE", g))
    end
  end
end

return M
