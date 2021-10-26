local oop = require("diffview.oop")
local utils = require("nvim-config.utils")
local M = {}

--#region TYPES

---@class RGBA
---@field red number
---@field green number
---@field blue number
---@field alpha number

---@class HSV
---@field hue number
---@field saturation number
---@field value number

---@class HSL
---@field hue number
---@field saturation number
---@field lightness number

--#endregion

---@class Color
---@field red number
---@field green number
---@field blue number
---@field alpha number
---@field hue number
---@field saturation number
---@field value number
---@field lightness number
local Color = oop.Object
Color = oop.create_class("Color")

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

---@param h number Hue. Float [0,1]
---@param s number Saturation. Float [0,1]
---@param v number Value. Float [0,1]
---@param a number (Optional) Alpha. Float [0,1]
---@return Color
function Color.from_hsv(h, s, v, a)
  h = h % 360
  s = utils.clamp(s, 0, 1)
  v = utils.clamp(v, 0, 1)
  a = utils.clamp(a or 1, 0, 1)

  local function f(n)
    local k = (n + h / 60) % 6
    return v - v * s * math.max(math.min(k, 4 - k, 1), 0)
  end

  return Color(f(5), f(3), f(1), a)
end

---@param h number Hue. Float [0,1]
---@param s number Saturation. Float [0,1]
---@param l number Lightness. Float [0,1]
---@param a number (Optional) Alpha. Float [0,1]
---@return Color
function Color.from_hsl(h, s, l, a)
  h = h % 360
  s = utils.clamp(s, 0, 1)
  l = utils.clamp(l, 0, 1)
  a = utils.clamp(a or 1, 0, 1)
  local _a = s * math.min(l, 1 - l)

  local function f(n)
    local k = (n + h / 30) % 12
    return l - _a * math.max(math.min(k - 3, 9 - k, 1), -1)
  end

  return Color(f(0), f(8), f(4), a)
end

---Create a color from a hex number.
---@param c number|string Either a literal number or a css-style hex string (`#RRGGBB[AA]`).
---@return Color
function Color.from_hex(c)
  local n = c
  if type(c) == "string" then
    n = tonumber(c:match("#?(.*)"), 16)
  end

  if n <= 0xffffff then
    n = bit.lshift(n, 8) + 0xff
  end

  return Color(
    bit.rshift(n, 24) / 255,
    bit.band(bit.rshift(n, 16), 0xff) / 255,
    bit.band(bit.rshift(n, 8), 0xff) / 255,
    bit.band(n, 0xff) / 255
  )
end

---@return Color
function Color:clone()
  return Color(self.red, self.green, self.blue, self.alpha)
end

---Returns a new shaded color.
---@param f number Amount. Float [-1,1].
---@return Color
function Color:shade(f)
  local t = f < 0 and 0 or 1.0
  local p = f < 0 and f * -1.0 or f

  return Color(
    (t - self.red) * p + self.red,
    (t - self.green) * p + self.green,
    (t - self.blue) * p + self.blue,
    self.alpha
  )
end

---Returns a new color that's a linear blend between two colors.
---@param other Color
---@param f number Amount. Float [0,1].
function Color:blend(other, f)
  return Color(
    (other.red - self.red) * f + self.red,
    (other.green - self.green) * f + self.green,
    (other.blue - self.blue) * f + self.blue,
    self.alpha
  )
end

function Color.test_shade()
  print("-- SHADE TEST -- ")
  local c = Color.from_hex("#98c379")

  for i = 5, 1, -1 do
    local f = (1 / 5) * -i
    utils._echo_multiline(f .. "\t\t" .. c:shade(f):to_css())
  end

  utils._echo_multiline("0.0\t\t" .. c:to_css())

  for i = 1, 5 do
    local f = (1 / 5) * i
    utils._echo_multiline(f .. "\t\t" .. c:shade(f):to_css())
  end
end

function Color.test_blend()
  print("-- BLEND TEST -- ")
  local c0 = Color.from_hex("#98c379")
  local c1 = Color.from_hex("#61afef")

  for i = 0, 10 do
    local f = (1 / 10) * i
    utils._echo_multiline(f .. "\t\t" .. c0:blend(c1, f):to_css())
  end
end

---Return the RGBA values in a new table.
---@return RGBA
function Color:to_rgba()
  return { red = self.red, green = self.green, blue = self.blue, alpha = self.alpha }
end

---Convert the color to HSV.
---@return HSV
function Color:to_hsv()
  local r = self.red
  local g = self.green
  local b = self.blue
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
  local r = self.red
  local g = self.green
  local b = self.blue
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
---@param with_alpha boolean Include the alpha component.
---@return integer
function Color:to_hex(with_alpha)
  local n = bit.bor(
    bit.bor((self.blue * 255), bit.lshift((self.green * 255), 8)),
    bit.lshift((self.red * 255), 16)
  )
  return with_alpha and bit.lshift(n, 8) + (self.alpha * 255) or n
