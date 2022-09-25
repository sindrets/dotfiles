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
local DEFAULT_COLORSCHEME = "oxocarbon-lua dark"

local Color = Config.common.color.Color
local utils = Config.common.utils
local hl = Config.common.hl
local hi, hi_link, hi_clear = hl.hi, hl.hi_link, hl.hi_clear

local M = {}

M.DEFAULT_DARK = "oxocarbon-lua"
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
      hi("Spell" .. name, { style = "undercurl", sp = fg, fg = "NONE" })
    end
  end

  -- Normalize diagnostic underlines
  local diagnostic_names = { "Error", "Warn", "Info", "Hint" }
  for _, name in ipairs(diagnostic_names) do
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
        fg = data.fg and Color.from_hex(data.fg) or default_fg,
        bg = data.bg and Color.from_hex(data.bg) or default_bg,
      }
    end
  end

  -- Generate dimmed color variants

  local first, last = 1, 9

  for i = first, last do
    local f = (i - first + 1) / (last - first + 2)
    local v = math.floor(f * 1000)

    for group, values in pairs(groups) do
      hi(group .. "Dim" .. v, { fg = values.fg:clone():blend(values.bg, f):to_css() })
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
    opt.no_derive = { all = true }
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

  ---@type Color
  local base_add = base_colors.add
  ---@type Color
  local base_del = base_colors.del
  ---@type Color
  local base_mod = base_colors.mod

  local bg_add = base_add:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_add_text = base_add:blend(bg_normal, 0.7):mod_saturation(0.05)
  local bg_del = base_del:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_del_text = base_del:blend(bg_normal, 0.7):mod_saturation(0.05)
  local bg_mod = base_mod:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_mod_text = base_mod:blend(bg_normal, 0.7):mod_saturation(0.05)

  if not opt.no_override then
    hi("DiffAdd", { bg = bg_add:to_css(), fg = "NONE", style = "NONE" })
    hi("DiffDelete", { bg = bg_del:to_css(), fg = "NONE", style = "NONE" })
    hi("DiffChange", { bg = bg_mod:to_css(), fg = "NONE", style = "NONE" })
    hi("DiffText", { bg = bg_mod_text:to_css(), fg = "NONE", style = "NONE" })

    hi("diffAdded", { fg = base_add:to_css(), bg = "NONE", style = "NONE" })
    hi("diffRemoved", { fg = base_del:to_css(), bg = "NONE", style = "NONE" })
    hi("diffChanged", { fg = base_mod:to_css(), bg = "NONE", style = "NONE" })
  end

  hi("DiffAddText", { bg = bg_add_text:to_css(), fg = "NONE", style = "NONE" })
  hi("DiffDeleteText", { bg = bg_del_text:to_css(), fg = "NONE", style = "NONE" })

  hi("DiffInlineAdd", { bg = bg_add:to_css(), fg = base_add:to_css(), style = "NONE" })
  hi("DiffInlineDelete", { bg = bg_del:to_css(), fg = base_del:to_css(), style = "NONE" })
  hi("DiffInlineChange", { bg = bg_mod:to_css(), fg = base_mod:to_css(), style = "NONE" })
end

---Give Telescope its default appearance.
function M.unstyle_telescope()
  hi_link("TelescopeNormal", "NormalFloat")
  hi_link("TelescopeBorder", "FloatBorder")
  hi_link("TelescopePromptNormal", "TelescopeNormal")
  hi_link("TelescopePromptBorder", "TelescopeBorder")
  hi_link({ "TelescopePromptTitle", "TelescopePreviewTitle", "TelescopeResultsTitle" }, "TelescopeNormal")
  hi("TelescopePromptPrefix", { bg = "NONE" })
end

