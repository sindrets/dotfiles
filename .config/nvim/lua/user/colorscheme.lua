---Define the default colorscheme.
---
---Format is `"{name} [bg]"`, where `{name}` is the name of the colorscheme,
---and `[bg]` is the optionally defined value for 'background'. `{name}` may
---also be replaced with one of the special values "default_dark" or
---"default_light" which will apply a predefined default dark or light color
---scheme.
---
---Override the default colorscheme by defining the environment variable
---`NVIM_COLORSCHEME` using the same format.
local DEFAULT_COLORSCHEME = "default_dark"

local Color = Config.common.color.Color
local utils = Config.common.utils
local hl = Config.common.hl
local hi, hi_link, hi_clear = hl.hi, hl.hi_link, hl.hi_clear

local M = {}

M.DEFAULT_DARK = "vscode"
M.DEFAULT_LIGHT = "seoulbones"

do
  local name, bg
  for _, source in ipairs(utils.vec_join(vim.env.NVIM_COLORSCHEME, DEFAULT_COLORSCHEME)) do
    name, bg = unpack(vim.split(source or "", "%s+", {}))
    if name ~= "" then
      break
    end
  end

  ---Name of the currently configured colorscheme.
  ---@type string
  M.name = name
  ---Configured value for 'background'.
  ---@type string?
  M.bg = bg

  if name == "default_dark" then
    M.name = M.DEFAULT_DARK
    M.bg = "dark"
  elseif name == "default_light" then
    M.name = M.DEFAULT_LIGHT
    M.bg = "light"
  end
end

local diagnostic_kinds = { "Error", "Warn", "Info", "Hint", "Ok" }

function M.supports_sp_underline()
  if vim.g.started_by_firenvim then
    return true
  end
  return vim.tbl_contains({ "xterm-kitty", "wezterm" }, vim.env.TERM)
end

function M.apply_sp_underline()
  local spell_names = { "Bad", "Cap", "Rare", "Local" }
  for _, name in ipairs(spell_names) do
    local fg = hl.get_fg("Spell" .. name)
    if fg then
      hi("Spell" .. name, { style = "undercurl", sp = fg, fg = "NONE", bg = "NONE" })
    end
  end

  -- Normalize diagnostic underlines
  for _, name in ipairs(diagnostic_kinds) do
    hi_clear("DiagnosticUnderline" .. name)
    hi("DiagnosticUnderline" .. name, {
      style = "underline",
      sp = hl.get_fg("Diagnostic" .. name),
      fg = "NONE"
    })
  end
end

function M.clear_terminal_colors()
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = nil
  end
end

function M.apply_terminal_defaults()
  -- black
  vim.g.terminal_color_0  = "#15161E"
  vim.g.terminal_color_8  = "#414868"
  -- red
  vim.g.terminal_color_1  = "#f7768e"
  vim.g.terminal_color_9  = "#f7768e"
  -- green
  vim.g.terminal_color_2  = "#9ece6a"
  vim.g.terminal_color_10 = "#9ece6a"
  -- yellow
  vim.g.terminal_color_3  = "#e0af68"
  vim.g.terminal_color_11 = "#e0af68"
  -- blue
  vim.g.terminal_color_4  = "#7aa2f7"
  vim.g.terminal_color_12 = "#7aa2f7"
  -- magenta
  vim.g.terminal_color_5  = "#bb9af7"
  vim.g.terminal_color_13 = "#bb9af7"
  -- cyan
  vim.g.terminal_color_6  = "#7dcfff"
  vim.g.terminal_color_14 = "#7dcfff"
  -- white
  vim.g.terminal_color_7  = "#a9b1d6"
  vim.g.terminal_color_15 = "#c0caf5"
end

