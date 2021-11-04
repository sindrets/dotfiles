return function ()
  local utils = require('nvim-config.utils')
  local hl = require("nvim-config.hl")
  local gl = require('galaxyline')
  local condition = require('galaxyline.condition')
  local gls = gl.section

  gl.short_line_list = {
    'NvimTree',
    'vista',
    'dbui',
    'packer',
    'fugitiveblame',
    'LspTrouble',
    'DiffviewFiles',
    'DiffviewFileHistoryPanel',
    'DiffviewFHOptionPanel',
    'Outline',
    'dashboard',
    'NeogitStatus',
  }

  local colors
  local fg = hl.get_fg("StatusLine")
  local bg = hl.get_bg("StatusLine")

  if hl.get_hl_attr("StatusLine", "reverse") == "1" then
    fg, bg = bg, fg
  end

  fg = fg or hl.get_fg("Normal")
  bg = bg or hl.get_bg("Normal")

  hl.hi("StatusLine", { fg = fg, bg = bg, gui = "NONE" })
  hl.hi("StatusLineNC", { fg = fg, bg = bg, gui = "NONE" })
  hl.hi_link("StatusLineNC")

  if vim.o.background == "light" then
    colors = {
      fg = fg,
      bg = bg,
      yellow = '#ECBE7B',
      cyan = '#008080',
      darkblue = '#081633',
      green = '#7f9f54',
      orange = '#FF8800',
      violet = '#958ec7',
      magenta = '#c678dd',
      blue = '#4596cd',
      red = '#ec5f67',
    }
  else
    colors = {
      fg = fg,
      bg = bg,
      yellow = '#ECBE7B',
      cyan = '#008080',
      darkblue = '#081633',
      green = '#98be65',
      orange = '#FF8800',
      violet = '#a9a1e1',
      magenta = '#c678dd',
      blue = '#51afef',
      red = '#ec5f67',
    }
  end

  local function mode_color()
    local mode_colors = {
      n = colors.blue,
      no = colors.blue,
      nov = colors.blue,
      noV = colors.blue,
      ['no'] = colors.blue,
      niI = colors.blue,
      niR = colors.blue,
      niV = colors.blue,
      v = colors.magenta,
      V = colors.magenta,
      [''] = colors.magenta,
      s = colors.magenta,
      S = colors.magenta,
      [''] = colors.magenta,
      i = colors.green,
      ic = colors.green,
      ix = colors.green,
      R = colors.red,
      Rc = colors.red,
      Rv = colors.red,
      Rx = colors.red,
      c = colors.orange,
      cv = colors.orange,
      ce = colors.orange,
      r = colors.cyan,
      rm = colors.cyan,
      ['r?'] = colors.cyan,
      ['!'] = colors.cyan,
      t = colors.orange,
    }

    return mode_colors[vim.fn.mode()]
  end

  local function use_provider(name)
    local ok, provider = pcall(require, "galaxyline.providers." .. name)
    if ok then
      return provider
    end
    return require("galaxyline.provider_" .. name)
  end

  local function filler_section(size)
    return {
      FillerSection = {
        provider = function ()
          local result = ""
          while #result < size do
            result = result .. " "
          end
          return result
        end,
        highlight = { "NONE", colors.bg }
      }
    }
  end

  local function width_condition(min_width)
    return function()
      return vim.api.nvim_win_get_width(0) > min_width
    end
  end

  _G.UpdateGalaxyline = function()
    require("nvim-config.plugins.galaxyline")()
    gl.load_galaxyline()
  end

  _G.ReloadGalaxyline = function()
    gl.load_galaxyline()
  end

  vim.api.nvim_exec([[
    augroup galaxyline_config
      au!
      au ColorScheme * lua UpdateGalaxyline()
    augroup END
  ]], false)

  -- RESET
  gls.left = {}
  gls.mid = {}
  gls.right = {}
  gls.short_line_left = {}
  gls.short_line_right = {}

  -- LEFT
  gls.left = {
    {
      RainbowRed = {
        provider = function() return '▊ ' end,
        highlight = { colors.blue, colors.bg }
      },
    },
    {
      ViMode = {
        provider = function()
          local alias = {
            n = 'NORMAL',
            no = 'NORMAL',
            nov = 'NORMAL',
            noV = 'NORMAL',
            ['no'] = 'NORMAL',
            niI = 'NORMAL',
            niR = 'NORMAL',
            niV = 'NORMAL',
            v = 'VISUAL',
            V = 'VISUAL LINE',
            [''] = 'VISUAL BLOCK',
            s = 'SELECT',
            S = 'SELECT LINE',
            [''] = 'SELECT BLOCK',
            i = 'INSERT',
            ic = 'COMPLETION',
            ix = 'COMPLETION',
            R = 'REPLACE',
            Rc = 'REPLACE',
            Rv = 'REPLACE',
            Rx = 'REPLACE',
            c = 'COMMAND',
            cv = 'EX',
            ce = 'NORMAL EX',
            r = 'PROMPT',
            rm = 'PROMPT',
            ['r?'] = 'CONFIRM',
            ['!'] = 'SHELL',
            t = 'TERMINAL'
          }
          vim.cmd('hi GalaxyViMode guifg=' .. mode_color())
          return alias[vim.fn.mode()]..' '
        end,
        highlight = { colors.red, colors.bg, 'bold' },
      },
    },
    {
      FileIcon = {
        provider = 'FileIcon',
        condition = condition.buffer_not_empty,
        highlight = { use_provider("fileinfo").get_file_icon_color, colors.bg },
      },
    },
    {
      FileName = {
        provider = 'FileName',
        condition = condition.buffer_not_empty,
        highlight = { colors.magenta, colors.bg, 'bold' }
      }
    },
    {
      DiffAdd = {
        provider = 'DiffAdd',
        condition = condition.hide_in_width,
        icon = ' ',
        separator = '',
        highlight = { colors.green, colors.bg },
      }
    },
    {
      DiffModified = {
        provider = 'DiffModified',
        condition = condition.hide_in_width,
        icon = ' ',
        separator = '',
        highlight = { colors.blue, colors.bg },
      }
    },
    {
      DiffRemove = {
        provider = 'DiffRemove',
        condition = condition.hide_in_width,
        icon = ' ',
        separator = '',
        highlight = { colors.red, colors.bg },
      }
    },
  }

  -- MID
  gls.mid = { filler_section(1) }

  -- RIGHT
  gls.right = {
    {
      DiagnosticError = {
        provider = 'DiagnosticError',
        icon = '  ',
        highlight = { colors.red, colors.bg, 'bold' }
      }
    },
    {
      DiagnosticWarn = {
        provider = 'DiagnosticWarn',
        icon = '  ',
        highlight = { colors.yellow, colors.bg, 'bold' },
      }
    },
    {
      DiagnosticHint = {
        provider = 'DiagnosticHint',
        icon = '  ',
        highlight = { colors.cyan, colors.bg, 'bold' },
      }
    },
    {
      DiagnosticInfo = {
        provider = 'DiagnosticInfo',
        icon = '  ',
        highlight = { colors.blue, colors.bg, 'bold' },
      }
    },
    {
      LineInfo = {
        provider = function ()
          local line = tostring(vim.fn.line("."))
          if #line % 2 ~= 0 then
            line = utils.str_left_pad(line, #line + (2 - #line % 2))
          end

          local col = tostring(vim.fn.col("."))
          if #col % 2 ~= 0 then
            col = utils.str_right_pad(col, #col + (2 - #col % 2))
          end

          local result = line .. ":" .. col
          if #result % 4 ~= 0 then
            result = utils.str_center_pad(result, #result + (4 - #result % 4))
          end

          return result
        end,
        separator = ' ',
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.fg, colors.bg },
      },
    },
    {
      Percent = {
        provider = function ()
          local current_line = vim.fn.line('.')
          local total_line = vim.fn.line('$')
          local result,_ = math.modf((current_line/total_line)*100)
          return ' '.. result .. '% '
        end,
        separator = ' ',
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.fg, colors.bg, 'bold' },
      }
    },
    {
      NumLines = {
        provider = function ()
          return '  '.. vim.fn.line("$")
        end,
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.fg, colors.bg },
      }
    },
    {
      LspClient = {
        provider = function()
          if #vim.tbl_keys(vim.lsp.buf_get_clients(0)) > 0 then
            return vim.bo.filetype
          end
        end,
        condition = function ()
          local exclude = { [''] = true }
          if exclude[vim.bo.filetype] then
            return false
          end
          return vim.fn.winwidth(0) > 120 and #vim.tbl_keys(vim.lsp.buf_get_clients(0)) > 0
        end,
        icon = ' ',
        separator = "  ",
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.red, colors.bg, 'bold' }
      }
    },
    {
      IndentInfo = {
        provider = function ()
          if vim.bo.expandtab then
            return "SPACES " .. vim.bo.shiftwidth
          else
            return "TABS " .. vim.bo.tabstop
          end
        end,
        condition = width_condition(100),
        icon = " ",
        separator = "  ",
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.cyan, colors.bg, 'bold' },
      },
    },
    {
      FileFormat = {
        provider = function ()
          local format = vim.bo.fileformat
          local enc = vim.bo.fileencoding
          enc = (enc ~= "" and enc or format):upper()
          if format == "unix" then
            return " " .. enc
          elseif format == "dos" then
            return " " .. enc
          elseif format == "mac" then
            return " " .. enc
          end
          return format:upper()
        end,
        condition = width_condition(80),
        separator = "  ",
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.green, colors.bg, 'bold' }
      }
    },
    {
      GitIcon = {
        provider = function() return '  ' end,
        condition = condition.check_git_workspace,
        separator = ' ',
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.violet, colors.bg, 'bold' },
      }
    },
    {
      GitBranch = {
        provider = "GitBranch",
        condition = condition.check_git_workspace,
        highlight = { colors.violet, colors.bg, 'bold' },
      }
    },
    filler_section(3)
  }

  -- SHORT LINE LEFT
  gls.short_line_left = {
    {
      RainbowRed = {
        provider = function() return '▊ ' end,
        highlight = { colors.blue, colors.bg }
      },
    },
    {
      BufferType = {
        provider = 'FileTypeName',
        separator = ' ',
        separator_highlight = { 'NONE', colors.bg },
        highlight = { colors.blue, colors.bg, 'bold' }
      }
    },
    {
      SFileName = {
        provider =  'SFileName',
        condition = condition.buffer_not_empty,
        highlight = { colors.fg, colors.bg, 'bold' }
      }
    },
  }

  -- SHORT LINE RIGHT
  gls.short_line_right = {
    {
      BufferIcon = {
        provider= 'BufferIcon',
        highlight = { colors.fg, colors.bg }
      }
    },
  }
end
