--- @namespace hypr.user
--- @using pebbles
--- @using imminent

-- #######################################################################################
-- HYPRLAND CONFIG
-- #######################################################################################

-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/

-- Lua 5.1 compat
if not unpack then _G.unpack = table.unpack end

local function append_pkgpath(path)
  package.path = package.path
    .. ";"
    .. table.concat({
      path .. "/?.lua",
      path .. "/?/init.lua",
      path .. "/?.so",
    }, ";")
end

local constants = require("lib.constants")

local HOME = constants.HOME
local CONF_DIR = constants.CONF_DIR

append_pkgpath(HOME .. "/.luarocks/lib/lua/5.5/lpeg")
append_pkgpath(HOME .. "/.luarocks/lib/lua/5.5/luv")
append_pkgpath(HOME .. "/.luarocks/share/lua/5.5")
append_pkgpath(CONF_DIR .. "/deps/imminent.nvim/lua")

local PluginManager = require("lib.PluginManager")
local async = require("imminent")
local pb = require("imminent.pebbles")

local d = hl.dispatch

-------------
-- PLUGINS --
-------------

-- Custom declarative plugin config. This loads the plugin library files _if
-- they're found_. Gracefully fails with a warning notification otherwise.
--
-- This _must_ be loaded early in the config.
--
-- NOTE: Make sure hyprpm plugins are disabled in /var/cache/hyprpm/$USER/state.toml
PluginManager.setup({
  { "hyprbars" },
  { "borders-plus-plus", enabled = false },
})

-----------------
-- MY PROGRAMS --
-----------------

-- Set programs that you use
local TERMINAL = "kitty"
local FILE_EXPLORER = "thunar"
local MENU = HOME .. "/.config/rofi/applets/launchers-git/launcher.sh"

---------------
-- AUTOSTART --
---------------

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("xrdb -merge " .. HOME .. "/.Xresources")
  hl.exec_cmd("dunst")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hyprpm reload")
  hl.exec_cmd("bash -c '[ -x ~/.azotebg-hyprland ] && ~/.azotebg-hyprland'")
  hl.exec_cmd("udiskie")
  hl.exec_cmd("env QT_QPA_PLATFORM=xcb insync start")
  hl.exec_cmd("thunar --daemon")
  hl.exec_cmd("bash -c 'command -v hushmic && hushmic'")
end)

---------------------------
-- ENVIRONMENT VARIABLES --
---------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("HYPRCURSOR_THEME", "Vimix-cursors")
hl.env("XCURSOR_THEME", "Vimix-cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")

-----------------
-- PERMISSIONS --
-----------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-------------------
-- LOOK AND FEEL --
-------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 20,

    border_size = 1,

    -- https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
    col = {
      active_border = "rgb(888888)",
      inactive_border = "rgba(595959aa)",
    },

    -- Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
    allow_tearing = false,

    layout = "dwindle",
  },

  decoration = {
    rounding = 5,
    rounding_power = 2.0,

    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 16,
      scale = 0.985,
      render_power = 1,
      color = "rgba(1a1a1a77)",
      offset = { 0, 5 },
    },

    -- https://wiki.hypr.land/Configuring/Variables/#blur
    blur = {
      enabled = false,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  -- Ref https://wiki.hypr.land/Configuring/Workspace-Rules/
  -- "Smart gaps" / "No gaps when only"
  -- uncomment all if you wish to use that.
  -- workspace_rule = { ... }

  dwindle = {
    preserve_split = true,
    force_split = 2,
    smart_split = false,
    use_active_for_splits = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    vrr = 0,
  },

  experimental = {},

  render = {
    cm_auto_hdr = 2,
    -- Default transfer function for displaying SDR apps. "default" - Use
    -- default value (sRGB), "gamma22" - Treat unspecified as Gamma 2.2,
    -- "gamma22force" - Treat unspecified and sRGB as Gamma 2.2, "srgb" - Treat
    -- unspecified as sRGB
    cm_sdr_eotf = "default",
    -- Use FP16 buffers internally. 0 - disabled, 1 - enabled, 2 - enabled in
    -- hdr mode (default: `2`)
    use_fp16 = 1,
  },

  quirks = {
    prefer_hdr = 1,
  },

  debug = {
    disable_logs = false,
  },
})