---[Graph](https://www.desmos.com/calculator/tmiqlckphe)
---@param k number # Slope
function M.parametric_ease_out(k)
  ---@param x number # [0,1]
  ---@return number # Progression
  return function(x)
    if x <= 0 then return 0 end
    if x >= 1 then return 1 end
    return math.pow(1 - x, 2 * (k + 1 / 2)) * (-1) + 1
  end
end

function M.generate_base_colors()
  local bg = vim.o.bg
  local default_bg = Color.from_hex(bg == "dark" and "#111111" or "#eeeeee")
  local default_fg = Color.from_hex(bg == "dark" and "#eeeeee" or "#111111")

  ---@type { [string]: { fg: Color, bg: Color } }
  local groups = {}
  local targets = { "Normal", "StatusLine" }

  for _, target in ipairs(targets) do
    local data = hl.get_hl(target)

    if data then
      groups[target] = {
        fg = data.fg and Color.from_hex(bit.lshift(data.fg, 8) + 0xff) or default_fg,
        bg = data.bg and Color.from_hex(bit.lshift(data.bg, 8) + 0xff) or default_bg,
      }
    end
  end

  -- Generate dimmed color variants

  local f = M.parametric_ease_out(0.4)

  local first, last = 1, 9

  for i = first, last do
    local fstep = (i - first + 1) / (last - first + 2)
    local step_name = math.floor(fstep * 1000)

    for group, values in pairs(groups) do
      hi(group .. "Dim" .. step_name, { fg = values.fg:clone():blend(values.bg, f(fstep)):to_css() })
    end
  end
end

---@class GenerateDiffColorsSpec
---@field no_override boolean
---@field no_derive boolean|{ add: boolean, del: boolean, mod: boolean, all: boolean }

---@param opt? GenerateDiffColorsSpec
function M.generate_diff_colors(opt)
  opt = opt or {}
  local bg = vim.o.bg
  local hl_bg_normal = hl.get_bg("Normal") or (bg == "dark" and "#111111" or "#eeeeee")

  if type(opt.no_derive) == "nil" then
    opt.no_derive = {}
  elseif type(opt.no_derive) == "boolean" then
    opt.no_derive = { all = opt.no_derive }
  end

  local bg_normal = Color.from_hex(hl_bg_normal)
  local bright = bg_normal.lightness >= 0.5

  local base_colors = {}
  if not opt.no_derive.all then
    base_colors.add = not opt.no_derive.add and Color.from_hl("diffAdded", "fg") or nil
    base_colors.del = not opt.no_derive.del and Color.from_hl("diffRemoved", "fg") or nil
    base_colors.mod = not opt.no_derive.mod and Color.from_hl("diffChanged", "fg") or nil
  end

  if bright then
    base_colors = vim.tbl_extend("keep", base_colors, {
      add = Color.from_hex("#97BE65"):mod_lightness(-0.2),
      del = Color.from_hex("#FF6C69"):mod_lightness(-0.1),
      mod = Color.from_hex("#51afef"):mod_lightness(-0.1):mod_value(-0.15),
    }) --[[@as table ]]
  else
    base_colors = vim.tbl_extend("keep", base_colors, {
      add = Color.from_hex("#97BE65"),
      del = Color.from_hex("#FF6C69"),
      mod = Color.from_hex("#51afef"),
    }) --[[@as table ]]
  end

  local base_add = base_colors.add --[[@as Color ]]
  local base_del = base_colors.del --[[@as Color ]]
  local base_mod = base_colors.mod --[[@as Color ]]

  local bg_add = base_add:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_add_text = base_add:blend(bg_normal, 0.7):mod_saturation(0.05)
  local bg_del = base_del:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_del_text = base_del:blend(bg_normal, 0.7):mod_saturation(0.05)
  local bg_mod = base_mod:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_mod_text = base_mod:blend(bg_normal, 0.7):mod_saturation(0.05)

  -- Builtin groups

  if not opt.no_override then
    hi("DiffAdd", { bg = bg_add:to_css(), fg = "NONE", style = "NONE", explicit = true })
    hi("DiffDelete", { bg = bg_del:to_css(), fg = "NONE", style = "NONE", explicit = true })
    hi("DiffChange", { bg = bg_mod:to_css(), fg = "NONE", style = "NONE", explicit = true })
    hi("DiffText", { bg = bg_mod_text:to_css(), fg = base_mod:to_css(), style = "NONE", explicit = true })

    hi("diffAdded", { fg = base_add:to_css(), bg = "NONE", style = "NONE", explicit = true })
    hi("diffRemoved", { fg = base_del:to_css(), bg = "NONE", style = "NONE", explicit = true })
    hi("diffChanged", { fg = base_mod:to_css(), bg = "NONE", style = "NONE", explicit = true })
  end

  -- Custom groups

  hi("DiffAddText", { bg = bg_add_text:to_css(), fg = base_add:to_css(), style = "NONE", explicit = true })
  hi("DiffDeleteText", { bg = bg_del_text:to_css(), fg = base_del:to_css(), style = "NONE", explicit = true })

  hi("DiffInlineAdd", { bg = bg_add:to_css(), fg = base_add:to_css(), style = "NONE", explicit = true })
  hi("DiffInlineDelete", { bg = bg_del:to_css(), fg = base_del:to_css(), style = "NONE", explicit = true })
  hi("DiffInlineChange", { bg = bg_mod:to_css(), fg = base_mod:to_css(), style = "NONE", explicit = true })

  hi_link("@text.diff.add", "DiffInlineAdd")
  hi_link("@text.diff.delete", "DiffInlineDelete")
end

---Give Telescope its default appearance.
function M.unstyle_telescope()
  hi_link("TelescopeNormal", "NormalFloat", { clear = true })
  hi_link("TelescopeBorder", "FloatBorder", { clear = true })
  hi_link(
    { "TelescopePromptNormal", "TelescopeResultsNormal", "TelescopePreviewNormal" },
    "TelescopeNormal",
    { clear = true }
  )
  hi_link(
    { "TelescopePromptBorder", "TelescopeResultsBorder", "TelescopePreviewBorder" },
    "TelescopeBorder",
    { clear = true }
  )
  hi_link(
    { "TelescopePromptTitle", "TelescopePreviewTitle", "TelescopeResultsTitle" },
    "TelescopeNormal",
    { clear = true }
  )
  hi("TelescopePromptPrefix", { bg = "NONE" })
end

function M.apply_log_defaults()
  hi_link("logLevelTrace", "DiagnosticHint")
  hi_link({ "logLevelInfo", "logLevelNotice" }, "DiagnosticInfo")
  hi_link({ "logLevelWarning", "logLevelDebug", "logLevelAlert" }, "DiagnosticWarn")
  hi_link({ "logLevelError", "logLevelCritical", "logLevelEmergency" }, "DiagnosticError")
end

function M.find_base_colors()
  local primary = Color.from_hl({ "Function", "Title", "Normal" }, "fg") --[[@as Color ]]
  local accent

  for _, name in ipairs({ "@function.builtin", "Statement", "Constant", "Statement", "Title" }) do
    local color = Color.from_hl(name, "fg")
    if color and color:to_hex() ~= primary:to_hex() then
      accent = color
      break
    end
  end

  return {
    primary = primary,
    accent = accent,
  }
end

---Configure the colorscheme before it's loaded.
---@param colors_name string The name of the new colorscheme.
function M.setup_colorscheme(colors_name)
  M.clear_terminal_colors()

  if colors_name == "ayucolor" then
    vim.g.ayucolor = "dark"
  elseif colors_name == "gruvbox" then
    vim.g.gruvbox_italic = 1
    vim.g.gruvbox_contrast_dark = "medium"
    vim.g.gruvbox_invert_selection = 0
  elseif colors_name == "gruvbox-material" then
    vim.g.gruvbox_material_background = 'medium'
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_diagnostic_line_highlight = 1
  elseif colors_name:match("^base16") then
    vim.g.base16colorspace = 256
  elseif colors_name == "palenight" then
    vim.g.palenight_terminal_italics = 1
  elseif colors_name == "rose-pine" then
    vim.g.rose_pine_variant = "moon"
    vim.g.rose_pine_enable_italics = true
  elseif colors_name == "tokyonight" then
    vim.g.tokyonight_style = "storm"
    vim.g.tokyonight_dark_sidebar = 1
    vim.g.tokyonight_sidebars = { "qf", "packer", "DiffviewFiles" }

    if vim.g.tokyonight_style == "night" then
      vim.g.tokyonight_colors = {
        ["bg_dark"] = "#16161F",
        ["bg_popup"] = "#16161F",
        ["bg_statusline"] = "#16161F",
        ["bg_sidebar"] = "#16161F",
        ["bg_float"] = "#16161F",
      }
    else
      vim.g.tokyonight_colors = nil
    end
  elseif colors_name == "material" then
    require("user.plugins.material")()
  elseif colors_name == "catppuccin" then
    if vim.o.bg == "light" then
      vim.g.catppuccin_flavour = "latte"

      require("catppuccin").setup({
        integrations = {
          bufferline = false,
        },
      })
    else
      vim.g.catppuccin_flavour = "mocha"
    end
  elseif colors_name == "oxocarbon-lua" then
    vim.g.oxocarbon_lua_keep_terminal = true
  end
end

---Tweaks applied after loading a colorscheme.
function M.apply_tweaks()
  if not vim.o.termguicolors then
    Config.common.utils.warn(
      "'termguicolors' is not set! Color scheme tweaks might have unexpected results!"
    )
  end

  if not vim.g.colors_name then
    Config.common.utils.err("'g:colors_name' is not set for the current color scheme!")
  end

  local colors_name = vim.g.colors_name or ""
  local bg = vim.o.bg
  local bg_normal = Color.from_hl("Normal", "bg")
      or Color.from_hex(bg == "dark" and "#111111" or "#eeeeee")
  local fg_normal = Color.from_hl("Normal", "fg") --[[@as Color ]]
  local base_colors = M.find_base_colors()

  hi_clear({ "Cursor", "TermCursor" })
  hi("TermCursor", { style = "reverse" })
  hi("NonText", { style = "nocombine" })
  hi("Hidden", { fg = "bg", bg = "bg" })
  hi("CursorLine", { sp = fg_normal:to_css() })
  hi("Primary", { fg = base_colors.primary:to_css() })
  hi("Accent", { fg = base_colors.accent:to_css() })

  ---Controls whether or not diff hl is generated.
  local do_diff_gen = true
  ---@type GenerateDiffColorsSpec
  local diff_gen_opt
  ---@type FelineThemeName
  local feline_theme = "duo"

  if colors_name == "codedark" then
    hi("NonText", { bg = "NONE", })

  elseif colors_name == "tender" then
    hi("Visual", { style = "NONE", bg = "#293b44", })
    hi("VertSplit", { fg = "#202020", bg = "NONE", })
    hi("Search", { style = "bold", fg = "#dddddd", bg = "#7a6a24", })

  elseif colors_name == "horizon" then
    hi("NonText", { fg = "#414559", bg = "NONE", })
    hi("VertSplit", { style = "bold", fg = "#0f1117", bg = "NONE", })
    hi("Pmenu", { bg = "#272c42", fg = "#eff0f4", })
    hi("PmenuSel", { bg = "#5b6389", })
    hi("PmenuSbar", { bg = "#3d425b", })
    hi("PmenuThumb", { bg = "#0f1117", })
    hi("CursorLineNr", { style = "bold", fg = "#09f7a0", bg = "NONE", })
    hi("QuickFixLine", { bg = "#335172", fg = "NONE", })
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")
    hi_link("jsonQuote")

  elseif colors_name == "monokai_pro" then
    hi("NonText", { fg = "#5b595c", bg = "None", })
    hi("VertSplit", { fg = "#696769", bg = "None", })
    hi("Pmenu", { fg = "#a9dc76", bg = "#252226", })
    hi("PmenuSel", { bg = "#403e41", })
    hi("PmenuSbar", { bg = "Grey", })
    hi("PmenuThumb", { bg = "White", })
    hi("CursorLineNr", { style = "bold", fg = "Yellow", bg = "#423f42", })
    hi("SignColumn", { bg = "#423f42", })
    hi("FoldColumn", { fg = "Cyan", bg = "#423f42", })
    hi("QuickFixLine", { bg = "#714754", fg = "NONE", })
    hi("Search", { fg = "#ffd866", style = "bold,underline", })
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")
    hi_link("jsonQuote")

  elseif colors_name == "gruvbox-material" then
    hi("CursorLineNr", { style = "bold", fg = "#a9b665", })

  elseif colors_name == "predawn" then
    hi("NonText", { fg = "#3c3c3c", bg = "None", })
    hi("CursorLine", { bg = "#303030", })
    hi("SignColumn", { fg = "#8c8c8c", bg = "#3c3c3c", })
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")
    hi_link("jsonQuote")

  elseif colors_name == "nvcode" then
    hi("CocExplorerGitIgnored", { fg = "#5C6370", })
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")

  elseif colors_name == "zephyr" then
    hi("Visual", { fg = "NONE", bg = "#393e49", })

  elseif colors_name == "tokyonight" then
    hi_link("ColorColumn", "CursorLine")
    if bg == "dark" then
      hi("DiffAdd", { bg = "#283B4D", fg = "NONE", })
      hi("DiffChange", { bg = "#28304d", fg = "NONE", })
      hi("DiffText", { bg = "#36426b", fg = "NONE", })
    end
    hi_link("GitsignsAdd", "String")
    -- hi_link("DiffviewNormal", "NormalSB")

  elseif colors_name == "everforest" then
    hi("SignColumn", { bg = "NONE", })
    hi("FoldColumn", { bg = "NONE", })
    hi("OrangeSign", { bg = "NONE", })
    hi("GreenSign", { bg = "NONE", })
    hi("PurpleSign", { bg = "NONE", })
    hi("RedSign", { bg = "NONE", })
    hi("YellowSign", { bg = "NONE", })
    hi("AquaSign", { bg = "NONE", })
    hi("BlueSign", { bg = "NONE", })
    if bg == "light" then
      hi("Search", { bg = "#35a77c", })
      hi("CursorLineNr", { style = "bold", bg = "NONE", fg = "#8da101", })
      hi("DiffAdd", { bg = "#EBF4BF", fg = "NONE", })
      hi("DiffDelete", { bg = "#FCDDCC", fg = "NONE", })
      hi("DiffChange", { bg = "#E3ECE4", fg = "NONE", })
      hi("DiffText", { bg = "#BEDFE6", fg = "NONE", })
    else
      hi("CursorLineNr", { style = "bold", bg = "NONE", fg = "#a7c080", })
      -- hi("DiffText", { bg = "#4a6778", fg = "NONE", })
    end

  elseif colors_name == "palenight" then
    hi("Visual", { bg = bg_normal:clone():mod_value(0.18):mod_saturation(0.2):to_css() })
    hi("CursorLine", { bg = "#212433", })
    hi("StatusLine", { bg = "#212433", })
    hi("StatusLineNC", { bg = "#212433", })
    hi("Folded", { bg = "#1e212e", })
    hi("ColorColumn", { bg = "#33384d", })
    hi("NonText", { fg = "#3c445f", })
    hi("TabLineSel", { fg = "#82b1ff", })
    hi("IndentBlanklineContextChar", { fg = "#82b1ff", })
    hi("EndOfBuffer", { fg = "#292D3E", })
    hi("PmenuThumb", { bg = "#6A3EB5" })
    hi_link("QuickFixLine", "DiffText")
    hi_link("@comment", "Comment")
    hi_link("NvimTreeIndentMarker", "LineNr")
    hi_link("TelescopeBorder", "Directory")
    hi("DiffAdd", { bg = "#344a4d", fg = "NONE", })
    hi("DiffDelete", { bg = "#4b3346", fg = "NONE", })
    hi("DiffChange", { bg = "#32395c", fg = "NONE", })
    hi("DiffText", { bg = "#3f4a87", fg = "NONE", })
    hi("diffChanged", { fg = "#82b1ff", })
    hi("GitSignsChange", { fg = "#82b1ff", })
    hi("LspReferenceText", { bg = bg_normal:clone():mod_value(0.12):to_css() })
    hi("LspReferenceRead", { bg = bg_normal:clone():mod_value(0.12):to_css() })
    hi("LspReferenceWrite", { bg = bg_normal:clone():mod_value(0.12):to_css() })
    hi("NvimTreeRootFolder", { fg = "#C3E88D", style = "bold", })
    hi("NvimTreeFolderIcon", { fg = "#F78C6C", })
    hi("NvimTreeNormal", { bg = "#222533", })
    hi("NvimTreeCursorLine", { bg = "#33374c", })
    hi("NvimTreeGitDirty", { fg = "#ffcb6b", })
    do_diff_gen = false

  elseif colors_name == "onedarkpro" then
    hi({ "Cursor", "TermCursor" }, { style = "reverse", bg = "NONE", })
    hi("NormalFloat", { bg = bg_normal:clone():mod_value(-0.025):to_css(), })
    hi_link("TelescopeSelection", "CursorLine")
    hi_link("TelescopeBorder", "Directory")
    hi_link("diffChanged", "Directory")
    if bg == "dark" then
      hi("Identifier", { fg = "#c678dd", })
      hi("TabLineSel", { fg = "#61afef", bg = "NONE", })
      hi("Whitespace", { fg = bg_normal:clone():mod_value(0.2):to_css(), })
      hi("NonText", { fg = bg_normal:clone():mod_value(0.2):to_css(), bg = "NONE" })
      hi("IndentBlanklineContextChar", { fg = "#61afef", })
      hi("CursorLine", { bg = bg_normal:clone():mod_value(-0.05):to_css(), })
      hi("FoldColumn", { fg = "#61afef", })
      hi("StatusLine", { bg = bg_normal:clone():mod_value(-0.03):to_css(), })
      hi("LspReferenceText", { bg = bg_normal:clone():mod_value(0.1):to_css(), })
      hi("NvimTreeOpenedFolderName", { fg = "#61afef", style = "italic,bold", })
      hi("NvimTreeRootFolder", { fg = "#98c379", })
      hi("NvimTreeGitDirty", { fg = "#e5c07b", })
      hi("NvimTreeGitStaged", { fg = "#98c379", })
    end

  elseif colors_name == "doom-one" then
    if bg == "dark" then
      hi("Primary", { fg = hl.get_fg("Keyword") })
      hi("diffAdded", { bg = "NONE", fg = "#97BE65", })
      hi("diffRemoved", { bg = "NONE", fg = "#FF6C69", })
      hi("diffChanged", { fg = "#51afef", })
      hi("SignColumn", { bg = "NONE", })
      hi("CursorLine", { bg = bg_normal:clone():highlight(0.05):to_css() })
      hi("CursorLineNr", { bg = bg_normal:clone():highlight(0.05):to_css(), style = "bold" })
      hi("DiagnosticError", { fg = "#ff6c6b"} )
      hi("DiagnosticWarn", { fg = "#ECBE7B"} )
      hi("DiagnosticInfo", { fg = "#51afef"} )
      hi("DiagnosticHint", { fg = "LightBlue"} )
      hi("GitSignsChange", { fg = "#51afef", })
      hi("NvimTreeRootFolder", { style = "bold", })
      hi("SpellCap", { sp = "#51afef", })
      hi("SpellBad", { sp = "#FF6C69", })
      hi("SpellRare", { sp = "#a9a1e1", })
      hi("SpellLocal", { sp = "#da8548", })
      hi("Visual", { bg = Color.from_hl("WildMenu", "bg"):blend(bg_normal, 0.7):to_css() })
      hi("LspReferenceText", { bg = bg_normal:clone():mod_value(0.1):to_css()})
      vim.opt.pumblend = 0
    end

  elseif colors_name == "catppuccin" then
    hi("Primary", { fg = hl.get_fg("Function") })
    hi("Accent", { fg = hl.get_fg("Constant") })
    hi_link("ColorColumn", "CursorLine")
    hi("CursorLine", { style = "NONE", bg = bg_normal:clone():highlight(0.07):to_css() })
    hi({ "TsNumber", "TsFloat" }, { style = "NONE" })
    hi("Visual", {
      style = "NONE",
      bg = Color.from_hl("Directory", "fg")
      :mod_lightness(-0.1)
      :blend(bg_normal, 0.85)
      :to_css()
    })
    hi("TablineSel", { bg = "NONE" })
    hi("BufferLineCloseButtonSelected", { fg = fg_normal:clone():blend(bg_normal, 0.3):to_css() })
    hi("BufferLineIndicatorSelected", { fg = hl.get_fg("Accent") })
    hi("TelescopeBorder", { fg = hl.get_fg("FloatBorder") })

    if bg == "dark" then
      hi({ "NormalFloat", "StatusLine" }, { bg = bg_normal:clone():mod_value(-0.025):to_css() })
      hi("diffAdded", { fg = "#B3E1A3" })
      hi("diffChanged", { fg = "#A4B9EF" })
      hi("ModeMsg", { fg = "#98BBF5" })
      hi("IndentBlanklineContextChar", { fg = "#B5E8E0" })
      hi("BufferLineFill", { bg = bg_normal:clone():highlight(-0.07):to_css() })
      hi("TelescopePromptPrefix", { fg = "#F08FA9" })
    else
      hi({ "NormalFloat", "StatusLine" }, { bg = bg_normal:clone():mod_value(-0.05):to_css() })
      hi("VertSplit", { fg = bg_normal:clone():mod_value(-0.25):to_css() })
    end

    -- Remove bg for diagnostics.
    for _, name in ipairs(diagnostic_kinds) do
      hi("Diagnostic" .. name, { bg = "NONE" })
    end

  elseif colors_name == "dracula" then
    hi("Primary", { fg = "#50FA7B" })
    hi("Accent", { fg = "#FF79C6" })
    hi_link("QuickFixLine", "Visual")

  elseif colors_name == "paper" then
    hi("Normal", { fg = "#222222" })
    hi("StatusLine", { fg = "#222222" })
    hi({ "CursorLine", "ColorColumn" }, { bg = bg_normal:clone():highlight(0.07):to_css() })
    hi({ "Whitespace", "NonText" }, { fg = bg_normal:clone():highlight(0.2):to_css(), bg = "NONE" })
    hi_link("IndentBlanklineChar", "Whitespace")
    hi("Visual", { bg = Color.from_hl("Number", "fg"):blend(bg_normal, 0.8):to_css() })
    hi("Directory", { fg= "#2c8dd0" })
    hi("LspReferenceText", { bg = Color.from_hex("#5c21a5"):blend(bg_normal, 0.85):to_css() })
    hi("DiagnosticHint", { fg = "#4d945f" })
    hi("MatchParen", { fg = "#ff3a36" })
    diff_gen_opt = { no_derive = true }

  elseif colors_name == "seoulbones" then
    if bg == "light" then
      hi("Primary", { fg = hl.get_fg("Statement") })
      hi("Accent", { fg = hl.get_fg("Keyword") })
      hi("CursorLine", { bg = bg_normal:clone():highlight(0.05):to_css() })
      hi("ColorColumn", { bg = bg_normal:clone():highlight(0.1):to_css() })
      hi("Comment", { fg = bg_normal:clone():highlight(0.4):to_css() })
      hi("Visual", {
        bg = Color.from_hl("Statement", "fg"):blend(bg_normal, 0.9):mod_hue(25):to_css(),
      })
      hi("StatusLine", { fg = hl.get_fg("String") })
      hi("MatchParen", { bg = "NONE" })
      hi("String", { fg = hl.get_fg("PreProc") })
      hi_link("Directory", "Accent", { clear = true })
      hi_link("@string", "String")
      hi_link("NormalFloat", "Normal")
      hi_link("@text.math", "Function")

      vim.g.terminal_color_0 = "#E2E2E2"
      vim.g.terminal_color_8 = "#BFBABB"
      vim.g.terminal_color_1 = "#DC5284"
      vim.g.terminal_color_9 = "#BE3C6D"
      vim.g.terminal_color_2  = "#628562"
      vim.g.terminal_color_10 = "#487249"
      vim.g.terminal_color_3  = "#C48562"
      vim.g.terminal_color_11 = "#A76B48"
      vim.g.terminal_color_4  = "#0084A3"
      vim.g.terminal_color_12 = "#006F89"
      vim.g.terminal_color_5  = "#896788"
      vim.g.terminal_color_13 = "#7F4C7E"
      vim.g.terminal_color_6  = "#008586"
      vim.g.terminal_color_14 = "#006F70"
      vim.g.terminal_color_7  = "#555555"
      vim.g.terminal_color_15 = "#777777"
    end

  elseif colors_name:match("^github_") then
    hi("Primary", { fg = hl.get_fg("Title") })
    hi("Accent", { fg = hl.get_fg("Statement") })
    hi("Directory", { fg = hl.get_fg("Title") })
    hi_link("NonText", "Whitespace")
    hi_link("ColorColumn", "CursorLine")
    hi_link("FloatBorder", "WinSeparator")
    hi_link({ "FoldColumn", "markdownCode", "markdownCodeBlock" }, "String")
    hi("Substitute", { fg = "#dddddd" })
    hi("StatusLine", {
      bg = bg_normal:clone():highlight(0.12):to_css(),
      fg = fg_normal:clone():highlight(-0.2):to_css(),
    })
    hi("NeogitDiffContextHighlight", { bg = bg_normal:clone():highlight(0.075):to_css() })
    hi_link("DashboardHeader", "Identifier")
    hi_link("DashboardCenter", "Keyword")
    -- hi_link("DashboardShortCut", "String")
    hl.hi("DashboardShortCut", { fg = hl.get_fg("String"), style = "bold,reverse" })
    hi_link("DashboardFooter", "Comment")
    hi_link("DiffviewFolderName", "Special")
    hi_clear("BufferLineBackground")
    hi({ "BufferLineModified", "BufferLineModifiedVisible", "BufferLineModifiedSelected" }, {
      fg = hl.get_fg("Directory"),
    })
    diff_gen_opt = { no_derive = { mod = true } }
    M.apply_terminal_defaults()
    M.unstyle_telescope()

  elseif colors_name == "kanagawa" then
    hi("WinSeparator", { bg = "NONE", fg = "#444444" })
    hi("diffChanged", { fg = "#7E9CD8" })
    hi("Whitespace", { fg = bg_normal:clone():highlight(0.18):to_css() })
    hi("BufferLineIndicatorSelected", { fg = "#7E9CD8" })

    vim.g.terminal_color_8 = "#393836"

  elseif colors_name == "oxocarbon-lua" then
    if bg == "dark" then
      hi("Primary", { fg = hl.get_fg("Boolean") })
      hi("Accent", { fg = hl.get_fg("@property") })
      hi_link("NormalNC", "Normal")
      hi("StatusLine", {
        bg = bg_normal:clone():highlight(0.05):to_css(),
        fg = fg_normal:clone():mod_value(-0.2):to_css()
      })
      hi({ "FloatBorder", "WinSeparator" }, { fg = bg_normal:clone():highlight(0.3):to_css() })
      hi("Visual", { bg = Color.from_hl("Type", "fg"):blend(bg_normal, 0.8):mod_hue(25):to_css() })
      hi("Search", { bg = hl.get_fg("String"), style = "bold" })
      hi("Title", { style = "bold" })
      hi("Error", { fg = hl.get_fg("@property"), explicit = true })
      hi("DiagnosticInfo", { fg = hl.get_fg("Boolean") })
      hi("DiagnosticHint", { fg = hl.get_fg("String") })
      hi("FoldColumn", { fg = Color.from_hl("Number", "fg"):blend(bg_normal, 0.2):to_css() })
      hi("BufferLineIndicatorSelected", { fg = hl.get_fg("ErrorMsg") })
      hi({ "BufferLineModified", "BufferLineModifiedVisible", "BufferLineModifiedSelected" }, {
        fg = hl.get_fg("Boolean"),
      })
      hi({ "markdown_inlineTSLiteral", "@text.literal" }, { fg = hl.get_fg("WinSeparator") })
      hi_link("DiffviewFilePanelConflicts", "String")
      hi_link("@text.math", "Function")
      hi("TelescopeMatching", { fg = hl.get_fg("String"), style = "bold" })
      hi_link({ "fugitiveHash", "gitHash" }, "String")
    end

    M.unstyle_telescope()

  elseif colors_name == "nordic" then
    hi("NormalFloat", { bg = bg_normal:clone():mod_value(-0.025):to_css() })
    hi("FloatBorder", {
      fg = bg_normal:clone():mod_value(0.1):to_css(),
      bg = hl.get_bg("NormalFloat"),
    })
    hi("Pmenu", { bg = bg_normal:clone():mod_value(-0.025):to_css() })
    hi("PmenuSbar", { bg = Color.from_hl("Pmenu", "bg"):mod_value(0.05):to_css() })
    hi("PmenuThumb", { bg = Color.from_hl("PmenuSbar", "bg"):mod_value(0.15):to_css(), fg = "NONE" })
    hi("Search", { bg = bg_normal:clone():mod_value(0.1):to_css() })
    hi({ "CursorLine", "ColorColumn" }, { bg = bg_normal:clone():mod_value(-0.05):to_css() })
    hi("CursorLineSB", { bg = Color.from_hl("NormalSB", "bg"):mod_value(0.02):to_css() })
    hi("diffAdded", { fg = "#B1D196" })
    hi("diffRemoved", { fg = "#D06F79" })
    hi("diffChanged", { fg = "#8CAFD2" })
    hi("Visual", {
      bg = Color.from_hl("diffChanged", "fg"):blend(bg_normal, 0.85):to_css(),
      style = "NONE",
    })
    hi({ "WinBar", "WinBarNC" }, { style = "bold", explicit = true })
    hi("StatusLine", { fg = Color.from_hl("StatusLine", "bg"):highlight(0.6):mod_saturation(-0.15):to_css() })
    hi({ "FoldColumn", "Folded" }, { fg = hl.get_fg("Conceal") })
    hi("Whitespace", { fg = bg_normal:clone():highlight(0.15):to_css() })
    hi(
      { "@text", "@text.literal.markdown", "vimUserFunc", "vimEmbedError", "cssMediaComma" },
      { fg = "fg", explicit = true, link = -1 }
    )
    hi("IndentBlanklineContextChar", { fg = Color.from_hl("Whitespace", "fg"):highlight(0.15):to_css() })
    hi_link("@parameter", "@constant")
    hi_link("CmpItemMenuDefault", "Comment", { clear = true })
    hi_link("fugitiveHash", "@function")
    hi_link("DiffviewCursorLine", "CursorLineSB")
    hi("DiffviewFolderName", { bg = "NONE" })

    M.unstyle_telescope()

  elseif colors_name == "vscode" then
    hi({ "Comment", "@comment" }, { fg = fg_normal:clone():blend(bg_normal, 0.5):to_css() })
    hi("WarningMsg", { fg = hl.get_fg("Special") })
    hi("DiagnosticHint", { fg = hl.get_fg("Structure") })
    hi({ "CursorLine", "ColorColumn" }, { bg = bg_normal:clone():highlight(0.03):to_css() })
    hi_link("CurSearch", "IncSearch")
    hi_link("@text.literal", "@constructor")
    hi("IndentBlanklineContextChar", { gui = "" })
    hi("DiffviewFilePanelSelected", { fg = hl.get_fg("Function"), explicit = true })
    hi_link("DiffviewReference", "@keyword")
    hi_link("TelescopePromptPrefix", "Accent")

    if bg == "dark" then
      hi("Primary", { fg = hl.get_fg("@boolean") })
      hi("Accent", { fg = hl.get_fg("Statement") })
      hi("diffChanged", { fg = hl.get_fg("@boolean"), explicit = true })
      hi(
        { "BufferLineModified", "BufferLineModifiedVisible", "BufferLineModifiedSelected" },
        { fg = hl.get_fg("@boolean") }
      )
    else
      hi("Primary", { fg = hl.get_fg("@variable") })
      hi("Accent", { fg = hl.get_fg("Structure") })
      hi("diffChanged", { fg = hl.get_fg("@label"), explicit = true })
      hi(
        { "BufferLineModified", "BufferLineModifiedVisible", "BufferLineModifiedSelected" },
        { fg = hl.get_fg("@variable") }
      )
    end
  end

  M.generate_base_colors()
  M.apply_log_defaults()

  hi({ "WinBar", "WinBarNC" }, { style = "bold", explicit = true })

  -- Treesitter
  hi("@text.emphasis", { style = "italic" })
  hi("@text.uri", { style = "underline" })
  hi("TreesitterContext", { bg = bg_normal:clone():highlight(0.08):to_css() })
  hi_link("@neorg.markup.verbatim", "@text.literal")

  hi({ "@neorg.tags.ranged_verbatim.code_block", "Folded" }, {
    bg = bg_normal:clone()
      :mod_value(-0.03)
      :to_css(),
  })

  -- Remove bg from various groups
  hi(
    {
      "LineNr", "CursorLineNr", "CursorLineSign", "CursorLineFold", "FoldColumn", "SignColumn",
      "Directory", "ModeMsg",
    },
    { bg = "NONE" }
  )
  for _, kind in ipairs(diagnostic_kinds) do
    hi("DiagnosticSign" .. kind, { bg = "NONE" })
  end

  hi_link("CursorLineFold", "FoldColumn", { default = true })
  hi_link("CursorLineSign", "SignColumn", { default = true })

  -- Generate diff hl
  if do_diff_gen then
    M.generate_diff_colors(diff_gen_opt)
  end

  -- Update feline theme
  if Config.plugin.feline then
    Config.plugin.feline.current_theme = feline_theme
  end

  -- FloatBorder
  hi("FloatBorder", {
    bg = hl.get_bg("NormalFloat") or "NONE",
    fg = hl.get_fg({ "FloatBorder", "Normal" }),
    explicit = true,
  })
  hi_link("LspInfoBorder", "FloatBorder")

  hi("MsgSeparator", { fg = hl.get_fg("FloatBorder"), bg = hl.get_bg("MsgArea"), link = -1 })

  hi("MatchParen", { style = "underline", sp = fg_normal:to_css() })

  -- Use special underlines if supported
  if M.supports_sp_underline() then
    M.apply_sp_underline()
  end

  -- Custom diff hl
  hi("DiffAddAsDelete", {
    bg = hl.get_bg("DiffDelete", true) or "#FF6C69",
    fg = hl.get_fg("DiffDelete", true) or "NONE",
    style = hl.get_style("DiffDelete", true) or "NONE",
  })
  hi_link("DiffDelete", "Comment")

  hi_link({ "GitSignsAddLn", "GitSignsAddPreview" }, "DiffInlineAdd", { clear = true })
  hi_link({ "GitSignsDeleteLn", "GitSignsDeletePreview" }, "DiffInlineDelete", { clear = true })
  hi_link("GitSignsChangeLn", "DiffInlineChange", { clear = true })
  hi_link("GitSignsDeleteVirtLn", "DiffInlineDelete", { clear = true })
  hi_link("GitSignsAdd", "diffAdded", { clear = true })
  hi_link("GitSignsDelete", "diffRemoved", { clear = true })
  hi_link("GitSignsChange", "diffChanged", { clear = true })
  hi("GitSignsAddInline", {
    fg = hl.get_bg("DiffInlineAdd"),
    bg = hl.get_fg("DiffInlineAdd")
  })
  hi("GitSignsDeleteInline", {
    fg = hl.get_bg("DiffInlineDelete"),
    bg = hl.get_fg("DiffInlineDelete")
  })
  hi("GitSignsChangeInline", {
    fg = hl.get_bg("DiffInlineChange"),
    bg = hl.get_fg("DiffInlineChange")
  })

  hi_link("NeogitCommitViewHeader", "Title")
  hi_link("NeogitDiffAddHighlight", "DiffInlineAdd")
  hi_link("NeogitDiffDeleteHighlight", "DiffInlineDelete")

  hi("BufferLineModified", { bg = hl.get_bg("BufferLineBuffer") })
  hi("BufferLineModifiedVisible", { bg = hl.get_bg("BufferLineBufferVisible") })

  for _, kind in ipairs({ "Error", "Warn", "Info", "Debug", "Trace" }) do
    local s = "Notify" .. kind:upper()
    hi_link({ s .. "Border", s .. "Icon", s .. "Title" }, "DiagnosticSign" .. kind)
  end

  hi_link("BqfSign", "DiagnosticSignInfo")

  hi("TroubleText", { bg = "NONE", fg = hl.get_fg("TroubleNormal") })

  hi("LspReferenceText", {
    bg = Color.from_hl("CursorLine", "bg"):highlight(0.08):to_css(),
    link = -1,
    explicit = true,
  })
  hi_link({ "LspReferenceRead", "LspReferenceWrite" }, "LspReferenceText", { clear = true })
  hi_link(
    { "IlluminatedWordText", "IlluminatedWordRead", "IlluminatedWordWrite" },
    "LspReferenceText",
    { clear = true }
  )

  hi_link("IndentBlanklineChar", "Whitespace", { clear = true })
  hi_link("IndentBlanklineSpaceChar", "Whitespace", { clear = true })

  -- Make breaking changes stand out more
  hi("packerBreakingChange", {
    fg = hl.get_fg("DiagnosticError"),
    sp = hl.get_fg("DiagnosticWarn"),
    style = "underline,bold",
  })

  -- Adjust ts-rainbow colors depending on brightness
  if bg_normal.lightness >= 0.5 then
    hi("TSRainbowRed", { fg = "#e05661" })
    hi("TSRainbowOrange", { fg = "#cc901f" })
    hi("TSRainbowYellow", { fg = "#cc641f" })
    hi("TSRainbowGreen", { fg = "#429e3b" })
    hi("TSRainbowCyan", { fg = "#118dc3" })
    hi("TSRainbowBlue", { fg = "#56b6c2" })
    hi("TSRainbowViolet", { fg = "#9a77cf" })
  else
    hi("TSRainbowRed", { fg = "#bf616a" })
    hi("TSRainbowOrange", { fg = "#d08770" })
    hi("TSRainbowYellow", { fg = "#ebcb8b" })
    hi("TSRainbowGreen", { fg = "#a3be8c" })
    hi("TSRainbowCyan", { fg = "#88c0d0" })
    hi("TSRainbowBlue", { fg = "#5e81ac" })
    hi("TSRainbowViolet", { fg = "#b48ead" })
  end

  hi("LirFloatCursorLine", {
    bg = Color.from_hl("NormalFloat", "bg"):highlight(0.06):to_css()
  })
  hi_link("LirFloatNormal", "NormalFloat", { force = true })
  hi_link("LirFolderIcon", "Directory", { default = true })
  hi_link("LirDir", "Directory")
  hi_link("DevIconLirFolderNode", "LirFolderIcon")
  hi_link("LirGitStatusIndex", "DiffviewStatusAdded")
  hi_link("LirGitStatusWorktree", "DiffviewStatusModified")
  hi_link("LirGitStatusUnmerged", "DiffviewStatusUnmerged")

  hi("BufferLineTabSelected", {
    bg = bg_normal:clone():highlight(0.1):to_css(),
    fg = hl.get_fg({ "Accent", "Title", "Normal" }),
    style = "bold",
  })
  hi("BufferLineIndicatorSelected", { fg = hl.get_fg({ "Accent", "Title", "Normal" }) })
  hi_link("BufferLineTabSeparatorSelected", "BufferLineTabSelected")

  hi({ "InclineNormal", "InclineNormalNC" }, {
    bg = bg_normal:clone():mod_value(-0.05):to_css(),
    fg = "NONE",
  })

  if Config.plugin.feline then
    Config.plugin.feline.reload()
  end
end

function M.apply()
  hi_link("LspReferenceText", "Visual", { default = true })
  hi_link({ "LspReferenceRead", "LspReferenceWrite" }, "LspReferenceText", { default = true })
  hi_link(
    { "IlluminatedWordText", "IlluminatedWordRead", "IlluminatedWordWrite" },
    "LspReferenceText",
    { default = true }
  )

  M.apply_log_defaults()

  -- NOTE: Seems like firenvim doesn't load colorscheme properly if loaded early.
  -- Load later in autocmd instead.
  if not vim.g.started_by_firenvim then
    if M.bg then
      vim.opt.bg = M.bg
    end
    vim.cmd("hi clear")
    vim.cmd("colorscheme " .. M.name)
  end
end

Config.colorscheme = M

return M
