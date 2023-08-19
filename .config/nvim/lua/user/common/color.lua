local utils = require("user.common.utils")
local hl = require("user.common.hl")

local M = {}

assert(bit ~= nil, "Color requires the bitlib!")

--#region TYPES

---@class RGBA
---@field red number Float [0,1]
---@field green number Float [0,1]
---@field blue number Float [0,1]
---@field alpha number Float [0,1]

---@class HSV
---@field hue number Float [0,360)
---@field saturation number Float [0,1]
---@field value number Float [0,1]

---@class HSL
---@field hue number Float [0,360)
---@field saturation number Float [0,1]
---@field lightness number Float [0,1]

--#endregion

---@class Color
---@field private _red number
---@field private _green number
---@field private _blue number
---@field private _alpha number
---@field red number
---@field green number
---@field blue number
---@field alpha number
---@field hue number
---@field saturation number
---@field value number
---@field lightness number
local Color = setmetatable({}, {})

function Color:init(r, g, b, a)
  self:set_red(r)
  self:set_green(g)
  self:set_blue(b)
  self:set_alpha(a)
end

---@param c Color
---@return Color
function Color.from_color(c)
  return Color(c.red, c.green, c.blue, c.alpha)
end

---@param h number Hue. Float [0,360)
---@param s number Saturation. Float [0,1]
---@param v number Value. Float [0,1]
---@param a? number Alpha. Float [0,1]
---@return Color
function Color.from_hsv(h, s, v, a)
  h = h % 360
  s = utils.clamp(s, 0, 1)
  v = utils.clamp(v, 0, 1)
  a = utils.clamp(a or 1, 0, 1)

  local k = (5 + h / 60) % 6
  local f5 = v - v * s * math.max(math.min(k, 4 - k, 1), 0)
  k = (3 + h / 60) % 6
  local f3 = v - v * s * math.max(math.min(k, 4 - k, 1), 0)
  k = (1 + h / 60) % 6
  local f1 = v - v * s * math.max(math.min(k, 4 - k, 1), 0)

  return Color(f5, f3, f1, a)
end

---@param h number Hue. Float [0,360)
---@param s number Saturation. Float [0,1]
---@param l number Lightness. Float [0,1]
---@param a? number Alpha. Float [0,1]
---@return Color
function Color.from_hsl(h, s, l, a)
  h = h % 360
  s = utils.clamp(s, 0, 1)
  l = utils.clamp(l, 0, 1)
  a = utils.clamp(a or 1, 0, 1)
  local _a = s * math.min(l, 1 - l)

  local k = (0 + h / 30) % 12
  local f0 = l - _a * math.max(math.min(k - 3, 9 - k, 1), -1)
  k = (8 + h / 30) % 12
  local f8 = l - _a * math.max(math.min(k - 3, 9 - k, 1), -1)
  k = (4 + h / 30) % 12
  local f4 = l - _a * math.max(math.min(k - 3, 9 - k, 1), -1)

  return Color(f0, f8, f4, a)
end

---Create a color from a hex number.
---@param c number|string Either a literal number or a css-style hex string (`#RRGGBB[AA]`).
---@return Color
function Color.from_hex(c)
  local n = c

  if type(c) == "string" then
    local s = c:lower():match("#?([a-f0-9]+)")
    n = tonumber(s, 16)
    if #s <= 6 then
      n = bit.lshift(n, 8) + 0xff
    end
  end

  ---@cast n integer

  return Color(
    bit.rshift(n, 24) / 0xff,
    bit.band(bit.rshift(n, 16), 0xff) / 0xff,
    bit.band(bit.rshift(n, 8), 0xff) / 0xff,
    bit.band(n, 0xff) / 0xff
  )
end

---Create a color from a syntax group attribute.
---@param groups string|string[] Syntax group name or an ordered list of groups
---where the first found value will be used.
---@param attr string Attribute name.
---@return Color?
function Color.from_hl(groups, attr)
  assert(vim.o.termguicolors)

  if type(groups) ~= "table" then groups = { groups } end

  local value

  for _, group in ipairs(groups) do
    value = hl.get_hl_attr(group, attr)
    if value ~= nil then break end
  end

  if value == nil then
    return
  elseif type(value) == "number" then
    value = bit.lshift(value, 8) + 0xff
  end

  return Color.from_hex(value)
end

---@return Color
function Color:clone()
  return Color(self._red, self._green, self._blue, self._alpha)
end

