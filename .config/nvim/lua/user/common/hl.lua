local api = vim.api

local M = {}

---@alias hl.HiValue<T> T|"NONE"

---@class hl.HiSpec
---@field fg         hl.HiValue<string>
---@field bg         hl.HiValue<string>
---@field sp         hl.HiValue<string>
---@field style      hl.HiValue<string>
---@field ctermfg    hl.HiValue<integer>
---@field ctermbg    hl.HiValue<integer>
---@field cterm      hl.HiValue<string>
---@field blend      hl.HiValue<integer>
---@field default    hl.HiValue<boolean> Only set values if the hl group is cleared.
---@field unlink     boolean Remove links.
---@field explicit   boolean All undefined fields will be cleared from the hl group.

---@class hl.HiLinkSpec
---@field force boolean
---@field default boolean
---@field clear boolean

---@class hl.HlData
---@field link string|integer
---@field foreground integer Foreground color integer
---@field background integer Background color integer
---@field special integer Special color integer
---@field fg string Foreground color hex string
---@field bg string Bakground color hex string
---@field sp string Special color hex string
---@field bold boolean
---@field italic boolean
---@field underline boolean
---@field underlineline boolean
---@field undercurl boolean
---@field underdash boolean
---@field underdot boolean
---@field strikethrough boolean
---@field standout boolean
---@field reverse boolean
---@field blend integer

---@alias hl.HlAttrValue integer|boolean

---@enum HlAttribute
M.HlAttribute = {
  foreground = 1,
  background = 2,
  special = 3,
  fg = 4,
  bg = 5,
  sp = 6,
  bold = 7,
  italic = 8,
  underline = 9,
  underlineline = 10,
  undercurl = 11,
  underdash = 12,
  underdot = 13,
  strikethrough = 14,
  standout = 15,
  reverse = 16,
  blend = 17,
}

local style_attrs = {
  "bold",
  "italic",
  "underline",
  "underlineline",
  "undercurl",
  "underdash",
  "underdot",
  "strikethrough",
  "standout",
  "reverse",
}

-- NOTE: Some atrtibutes have been renamed in v0.8.0
if vim.fn.has("nvim-0.8") == 1 then
  M.HlAttribute.underdashed = M.HlAttribute.underdash
  M.HlAttribute.underdash = nil

  M.HlAttribute.underdotted = M.HlAttribute.underdot
  M.HlAttribute.underdot = nil

  M.HlAttribute.underdouble = M.HlAttribute.underlineline
  M.HlAttribute.underlineline = nil

  style_attrs = {
    "bold",
    "italic",
    "underline",
    "underdouble",
    "undercurl",
    "underdashed",
    "underdotted",
    "strikethrough",
    "standout",
    "reverse",
  }
end

vim.tbl_add_reverse_lookup(M.HlAttribute)
vim.tbl_add_reverse_lookup(style_attrs)
local hlattr = M.HlAttribute

---@param name string Syntax group name.
---@param no_trans? boolean Don't translate the syntax group (follow links).
---@return hl.HlData?
function M.get_hl(name, no_trans)
  local hl

  if no_trans then
    hl = api.nvim__get_hl_defs(0)[name]
  else
    local id = api.nvim_get_hl_id_by_name(name)

    if id then
      hl = api.nvim_get_hl_by_id(id, true)
    end
  end

  if hl then
    if hl.foreground then hl.fg = string.format("#%06x", hl.foreground) end
    if hl.background then hl.bg = string.format("#%06x", hl.background) end
    if hl.special then hl.sp = string.format("#%06x", hl.special) end

    return hl
  end
end

---@param name string Syntax group name.
---@param attr HlAttribute|string Attribute kind.
---@param no_trans? boolean Don't translate the syntax group (follow links).
---@return hl.HlAttrValue?
function M.get_hl_attr(name, attr, no_trans)
  local hl = M.get_hl(name, no_trans)

  if type(attr) == "string" then attr = hlattr[attr] end

  if not (hl and attr) then return end

  return hl[hlattr[attr]]