function M.apply_log_defaults()
  hi_link("logLevelTrace", "DiagnosticHint")
  hi_link({ "logLevelInfo", "logLevelNotice" }, "DiagnosticInfo")
  hi_link({ "logLevelWarning", "logLevelDebug", "logLevelAlert" }, "DiagnosticWarn")
  hi_link({ "logLevelError", "logLevelCritical", "logLevelEmergency" }, "DiagnosticError")
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
  local primary = Color.from_hl({ "Function", "Title", "Normal" }, "fg") --[[@as Color ]]
  local accent = Color.from_hl({ "TSFuncBuiltin", "Statement", "Normal" }, "fg") --[[@as Color ]]

  hi_clear({ "Cursor", "TermCursor" })
  hi("TermCursor", { style = "reverse" })
  hi("NonText", { style = "nocombine" })
  hi("Hidden", { fg = "bg", bg = "bg" })
  hi("CursorLine", { sp = fg_normal:to_css() })
  hi("Primary", { fg = primary:to_css() })
  hi("Accent", { fg = accent:to_css() })

  -- Explicitly redefine Normal to circumvent bug in upstream 0.7.0.
  -- TODO: Remove once 0.8.0 becomes stable.
  -- @see [Neovim issue](https://github.com/neovim/neovim/issues/18024)
  hi("Normal", { fg = fg_normal:to_css(), bg = bg_normal:to_css() })

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
    hi_link("TSComment", "Comment")
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
    M.apply_log_defaults()

    -- Remove bg for diagnostics.
    for _, name in ipairs({ "Error", "Warn", "Info", "Hint" }) do
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
      hi_link("NormalFloat", "Normal")
      hi_link("TSMath", "Function")

      vim.g.terminal_color_0 = "#E2E2E2"
      vim.g.terminal_color_8 = "#BFBABB"
      vim.g.terminal_color_1 = "#DC5284"
      vim.g.terminal_color_9 = "#BE3C6D"
      vim.g.terminal_color_2  = "#628562"
      vim.g.terminal_color1_0 = "#487249"
      vim.g.terminal_color_3  = "#C48562"
      vim.g.terminal_color1_1 = "#A76B48"
      vim.g.terminal_color_4  = "#0084A3"
      vim.g.terminal_color1_2 = "#006F89"
      vim.g.terminal_color_5  = "#896788"
      vim.g.terminal_color1_3 = "#7F4C7E"
      vim.g.terminal_color_6  = "#008586"
      vim.g.terminal_color1_4 = "#006F70"
      vim.g.terminal_color_7  = "#555555"
      vim.g.terminal_color1_5 = "#777777"
    end

  elseif colors_name:match("^github_") then
    hi_link("NonText", "Whitespace")
    hi_link({ "FoldColumn", "markdownCode", "markdownCodeBlock" }, "String")
    hi("Substitute", { fg = "#dddddd" })
    hi("StatusLine", {
      bg = bg_normal:clone():highlight(0.12):to_css(),
      fg = hl.get_fg("String"),
    })
    hi("NeogitDiffContextHighlight", { bg = bg_normal:clone():highlight(0.075):to_css() })
    hi_link("DashboardHeader", "Identifier")
    hi_link("DashboardCenter", "Keyword")
    -- hi_link("DashboardShortCut", "String")
    hl.hi("DashboardShortCut", { fg = hl.get_fg("String"), style = "bold,reverse" })
    hi_link("DashboardFooter", "Comment")
    hi_link("DiffviewFolderName", "Special")
    diff_gen_opt = { no_derive = { mod = true } }
    feline_theme = "simple"
    M.apply_terminal_defaults()

  elseif colors_name == "kanagawa" then
    hi("VertSplit", { bg = "NONE", fg = "#0f0f0f" })
    hi("diffChanged", { fg = "#7E9CD8" })
    hi("Whitespace", { fg = bg_normal:clone():highlight(0.18):to_css() })
    hi("BufferLineIndicatorSelected", { fg = "#7E9CD8" })

  elseif colors_name == "oxocarbon-lua" then
    if bg == "dark" then
      hi("Primary", { fg = hl.get_fg("Boolean") })
      hi("Accent", { fg = hl.get_fg("TSProperty") })
      hi_link("NormalNC", "Normal")
      hi("StatusLine", {
        bg = bg_normal:clone():highlight(0.05):to_css(),
        fg = fg_normal:clone():mod_value(-0.2):to_css()
      })
      hi({ "FloatBorder", "WinSeparator" }, { fg = bg_normal:clone():highlight(0.3):to_css() })
      hi("Visual", { bg = Color.from_hl("Type", "fg"):blend(bg_normal, 0.8):mod_hue(25):to_css() })
      hi("Search", { bg = hl.get_fg("String"), style = "bold" })
      hi("Title", { style = "bold" })
      hi("Error", { fg = hl.get_fg("TSProperty"), explicit = true })
      hi("DiagnosticInfo", { fg = hl.get_fg("Boolean") })
      hi("DiagnosticHint", { fg = hl.get_fg("String") })
      hi("FoldColumn", { fg = Color.from_hl("Number", "fg"):blend(bg_normal, 0.2):to_css() })
      hi("BufferLineIndicatorSelected", { fg = hl.get_fg("ErrorMsg") })
      hi({ "BufferLineModified", "BufferLineModifiedVisible", "BufferLineModifiedSelected" }, {
        fg = hl.get_fg("Boolean"),
      })
      hi({ "markdown_inlineTSLiteral", "TSLiteral" }, { fg = hl.get_fg("WinSeparator") })
      hi_link("DiffviewFilePanelConflicts", "String")
      hi_link("TSMath", "Function")
      hi("TelescopeMatching", { fg = hl.get_fg("String"), style = "bold" })
      hi_link({ "fugitiveHash", "gitHash" }, "String")
    end

    M.unstyle_telescope()

  end

  M.generate_base_colors()

  -- Treesitter
  hi("TSEmphasis", { style = "italic" })
  hi("TreesitterContext", { bg = bg_normal:clone():highlight(0.08):to_css() })
  hi_link("@neorg.markup.verbatim", "@text.literal")

  hi("@neorg.tags.ranged_verbatim.code_block", {
    bg = bg_normal:clone()
      :mod_value(-0.03)
      :to_css(),
  })

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
  })
  hi_link("LspInfoBorder", "FloatBorder")

  hi("MsgSeparator", { fg = hl.get_fg("FloatBorder"), bg = hl.get_bg("MsgArea") })

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

  hi_link({ "GitSignsAddLn", "GitSignsAddPreview" }, "DiffInlineAdd")
  hi_link({ "GitSignsDeleteLn", "GitSignsDeletePreview" }, "DiffInlineDelete")
  hi_link("GitSignsChangeLn", "DiffInlineChange")
  hi_link("GitSignsDeleteVirtLn", "DiffInlineDelete")
  hi_link("GitSignsAdd", "diffAdded")
  hi_link("GitSignsDelete", "diffRemoved")
  hi_link("GitSignsChange", "diffChanged")

  hi_link("NeogitCommitViewHeader", "Title")
  hi_link("NeogitDiffAddHighlight", "DiffInlineAdd")
  hi_link("NeogitDiffDeleteHighlight", "DiffInlineDelete")

  for _, kind in ipairs({ "Error", "Warn", "Info", "Debug", "Trace" }) do
    local s = "Notify" .. kind:upper()
    hi_link({ s .. "Border", s .. "Icon", s .. "Title" }, "DiagnosticSign" .. kind)
  end

  hi_link("BqfSign", "DiagnosticSignInfo")

  hi("TroubleText", { bg = "NONE", fg = hl.get_fg("TroubleNormal") })

  hi("LspReferenceText", {
    bg = Color.from_hl("CursorLine", "bg"):highlight(0.08):to_css(),
    unlink = true,
    explicit = true,
  })
  hi_link({ "LspReferenceRead", "LspReferenceWrite" }, "LspReferenceText", { clear = true })
  hi_link(
    { "IlluminatedWordText", "IlluminatedWordRead", "IlluminatedWordWrite" },
    "LspReferenceText",
    { clear = true }
  )

  hi_link("IndentBlanklineChar", "Whitespace")
  hi_link("IndentBlanklineSpaceChar", "Whitespace")

  -- Adjust ts-rainbow colors for light color schemes
  if bg_normal.lightness >= 0.5 then
    hi("rainbowcol1", { fg = "#e05661" })
    hi("rainbowcol2", { fg = "#cc901f" })
    hi("rainbowcol3", { fg = "#cc641f" })
    hi("rainbowcol4", { fg = "#429e3b" })
    hi("rainbowcol5", { fg = "#118dc3" })
    hi("rainbowcol6", { fg = "#56b6c2" })
    hi("rainbowcol7", { fg = "#9a77cf" })
  end

  hl.hi("LirFloatCursorLine", {
    bg = Color.from_hl("NormalFloat", "bg"):highlight(0.06):to_css()
  })
  hl.hi_link("LirFloatNormal", "NormalFloat", { force = true })
  hl.hi_link("LirFolderIcon", "Directory", { default = true })
  hl.hi_link("DevIconLirFolderNode", "LirFolderIcon")

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

hi_link("LspReferenceText", "Visual", { default = true })
hi_link({ "LspReferenceRead", "LspReferenceWrite" }, "LspReferenceText", { default = true })
hi_link(
  { "IlluminatedWordText", "IlluminatedWordRead", "IlluminatedWordWrite" },
  "LspReferenceText",
  { default = true }
)

M.apply_log_defaults()

Config.common.au.declare_group("colorscheme_config", {}, {
  { "ColorSchemePre", callback = function(state) M.setup_colorscheme(state.match) end, },
  { "ColorScheme", callback = function(_) M.apply_tweaks() end, },
})

Config.colorscheme = M

-- NOTE: Seems like firenvim doesn't load colorscheme properly if loaded early.
-- Load later in autocmd instead.
if not vim.g.started_by_firenvim then
  if M.bg then
    vim.opt.bg = M.bg
  end
  vim.cmd("colorscheme " .. M.name)
end

return M