---Returns a new shaded color.
---@param f number Amount. Float [-1,1].
---@return Color
function Color:shade(f)
  local t = f < 0 and 0 or 1.0
  local p = f < 0 and f * -1.0 or f

  return Color(
    (t - self._red) * p + self._red,
    (t - self._green) * p + self._green,
    (t - self._blue) * p + self._blue,
    self._alpha
  )
end

---Returns a new color that's a linear blend between two colors.
---@param other Color
---@param f number Amount. Float [0,1].
---@return Color
function Color:blend(other, f)
  return Color(
    (other._red - self._red) * f + self._red,
    (other._green - self._green) * f + self._green,
    (other._blue - self._blue) * f + self._blue,
    self._alpha
  )
end

function Color.test_shade()
  print("-- SHADE TEST -- ")
  local c = Color.from_hex("#98c379")

  for i = 0, 10 do
    local f = (1 / 5) * i - 1
    print(string.format("%-8.1f%s", f, c:shade(f):to_css()))
  end
end

function Color.test_blend()
  print("-- BLEND TEST -- ")
  local c0 = Color.from_hex("#98c379")
  local c1 = Color.from_hex("#61afef")

  for i = 0, 10 do
    local f = (1 / 10) * i
    print(string.format("%-8.1f%s", f, c0:blend(c1, f):to_css()))
  end
end

---Return the RGBA values in a new table.
---@return RGBA
function Color:to_rgba()
  return { red = self._red, green = self._green, blue = self._blue, alpha = self._alpha }
end

---Convert the color to HSV.
---@return HSV
function Color:to_hsv()
  local r = self._red
  local g = self._green
  local b = self._blue
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local delta = max - min
  local h = 0
  local s = 0
  local v = max

  if max == min then
    h = 0
  elseif max == r then
    h = 60 * ((g - b) / delta)
  elseif max == g then
    h = 60 * ((b - r) / delta + 2)
  elseif max == b then
    h = 60 * ((r - g) / delta + 4)
  end

  if h < 0 then
    h = h + 360
  end
  if max ~= 0 then
    s = (max - min) / max
  end

  return { hue = h, saturation = s, value = v }
end

---Convert the color to HSL.
---@return HSL
function Color:to_hsl()
  local r = self._red
  local g = self._green
  local b = self._blue
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local delta = max - min
  local h = 0
  local s = 0
  local l = (max + min) / 2

  if max == min then
    h = 0
  elseif max == r then
    h = 60 * ((g - b) / delta)
  elseif max == g then
    h = 60 * ((b - r) / delta + 2)
  elseif max == b then
    h = 60 * ((r - g) / delta + 4)
  end

  if h < 0 then
    h = h + 360
  end
  if max ~= 0 and min ~= 1 then
    s = (max - l) / math.min(l, 1 - l)
  end

  return { hue = h, saturation = s, lightness = l }
end

---Convert the color to a hex number representation (`0xRRGGBB[AA]`).
---@param with_alpha? boolean Include the alpha component.
---@return integer
function Color:to_hex(with_alpha)
  local n = bit.bor(
    bit.bor((self._blue * 0xff), bit.lshift((self._green * 0xff), 8)),
    bit.lshift((self._red * 0xff), 16)
  )

  return with_alpha and bit.lshift(n, 8) + (self._alpha * 0xff) or n
end

---Convert the color to a css hex color (`#RRGGBB[AA]`).
---@param with_alpha? boolean Include the alpha component.
---@return string
function Color:to_css(with_alpha)
  local n = self:to_hex(with_alpha)
  local l = with_alpha and 8 or 6

  return string.format("#%0" .. l .. "x", n)
end

---@param v number Float [0,1].
function Color:set_red(v)
  self._red = utils.clamp(v or 1.0, 0, 1)

  return self
end

---@param v number Float [0,1].
function Color:set_green(v)
  self._green = utils.clamp(v or 1.0, 0, 1)

  return self
end

---@param v number Float [0,1].
function Color:set_blue(v)
  self._blue = utils.clamp(v or 1.0, 0, 1)

  return self
end

---@param v number Float [0,1].
function Color:set_alpha(v)
  self._alpha = utils.clamp(v or 1.0, 0, 1)

  return self
end

---@param v number Hue. Float [0,360).
function Color:set_hue(v)
  local hsv = self:to_hsv()
  hsv.hue = v % 360
  self:set_from_hsv(hsv.hue, hsv.saturation, hsv.value, self._alpha)

  return self