end

---Convert the color to a css hex color (`#RRGGBB[AA]`).
---@param with_alpha boolean Include the alpha component.
---@return string
function Color:to_css(with_alpha)
  local n = self:to_hex(with_alpha)
  local l = with_alpha and 8 or 6
  return string.format("#%0" .. l .. "x", n)
end

---@param v number Float [0,1].
function Color:set_red(v)
  self._red = utils.clamp(v or 1.0, 0, 1)
end

---@param v number Float [0,1].
function Color:set_green(v)
  self._green = utils.clamp(v or 1.0, 0, 1)
end

---@param v number Float [0,1].
function Color:set_blue(v)
  self._blue = utils.clamp(v or 1.0, 0, 1)
end

---@param v number Float [0,1].
function Color:set_alpha(v)
  self._alpha = utils.clamp(v or 1.0, 0, 1)
end

---@param v number Float [0,1].
function Color:set_hue(v)
  local hsv = self:to_hsv()
  hsv.hue = v % 360
  local c = Color.from_hsv(hsv.hue, hsv.saturation, hsv.value)
  self._red = c.red
  self._green = c.green
  self._blue = c.blue
end

---@param v number Float [0,1].
function Color:set_saturation(v)
  local hsv = self:to_hsv()
  hsv.saturation = utils.clamp(v, 0, 1)
  local c = Color.from_hsv(hsv.hue, hsv.saturation, hsv.value)
  self._red = c.red
  self._green = c.green
  self._blue = c.blue
end

---@param v number Float [0,1].
function Color:set_value(v)
  local hsv = self:to_hsv()
  hsv.value = utils.clamp(v, 0, 1)
  local c = Color.from_hsv(hsv.hue, hsv.saturation, hsv.value)
  self._red = c.red
  self._green = c.green
  self._blue = c.blue
end

---@param v number Float [0,1].
function Color:set_lightness(v)
  local hsl = self:to_hsl()
  hsl.lightness = utils.clamp(v, 0, 1)
  local c = Color.from_hsl(hsl.hue, hsl.saturation, hsl.lightness)
  self._red = c.red
  self._green = c.green
  self._blue = c.blue
end

---Copy the values from another color.
---@param c Color
function Color:set_from_color(c)
  self._red = c.red
  self._green = c.green
  self._blue = c.blue
  self._alpha = c.alpha
end

---@param x RGBA|number[]|number Either an RGBA struct, or a vector, or the value for red.
---@param g number Green. Float [0,1].
---@param b number Blue. Float [0,1].
---@param a number (Optional) Alpha. Float [0,1].
function Color:set_from_rgba(x, g, b, a)
  if type(x) == "number" then
    self:set_red(x)
    self:set_green(g)
    self:set_blue(b)
    self:set_alpha(a or self.alpha)
  elseif type(x.red) == "number" then
    self:set_red(x.red)
    self:set_green(x.green)
    self:set_blue(x.blue)
    self:set_alpha(x.alpha)
  else
    self:set_red(x[1])
    self:set_green(x[2])
    self:set_blue(x[3])
    self:set_alpha(x[4] or self.alpha)
  end
end

---@param x HSV|number[]|number Either an HSV struct, or a vector, or the value for hue.
---@param s number Saturation. Float [0,1].
---@param v number Value Float [0,1].
function Color:set_from_hsv(x, s, v)
  local c
  if type(x) == "number" then
    c = Color.from_hsv(x, s, v, self.alpha)
  elseif type(x.hue) == "number" then
    c = Color.from_hsv(x.hue, x.saturation, x.value, self.alpha)
  else
    c = Color.from_hsv(x[1], x[2], x[3], self.alpha)
  end
  self:set_from_color(c)
end

---@param x HSL|number[]|number Either an HSL struct, or a vector, or the value for hue.
---@param s number Saturation. Float [0,1].
---@param l number Lightness. Float [0,1].
function Color:set_from_hsl(x, s, l)
  local c
  if type(x) == "number" then
    c = Color.from_hsl(x, s, l, self.alpha)
  elseif type(x.hue) == "number" then
    c = Color.from_hsl(x.hue, x.saturation, x.lightness, self.alpha)
  else
    c = Color.from_hsl(x[1], x[2], x[3], self.alpha)
  end
  self:set_from_color(c)
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

  local __index = Color.__index
  function Color.__index(self, k)
    if getters[k] then
      return getters[k](self)
    else
      return __index(self, k)
    end
  end

  local __newindex = Color.__newindex
  function Color.__newindex(self, k, v)
    if setters[k] then
      setters[k](self, v)
    else
      __newindex(self, k, v)
    end
  end
end

M.Color = Color
return M
