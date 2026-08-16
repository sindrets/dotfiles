local utils = {}

--- @param str string
--- @return string[]
function utils.utf8_chars(str)
  local positions = vim.str_utf_pos(str)
  local chars = {}

  for i, start_byte in ipairs(positions) do
    -- The character ends right before the next character starts
    local end_byte = (positions[i + 1] or (#str + 1)) - 1
    local char = str:sub(start_byte, end_byte)
    chars[#chars+1] = char
  end

  return chars
end

--- @param str string
--- @return string
function utils.invert_braille_str(str)
  local sb = {} --- @type string[]

  for _, char in ipairs(utils.utf8_chars(str)) do
    local cp = vim.fn.char2nr(char)
    if cp >= 0x2800 and cp <= 0x28FF then
      -- Invert braille dots: XOR dot pattern with 0xFF
      local offset = cp - 0x2800
      local inv = bit.bxor(offset, 0xFF)
      sb[#sb + 1] = vim.fn.nr2char(inv + 0x2800)
    elseif cp == 0x20 then
      -- ASCII space → full braille (all dots on)
      sb[#sb + 1] = vim.fn.nr2char(0x28FF)
    else
      sb[#sb + 1] = char
    end
  end

  return table.concat(sb)
end

return utils