end

---@param v number Float [0,1].
function Color:set_saturation(v)
  local hsv = self:to_hsv()
  hsv.saturation = utils.clamp(v, 0, 1)
  self:set_from_hsv(hsv.hue, hsv.saturation, hsv.value, self._alpha)

  return self
end

---@param v number Float [0,1].
function Color:set_value(v)
  local hsv = self:to_hsv()
  hsv.value = utils.clamp(v, 0, 1)
  self:set_from_hsv(hsv.hue, hsv.saturation, hsv.value, self._alpha)

  return self
end

---@param v number Float [0,1].
function Color:set_lightness(v)
  local hsl = self:to_hsl()
  hsl.lightness = utils.clamp(v, 0, 1)
  self:set_from_hsl(hsl.hue, hsl.saturation, hsl.lightness, self._alpha)

  return self
end

---Copy the values from another color.
---@param c Color
function Color:set_from_color(c)
  self._red = c.red
  self._green = c.green
  self._blue = c.blue
  self._alpha = c.alpha

  return self
end

---@param x RGBA|number[]|number Either an RGBA struct, or a vector, or the value for red.
---@param g? number Green. Float [0,1].
---@param b? number Blue. Float [0,1].
---@param a? number Alpha. Float [0,1].
---@overload fun(self: Color, rgba: RGBA)
---@overload fun(self: Color, rgba: number[])
---@overload fun(self: Color, r: number, g: number, b: number, a: number)
function Color:set_from_rgba(x, g, b, a)
  if type(x) == "number" then
    self.red = x
    self.green = g
    self.blue = b
    self.alpha = a or self._alpha
  elseif #x >= 3 then
    self.red = x[1]
    self.green = x[2]
    self.blue = x[3]
    self.alpha = x[4] or self._alpha
  else
    if x.red then self.red = x.red end
    if x.green then self.green = x.green end
    if x.blue then self.blue = x.blue end
    if x.alpha then self.alpha = x.alpha end
  end

  return self
end

---@param x HSV|number[]|number Either an HSV struct, or a vector, or the value for hue.
---@param s? number Saturation. Float [0,1].
---@param v? number Value. Float [0,1].
---@param a? number Alpha. Float [0,1].
---@overload fun(self: Color, hsv: HSV)
---@overload fun(self: Color, hsv: number[])
---@overload fun(self: Color, h: number, s: number, v: number)
function Color:set_from_hsv(x, s, v, a)
  local c

  if type(x) == "number" then
    ---@cast s number
    ---@cast v number
    c = Color.from_hsv(x, s, v, a or self._alpha)
  elseif #x >= 3 then
    c = Color.from_hsv(x[1], x[2], x[3], x[4] or self._alpha)
  else
    local hsv = self:to_hsv()
    c = Color.from_hsv(
      x.hue or hsv.hue,
      x.saturation or hsv.saturation,
      x.value or hsv.value,
      self._alpha
    )
  end

  return self:set_from_color(c)
end

---@param x HSL|number[]|number Either an HSL struct, or a vector, or the value for hue.
---@param s? number Saturation. Float [0,1].
---@param l? number Lightness. Float [0,1].
---@param a? number Alpha. Float [0,1].
---@overload fun(hsl: HSL)
---@overload fun(hsl: number[])
---@overload fun(h: number, s: number, l: number)
function Color:set_from_hsl(x, s, l, a)
  local c

  if type(x) == "number" then
    ---@cast s number
    ---@cast l number
    c = Color.from_hsl(x, s, l, a or self._alpha)
  elseif #x >= 3 then
    c = Color.from_hsl(x[1], x[2], x[3], x[4] or self._alpha)
  else
    local hsl = self:to_hsl()
    c = Color.from_hsl(
      x.hue or hsl.hue,
      x.saturation or hsl.saturation,
      x.lightness or hsl.lightness,
      self._alpha
    )
  end

  return self:set_from_color(c)
end

---@param v number Float [-1,1].
function Color:mod_red(v)
  return Color(
    utils.clamp(self._red + v, 0, 1),
    self._green,
    self._blue,
    self._alpha
  )
end

---@param v number Float [-1,1].
function Color:mod_green(v)
  return Color(
    self._red,
    utils.clamp(self._green + v, 0, 1),
    self._blue,
    self._alpha
  )
end

---@param v number Float [-1,1].
function Color:mod_blue(v)
  return Color(
    self._red,
    self._green,
    utils.clamp(self._blue + v, 0, 1),
    self._alpha
  )
