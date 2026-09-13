--- @namespace hypr.user

local PluginManager = require("lib.PluginManager")

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "",
    title = "",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

hl.window_rule({
  name = "kitty-float",
  match = { class = "kitty_FLOAT" },
  float = true,
})

hl.window_rule({
  name = "1password-float-1",
  match = { class = "1Password" },
  float = true,
})

hl.window_rule({
  name = "1password-float-2",
  match = { class = "1password" },
  float = true,
})

hl.window_rule({
  name = "pavucontrol-float",
  match = { class = "pavucontrol-qt" },
  float = true,
})

hl.window_rule({
  name = "thunar-progress-float",
  match = { class = "thunar", title = "File Operation Progress" },
  float = true,
})

hl.window_rule({
  name = "thunar-confirm-float",
  match = { class = "thunar", title = "Confirm to replace files" },
  float = true,
})

hl.window_rule({
  name = "pip-float",
  match = { class = "(Firefox Beta|zen)", title = "Picture-in-Picture" },
  float = true,
})

hl.window_rule({
  name = "azote-float",
  match = { class = "azote" },
  float = true,
})

hl.window_rule({
  name = "steam-friends-float",
  match = { class = "steam", title = "Friends List" },
  float = true,
})

-- windowrule = float 1, match:class gamescope
-- windowrule = float 1, match:xdg_tag proton-game

hl.window_rule({
  name = "steam-app-float",
  match = { initial_class = "^steam_app_.*" },
  float = true,
})

hl.window_rule({
  name = "modorganizer-no-bar",
  match = { float = true, class = "steam_app_0", initial_title = "^ModOrganizer$" },
  border_size = 0,
  no_shadow = true,
  no_blur = true,
  ["hyprbars:no_bar"] = PluginManager.if_loaded("hyprbars", true, nil),
})

-- Affinity
hl.window_rule({
  name = "affinity-tile",
  match = { class = "affinity.exe", initial_title = "Affinity" },
  tile = true,
})

hl.window_rule({
  name = "affinity-no-bar",
  match = { float = true, class = "affinity.exe", title = "^$" },
  border_size = 0,
  no_shadow = true,
  no_blur = true,
  ["hyprbars:no_bar"] = PluginManager.if_loaded("hyprbars", true, nil),
})

-- flameshot
-- hl.window_rule({
--   name = "flameshot-overlay",
--   match = { class = "flameshot" },
--   move = "0 0",
--   pin = true,
--   border_size = 0,
--   rounding = 0,
--   stay_focused = true,
--   float = true,
--   opaque = true,
--   ["hyprbars:no_bar"] = plugin_manager.if_loaded("hyprbars", true, nil),
--   size = { 8320, 2160 },
-- })

-- screenkey
hl.window_rule({
  name = "screenkey-float",
  match = { class = "one.alynx.showmethekey", initial_title = "^Floating Window.*" },
  float = true,
  pin = true,
  no_initial_focus = true,
  opacity = 0.7,
  decorate = false,
  border_size = 0,
  no_shadow = true,
  no_blur = true,
  ["hyprbars:no_bar"] = PluginManager.if_loaded("hyprbars", true, nil),
})

-- Window bars
hl.window_rule({
  name = "no-bar-tiled",
  match = { float = false },
  ["hyprbars:no_bar"] = PluginManager.if_loaded("hyprbars", true, nil),
})
