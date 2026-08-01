--- Moves the active window by a relative offset if floating, or in the given
--- direction if tiled.
---
--- @param resize_amount int pixel amount to move
--- @param direction 'l'|'r'|'u'|'d' move direction
return function(resize_amount, direction)
  local win = hl.get_active_window()
  if not win then return end

  if win.floating then
    ---@type int, int
    local dx, dy = 0, 0
    if direction == "l" then
      dx = -resize_amount
    elseif direction == "r" then
      dx = resize_amount
    elseif direction == "u" then
      dy = -resize_amount
    elseif direction == "d" then
      dy = resize_amount
    end

    hl.dispatch(hl.dsp.window.move({ x = dx, y = dy, relative = true }))
  else
    hl.dispatch(hl.dsp.window.move({ direction = direction }))
  end
end
