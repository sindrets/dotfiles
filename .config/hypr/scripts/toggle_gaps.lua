local pb = require("imminent.pebbles")

--- Toggles Hyprland gaps between zero and the given defaults.
---
--- @param gaps_in int|nil gaps_in value to restore (default 5)
--- @param gaps_out int|nil gaps_out value to restore (default 20)
return function(gaps_in, gaps_out)
  gaps_in = gaps_in or 5
  gaps_out = gaps_out or 20

  ---@type int
  local current_gaps_in = pb.get(hl.get_config("general.gaps_in"), { "top" }, 0)

  if current_gaps_in == 0 then
    hl.config({
      general = {
        gaps_in = gaps_in,
        gaps_out = gaps_out,
      },
    })
  else
    hl.config({
      general = {
        gaps_in = 0,
        gaps_out = 0,
      },
    })
  end
end
