local Color = Config.common.color.Color
local utils = Config.common.utils
local hl = Config.common.hl
local api = vim.api
local hi, hi_link = hl.hi, hl.hi_link

local colorscheme = "palenight"
vim.opt.bg = "dark"

vim.g.ayucolor = "dark"
vim.g.gruvbox_italic = 1
vim.g.gruvbox_contrast_dark = "medium"
vim.g.gruvbox_invert_selection = 0
vim.g.gruvbox_material_background = 'medium'
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_diagnostic_line_highlight = 1
vim.g.base16colorspace = 256
vim.g.seoul256_background = 234
vim.g.palenight_terminal_italics = 1
vim.g.neodark = '#202020'
vim.g.neodark = 0
vim.g.neodark = 1
vim.g.spacegray_use_italics = 1
vim.g.spacegray_low_contrast = 1
vim.g.rose_pine_variant = "moon"
vim.g.rose_pine_enable_italics = true
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

require("nvim-config.plugins.material")()

do
  hi("NonText", { gui = "nocombine" })
  hi_link("LspReferenceText", "Visual", { default = true })
  hi_link("LspReferenceRead", "Visual", { default = true })
  hi_link("LspReferenceWrite", "Visual", { default = true })
  hi_link("illuminateWord", "LspReferenceText", { default = true })
  hi_link("illuminateCurWord", "illuminateWord", { default = true })

  api.nvim_exec([[
    augroup colorscheme_config
      au!
      au ColorScheme * call v:lua.Config.colorscheme.apply_tweaks()
    augroup END
  ]], false)
end

local M = {}

function M.apply_terminal_defaults()
   -- black
  vim.g.terminal_color_0  = "#222222"
  vim.g.terminal_color_8  = "#666666"
   -- red
  vim.g.terminal_color_1  = "#e84f4f"
  vim.g.terminal_color_9  = "#d23d3d"
   -- green
  vim.g.terminal_color_2  = "#b7ce42"
  vim.g.terminal_color_10 = "#bde077"
   -- yellow
  vim.g.terminal_color_3  = "#fea63c"
  vim.g.terminal_color_11 = "#ffe863"
   -- blue
  vim.g.terminal_color_4  = "#66a9b9"
  vim.g.terminal_color_12 = "#aaccbb"
   -- magenta
  vim.g.terminal_color_5  = "#b7416e"
  vim.g.terminal_color_13 = "#e16a98"
   -- cyan
  vim.g.terminal_color_6  = "#6dc1b6"
  vim.g.terminal_color_14 = "#42717b"
   -- white
  vim.g.terminal_color_7  = "#cccccc"
  vim.g.terminal_color_15 = "#ffffff"
end

function M.generate_diff_colors()
  local bg = vim.o.bg
  local hl_bg_normal = hl.get_bg("Normal") or (bg == "dark" and "#111111" or "#eeeeee")

  local bg_normal = Color.from_hex(hl_bg_normal)

  local base_add = Color.from_hex(hl.get_fg("diffAdded") or "#b7ce42")
  local base_del = Color.from_hex(hl.get_fg("diffRemoved") or "#e84f4f")
  local base_mod = Color.from_hex(hl.get_fg("diffChanged") or "#51afef")

  local bg_add = base_add:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_del = base_del:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_mod = base_mod:blend(bg_normal, 0.85):mod_saturation(0.05)
  local bg_mod_text = base_mod:blend(bg_normal, 0.7):mod_saturation(0.05)

  hi("DiffAdd", { bg = bg_add:to_css(), fg = "NONE", gui = "NONE" })
  hi("DiffDelete", { bg = bg_del:to_css(), fg = "NONE", gui = "NONE" })
  hi("DiffChange", { bg = bg_mod:to_css(), fg = "NONE", gui = "NONE" })
  hi("DiffText", { bg = bg_mod_text:to_css(), fg = "NONE", gui = "NONE" })
end

