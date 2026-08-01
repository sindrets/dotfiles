--- @using HL

return function()
  local window = hl.get_active_window()
  if not window then return end

  -- Find the focused monitor and check its active special workspace name.
  --- @type Monitor?
  local focused_monitor = nil
  for _, m in ipairs(hl.get_monitors()) do
    if m.focused then
      focused_monitor = m
      break
    end
  end

  local current_special_name = ""
  if focused_monitor and focused_monitor.active_special_workspace then
    current_special_name = focused_monitor.active_special_workspace.name or ""
  end

  --- @param flag boolean
  local function set_floating(flag)
    local win = hl.get_active_window()
    if not win then return end
    if win.floating ~= flag then
      hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    end
  end

  if current_special_name == "special:magic" then
    hl.dispatch(hl.dsp.window.move({ workspace = "e+0" }))
    set_floating(false)
  else
    set_floating(true)
    hl.dispatch(hl.dsp.window.move({ workspace = "special:magic", follow = false }))
  end
end