end

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param no_trans? boolean Don't translate the syntax group (follow links).
---@return string?
function M.get_fg(groups, no_trans)
  no_trans = not not no_trans

  if type(groups) ~= "table" then groups = { groups } end

  for _, group in ipairs(groups) do
    local v = M.get_hl_attr(group, hlattr.fg, no_trans) --[[@as string? ]]

    if v then return v end
  end
end

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param no_trans? boolean Don't translate the syntax group (follow links).
---@return string?
function M.get_bg(groups, no_trans)
  no_trans = not not no_trans

  if type(groups) ~= "table" then groups = { groups } end

  for _, group in ipairs(groups) do
    local v = M.get_hl_attr(group, hlattr.bg, no_trans) --[[@as string? ]]

    if v then return v end
  end
end

---@param groups string|string[] Syntax group name, or an ordered list of
---groups where the first found value will be returned.
---@param no_trans? boolean Don't translate the syntax group (follow links).
---@return string?
function M.get_style(groups, no_trans)
  no_trans = not not no_trans
  if type(groups) ~= "table" then groups = { groups } end

  for _, group in ipairs(groups) do
    local hl = M.get_hl(group, no_trans)

    if hl then
      local res = {}

      for _, attr in ipairs(style_attrs) do
        if hl[attr] then table.insert(res, attr)
        end

        if #res > 0 then
          return table.concat(res, ",")
        end
      end
    end
  end
end

---@param spec hl.HiSpec
---@return hl.HlData
function M.hi_spec_to_data(spec)
  ---@type hl.HlData
  local res = {}
  local fields = { "fg", "bg", "sp", "ctermfg", "ctermbg", "cterm", "default" }

  for _, field in ipairs(fields) do
    res[field] = spec[field]
  end

  if spec.style then
    local spec_attrs = vim.tbl_add_reverse_lookup(vim.split(spec.style, ","))

    for _, attr in ipairs(style_attrs) do
      res[attr] = spec_attrs[attr] ~= nil
    end
  end

  return res
end

---@param groups string|string[] Syntax group name or a list of group names.
---@param opt hl.HiSpec
function M.hi(groups, opt)
  if type(groups) ~= "table" then groups = { groups } end

  for _, group in ipairs(groups) do
    local def_spec = M.hi_spec_to_data(opt)

    if not opt.explicit then
      def_spec = vim.tbl_extend("force", M.get_hl(group, true) or {}, def_spec) --[[@as hl.HlData ]]
      def_spec[true] = nil
      def_spec[false] = nil
      def_spec.link = nil
      def_spec.foreground = nil
      def_spec.background = nil
      def_spec.special = nil
    end

    if opt.unlink then
      def_spec.link = -1
    end

    for k, v in pairs(def_spec) do
      if v == "NONE" then
        def_spec[k] = nil
      end
    end

    api.nvim_set_hl(0, group, def_spec)
  end
end

---@param from string|string[] Syntax group name or a list of group names.
---@param to? string Syntax group name. (default: `"NONE"`)
---@param opt? hl.HiLinkSpec
function M.hi_link(from, to, opt)
  if to and tostring(to):upper() == "NONE" then
    ---@diagnostic disable-next-line: cast-local-type
    to = -1
  end

  opt = vim.tbl_extend("keep", opt or {}, {
    force = true,
  }) --[[@as hl.HiLinkSpec ]]

  if type(from) ~= "table" then from = { from } end

  for _, f in ipairs(from) do
    if opt.clear then
      api.nvim_set_hl(0, f, {})
    end

    api.nvim_set_hl(0, f, {
      default = opt.default,
      link = to,
    })
  end
end

---Clear highlighting for a given syntax group, or all groups if no group is
---given.
---@param groups? string|string[]
function M.hi_clear(groups)
  if not groups then
    vim.cmd("hi clear")
    return
  end

  if type(groups) ~= "table" then
    groups = { groups }
  end

  for _, g in ipairs(groups) do
    api.nvim_set_hl(0, g, {})
  end
end

return M
