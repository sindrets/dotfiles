--- Cycles focus to the next window, preferring tiled or floating depending on
--- the current window.
---
--- If the active window is floating, cycles to the next tiled window.
--- Otherwise, cycles to the next floating window.
return function()
  local win = hl.get_active_window()
  if not win then return end

  if win.floating then
    hl.dispatch(hl.dsp.window.cycle_next({ tiled = true }))
  else
    hl.dispatch(hl.dsp.window.cycle_next({ floating = true }))
  end
end