-- https://wiki.hypr.land/Configuring/Variables/#animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({
  leaf = "windowsIn",
  enabled = true,
  speed = 4.1,
  bezier = "easeOutQuint",
  style = "popin 87%",
})
hl.animation({
  leaf = "windowsOut",
  enabled = true,
  speed = 1.49,
  bezier = "linear",
  style = "popin 87%",
})
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({
  leaf = "layersIn",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
  style = "fade",
})
hl.animation({
  leaf = "layersOut",
  enabled = true,
  speed = 1.5,
  bezier = "linear",
  style = "fade",
})
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 1.94,
  bezier = "almostLinear",
  style = "fade",
})
hl.animation({
  leaf = "workspacesIn",
  enabled = true,
  speed = 1.21,
  bezier = "almostLinear",
  style = "fade",
})
hl.animation({
  leaf = "workspacesOut",
  enabled = true,
  speed = 1.94,
  bezier = "almostLinear",
  style = "fade",
})
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 2, bezier = "quick" })

-----------
-- INPUT --
-----------

hl.config({
  input = {
    kb_layout = "us,no",
    kb_options = "caps:escape,terminate:ctrl_alt_bksp,grp:shift_caps_toggle",
    repeat_delay = 200,
    repeat_rate = 60,

    follow_mouse = 1,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.device({
  name = "ydotoold-virtual-device",
  kb_layout = "us",
  kb_variant = "",
  kb_options = "",
  sensitivity = 0,
})

-- https://wiki.hypr.land/Configuring/Variables/#gestures
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

-----------------
-- KEYBINDINGS --
-----------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(HOME .. "/.config/hypr/scripts/system-menu"))
hl.bind(mainMod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + X", hl.dsp.eval("hl.dsp.layout('togglesplit')")) -- dwindle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + O", pb.bind(require("scripts.toggle_gaps"), 5, 20))

-- Program binds
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(TERMINAL))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(TERMINAL .. " --class kitty_FLOAT"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(FILE_EXPLORER))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(MENU))
hl.bind(
  mainMod .. " + P",
  hl.dsp.exec_cmd(table.concat({
    "nwg-displays",
    "--monitors_path",
    HOME .. "/.config/hypr/extra/00_monitors.conf",
    "--workspaces_path",
    HOME .. "/.config/hypr/extra/10_workspaces.conf",
  }, " "))
)
hl.bind("Print", hl.dsp.exec_cmd(HOME .. "/.config/scripts/screenshot-utils.sh -s"))
hl.bind(
  mainMod .. " + SHIFT + Print",
  hl.dsp.exec_cmd(HOME .. "/.config/scripts/screenshot-utils.sh -a")
)
hl.bind("MOD5 + 3", hl.dsp.exec_cmd("1password"))
hl.bind("ALT + Alt_R + 3", hl.dsp.exec_cmd("1password"), { release = true })
hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("rofi -modi emoji -show emoji"))

-- Magnify
hl.bind(
  mainMod .. " + SHIFT + mouse_up",
  hl.dsp.exec_cmd(HOME .. "/.config/hypr/scripts/magnify +0.5 3.0")
)
hl.bind(
  mainMod .. " + SHIFT + mouse_down",
  hl.dsp.exec_cmd(HOME .. "/.config/hypr/scripts/magnify 1.0")
)