function M.apply_tweaks()
  if not vim.g.colors_name then
    utils.warn("'g:colors_name' is not defined!")
    vim.g.colors_name = "UNKNOWN"
  end

  colorscheme = vim.g.colors_name
  local bg = vim.o.bg

  if colorscheme == "codedark" then
    hi("NonText", { bg = "NONE", })
    M.generate_diff_colors()

  elseif colorscheme == "tender" then
    hi("Visual", { gui = "NONE", bg = "#293b44", })
    hi("VertSplit", { fg = "#202020", bg = "NONE", })
    hi("Search", { gui = "bold", fg = "#dddddd", bg = "#7a6a24", })
    M.generate_diff_colors()

  elseif colorscheme == "horizon" then
    hi("NonText", { fg = "#414559", bg = "NONE", })
    hi("VertSplit", { gui = "bold", fg = "#0f1117", bg = "NONE", })
    hi("Pmenu", { bg = "#272c42", fg = "#eff0f4", })
    hi("PmenuSel", { bg = "#5b6389", })
    hi("PmenuSbar", { bg = "#3d425b", })
    hi("PmenuThumb", { bg = "#0f1117", })
    hi("CursorLineNr", { gui = "bold", fg = "#09f7a0", bg = "NONE", })
    hi("QuickFixLine", { bg = "#335172", fg = "NONE", })
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")
    hi_link("jsonQuote")
    M.generate_diff_colors()

  elseif colorscheme == "monokai_pro" then
    hi("NonText", { fg = "#5b595c", bg = "None", })
    hi("VertSplit", { fg = "#696769", bg = "None", })
    hi("Pmenu", { fg = "#a9dc76", bg = "#252226", })
    hi("PmenuSel", { bg = "#403e41", })
    hi("PmenuSbar", { bg = "Grey", })
    hi("PmenuThumb", { bg = "White", })
    hi("CursorLineNr", { gui = "bold", fg = "Yellow", bg = "#423f42", })
    hi("SignColumn", { bg = "#423f42", })
    hi("FoldColumn", { fg = "Cyan", bg = "#423f42", })
    hi("QuickFixLine", { bg = "#714754", fg = "NONE", })
    hi("Search", { fg = "#ffd866", gui = "bold,underline", })
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")
    hi_link("jsonQuote")
    M.generate_diff_colors()

  elseif colorscheme == "gruvbox-material" then
    hi("CursorLineNr", { gui = "bold", fg = "#a9b665", })
    M.generate_diff_colors()

  elseif colorscheme == "predawn" then
    hi("NonText", { fg = "#3c3c3c", bg = "None", })
    hi("CursorLine", { bg = "#303030", })
    hi("SignColumn", { fg = "#8c8c8c", bg = "#3c3c3c", })
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")
    hi_link("jsonQuote")
    hi("GitGutterAdd", { fg = "#46830d", bg = "None", })
    hi("GitGutterChange", { fg = "#243958", bg = "None", })
    hi("GitGutterDelete", { fg = "#8b0808", bg = "None", })

  elseif colorscheme == "nvcode" then
    hi("CocExplorerGitIgnored", { fg = "#5C6370", })
    hi_link("GitGutterAdd", "diffAdded")
    hi_link("GitGutterRemoved", "diffRemoved")
    hi_link("GitGutterChange", "diffChanged")
    hi_link("vimVar")
    hi_link("vimFuncVar")
    hi_link("vimUserFunc")

  elseif colorscheme == "zephyr" then
    hi("Visual", { fg = "NONE", bg = "#393e49", })

  elseif colorscheme == "tokyonight" then
    hi_link("ColorColumn", "CursorLine")
    if bg == "dark" then
      hi("DiffAdd", { bg = "#283B4D", fg = "NONE", })
      hi("DiffChange", { bg = "#28304d", fg = "NONE", })
      hi("DiffText", { bg = "#36426b", fg = "NONE", })
    end
    hi_link("GitsignsAdd", "String")
    -- hi_link("DiffviewNormal", "NormalSB")

  elseif colorscheme == "everforest" then
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
      hi("CursorLineNr", { gui = "bold", bg = "NONE", fg = "#8da101", })
      hi("DiffAdd", { bg = "#EBF4BF", fg = "NONE", })
      hi("DiffDelete", { bg = "#FCDDCC", fg = "NONE", })
      hi("DiffChange", { bg = "#E3ECE4", fg = "NONE", })
      hi("DiffText", { bg = "#BEDFE6", fg = "NONE", })
    else
      hi("CursorLineNr", { gui = "bold", bg = "NONE", fg = "#a7c080", })
      -- hi("DiffText", { bg = "#4a6778", fg = "NONE", })
      M.generate_diff_colors()
    end

  elseif colorscheme == "palenight" then
    local bg_normal = Color.from_hl("Normal", "bg")
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
    hi("NvimTreeRootFolder", { fg = "#C3E88D", gui = "bold", })
    hi("NvimTreeFolderIcon", { fg = "#F78C6C", })
    hi("NvimTreeNormal", { bg = "#222533", })
    hi("NvimTreeCursorLine", { bg = "#33374c", })
    hi("NvimTreeGitDirty", { fg = "#ffcb6b", })

  elseif colorscheme == "onedarkpro" then
    if bg == "dark" then
      hi("Cursor", { bg = "#61afef", })
      hi("Identifier", { fg = "#c678dd", })
      hi("TabLineSel", { fg = "#61afef", bg = "NONE", })
      hi("Whitespace", { fg = "#303030", })
      hi("NonText", { fg = "#303030", })
      hi("IndentBlanklineContextChar", { fg = "#61afef", })
      hi("CursorLine", { bg = "#252525", })
      hi("FoldColumn", { bg = "#1e1e1e", fg = "#61afef", })
      hi("StatusLine", { bg = "#2e2e2e", })
      hi("LspReferenceText", { bg = "#2e2e2e", })
      hi("NvimTreeOpenedFolderName", { fg = "#61afef", gui = "italic,bold", })
      hi("NvimTreeRootFolder", { fg = "#98c379", })
      hi("NvimTreeGitDirty", { fg = "#e5c07b", })
      hi("NvimTreeGitStaged", { fg = "#98c379", })
      hi("TelescopeSelection", { fg = "#c678dd", bg = "#2e2e2e", })
      hi_link("TelescopeBorder", "Directory")
      M.generate_diff_colors()
    end

  elseif colorscheme == "doom-one" then
    if bg == "dark" then
      hi("diffAdded", { bg = "#3E493D", fg = "#97BE65", })
      hi("diffRemoved", { bg = "#4F343A", fg = "#FF6C69", })
      hi("diffChanged", { fg = "#51afef", })
      hi("GitSignsChange", { fg = "#51afef", })
      hi("TermCursor", { fg = "NONE", })
      hi_link("TermCursor")
      hi("NvimTreeRootFolder", { gui = "bold", })
      hi("SpellCap", { sp = "#51afef", })
      hi("SpellBad", { sp = "#FF6C69", })
      hi("SpellRare", { sp = "#a9a1e1", })
      hi("SpellLocal", { sp = "#da8548", })
      M.generate_diff_colors()
      vim.opt.pumblend = 0
    end
  end

  -- FloatBorder
  hi("FloatBorder", {
    bg = hl.get_bg("NormalFloat") or "NONE",
    fg = hl.get_fg("FloatBorder") or "white",
  })

  -- Custom diff hl
  hi("DiffAddAsDelete", {
    bg = hl.get_bg("DiffDelete", false) or "red",
    fg = hl.get_fg("DiffDelete", false) or "NONE",
    gui = hl.get_gui("DiffDelete", false) or "NONE"
  })
  hi_link("DiffDelete", "Comment")
end

Config.colorscheme = M

vim.cmd("colorscheme " .. colorscheme)
return M