end

---@param v number Float [-1,1].
function Color:mod_alpha(v)
  return Color(
    self._red,
    self._green,
    self._blue,
    utils.clamp(self._alpha + v, 0, 1)
  )
end

---@param v number Hue. Float (-360,360).
function Color:mod_hue(v)
  local hsv = self:to_hsv()
  hsv.hue = (hsv.hue + v) % 360

  return Color.from_hsv(hsv.hue, hsv.saturation, hsv.value)
end

---@param v number Float [-1,1].
function Color:mod_saturation(v)
  local hsv = self:to_hsv()
  hsv.saturation = utils.clamp(hsv.saturation + v, 0, 1)

  return Color.from_hsv(hsv.hue, hsv.saturation, hsv.value)
end

---@param v number Float [-1,1].
function Color:mod_value(v)
  local hsv = self:to_hsv()
  hsv.value = utils.clamp(hsv.value + v, 0, 1)

  return Color.from_hsv(hsv.hue, hsv.saturation, hsv.value)
end

---@param v number Float [-1,1].
function Color:mod_lightness(v)
  local hsl = self:to_hsl()
  hsl.lightness = utils.clamp(hsl.lightness + v, 0, 1)

  return Color.from_hsl(hsl.hue, hsl.saturation, hsl.lightness)
end

---@param c Color
function Color:mod_color(c)
  return Color(
    self._red + c._red,
    self._green + c._green,
    self._blue + c._blue,
    self._alpha + c._alpha
  )
end

---@param rgba RGBA
function Color:mod_rgba(rgba)
  return Color(
    utils.clamp(self._red + (rgba.red or 0), 0, 1),
    utils.clamp(self._green + (rgba.green or 0), 0, 1),
    utils.clamp(self._blue + (rgba.blue or 0), 0, 1),
    utils.clamp(self._alpha + (rgba.alpha or 0), 0, 1)
  )
end

---@param hsv HSV
function Color:mod_hsv(hsv)
  local cur = self:to_hsv()

  return Color.from_hsv(
    cur.hue + (hsv.hue or 0) % 360,
    utils.clamp(cur.saturation + (hsv.saturation or 0), 0, 1),
    utils.clamp(cur.value + (hsv.value or 0), 0, 1),
    self._alpha
  )
end

---@param hsl HSL
function Color:mod_hsl(hsl)
  local cur = self:to_hsl()

  return Color.from_hsl(
    cur.hue + (hsl.hue or 0) % 360,
    utils.clamp(cur.saturation + (hsl.saturation or 0), 0, 1),
    utils.clamp(cur.lightness + (hsl.lightness or 0), 0, 1),
    self._alpha
  )
end

---@param v number Float [-1,1].
function Color:highlight(v)
  local sign = self.lightness >= 0.5 and -1 or 1
  local hsv = self:to_hsv()
  hsv.value = utils.clamp(hsv.value + v * sign, 0, 1)

  return Color.from_hsv(hsv.hue, hsv.saturation, hsv.value)
end

do
  -- stylua: ignore start
  local getters = {
    red = function(self) return self._red end,
    green = function(self) return self._green end,
    blue = function(self) return self._blue end,
    alpha = function(self) return self._alpha end,
    hue = function (self) return self:to_hsv().hue end,
    saturation = function (self) return self:to_hsv().saturation end,
    value = function (self) return self:to_hsv().value end,
    lightness = function (self) return self:to_hsl().lightness end,
  }
  local setters = {
    red = function(self, v) self:set_red(v) end,
    green = function(self, v) self:set_green(v) end,
    blue = function(self, v) self:set_blue(v) end,
    alpha = function(self, v) self:set_alpha(v) end,
    hue = function(self, v) self:set_hue(v) end,
    saturation = function(self, v) self:set_saturation(v) end,
    value = function(self, v) self:set_value(v) end,
    lightness = function(self, v) self:set_lightness(v) end,
  }
  -- stylua: ignore end

  function Color.__index(self, k)
    if getters[k] then
      return getters[k](self)
    end
    return Color[k]
  end

  function Color.__newindex(self, k, v)
    if setters[k] then
      setters[k](self, v)
    else
      rawset(self, k, v)
    end
  end

  local mt = getmetatable(Color)
  ---@return Color
  function mt.__call(_, ...)
    local this = setmetatable({}, Color)
    this:init(...)
    return this
  end
end

M.Color = Color
return M