-- Move focus with mod + arrow keys
hl.bind(mainMod .. " + H", function()
  d(hl.dsp.focus({ direction = "left" }))
  d(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + J", function()
  d(hl.dsp.focus({ direction = "down" }))
  d(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + K", function()
  d(hl.dsp.focus({ direction = "up" }))
  d(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + L", function()
  d(hl.dsp.focus({ direction = "right" }))
  d(hl.dsp.window.bring_to_top())
end)

hl.bind(mainMod .. " + left", function()
  d(hl.dsp.focus({ direction = "left" }))
  d(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + down", function()
  d(hl.dsp.focus({ direction = "down" }))
  d(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + up", function()
  d(hl.dsp.focus({ direction = "up" }))
  d(hl.dsp.window.bring_to_top())
end)
hl.bind(mainMod .. " + right", function()
  d(hl.dsp.focus({ direction = "right" }))
  d(hl.dsp.window.bring_to_top())
end)

hl.bind(mainMod .. " + D", require("scripts.toggle_focus_floating"))

-- Move window
local smartMove = require("scripts.smart_move")
hl.bind(mainMod .. " + SHIFT + H", pb.bind(smartMove, 30, "l"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", pb.bind(smartMove, 30, "d"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", pb.bind(smartMove, 30, "u"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + L", pb.bind(smartMove, 30, "r"), { repeating = true })

-- Window resize mode
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  local delta = 20
  hl.bind("H", hl.dsp.window.resize({ x = -delta, y = 0, relative = true }), { repeating = true })
  hl.bind("J", hl.dsp.window.resize({ x = 0, y = delta, relative = true }), { repeating = true })
  hl.bind("K", hl.dsp.window.resize({ x = 0, y = -delta, relative = true }), { repeating = true })
  hl.bind("L", hl.dsp.window.resize({ x = delta, y = 0, relative = true }), { repeating = true })
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- Switch workspaces with mod + [0-9]
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + B", hl.dsp.focus({ workspace = "previous_per_monitor" }))

-- Move active window to a workspace with mod + SHIFT + [0-9]
for i = 1, 9 do
  hl.bind(mainMod .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

for i = 1, 9 do
  hl.bind(
    mainMod .. " + CTRL + " .. tostring(i),
    hl.dsp.window.move({ workspace = tostring(i), follow = false })
  )
end
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({ workspace = "10", follow = false }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + Minus", function()
  d(hl.dsp.workspace.toggle_special("magic"))
  d(hl.dsp.window.bring_to_top())
end)
hl.bind(
  mainMod .. " + SHIFT + Minus",
  require("scripts.toggle_move_special")
)

-- Scroll through existing workspaces with mod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/volume-utils.sh --inc 2"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/volume-utils.sh --dec 2"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/volume-utils.sh --mute"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioPlay",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active play-pause"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioPause",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active pause"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioNext",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active next"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioPrev",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active previous"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioStop",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active stop"),
  { locked = true, repeating = true }
)

hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/brightness.sh --inc"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/brightness.sh --dec"),
  { locked = true, repeating = true }
)

-- Map extra media keys for keyboards without them
hl.bind(
  mainMod .. " + Prior",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/volume-utils.sh --inc 2"),
  { locked = true, repeating = true }
)
hl.bind(
  mainMod .. " + Next",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/volume-utils.sh --dec 2"),
  { locked = true, repeating = true }
)
hl.bind(
  mainMod .. " + Insert",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active play-pause"),
  { locked = true, repeating = true }
)
hl.bind(
  mainMod .. " + Home",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active previous"),
  { locked = true, repeating = true }
)
hl.bind(
  mainMod .. " + End",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/playerctl-utils.sh --use-active next"),
  { locked = true, repeating = true }
)
hl.bind(
  mainMod .. " + Delete",
  hl.dsp.exec_cmd(HOME .. "/.config/i3/scripts/volume-utils.sh --mute"),
  { locked = true, repeating = true }
)

PluginManager.load_plugin_configs()

----------------------------
-- WINDOWS AND WORKSPACES --
----------------------------

require("window_rules")

-----------------------------
-- SOURCE ADDITIONAL FILES --
-----------------------------

async.block_on(function()
  async.fs.ls(CONF_DIR .. "/extra", { max_depth = math.huge --[[@as int ]] })
    :await()
    :unwrap()
    :iter()
    :map(function(entry)
      return entry.path:extension() == "lua" and
        entry.path:to_os_path() or
        pb.None
    end)
    :sorted()
    :for_each(function(s_path) dofile(s_path) end)
end)
