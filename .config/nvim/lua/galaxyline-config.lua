local utils = require('nvim-utils')
local gl = require('galaxyline')
local condition = require('galaxyline.condition')
local gls = gl.section
local cur_section
gl.short_line_list = {'NvimTree','vista','dbui','packer'}

local colors = {
  bg = '#1c1e23',
  fg = '#bbc2cf',
  yellow = '#ECBE7B',
  cyan = '#008080',
  darkblue = '#081633',
  green = '#98be65',
  orange = '#FF8800',
  violet = '#a9a1e1',
  magenta = '#c678dd',
  blue = '#51afef';
  red = '#ec5f67';
}

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
      highlight = {"NONE", colors.bg}
    }
  }
end

-- LEFT

cur_section = gls.left

table.insert(cur_section, {
  RainbowRed = {
    provider = function() return '▊ ' end,
    highlight = {colors.blue,colors.bg}
  },
})

table.insert(cur_section, {
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
      vim.api.nvim_command('hi GalaxyViMode guifg='..mode_color())
      return alias[vim.fn.mode()]..' '
    end,
    highlight = {colors.red,colors.bg,'bold'},
  },
})

table.insert(cur_section, {
  FileSize = {
    provider = 'FileSize',
    condition = condition.buffer_not_empty,
    highlight = {colors.fg,colors.bg}
  }
})

table.insert(cur_section, {
  FileIcon = {
    provider = 'FileIcon',
    condition = condition.buffer_not_empty,
    highlight = {require('galaxyline.provider_fileinfo').get_file_icon_color,colors.bg},
  },
})

table.insert(cur_section, {
  FileName = {
    provider = 'FileName',
    condition = condition.buffer_not_empty,
    highlight = {colors.magenta,colors.bg,'bold'}
  }
})

table.insert(cur_section, {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = condition.hide_in_width,
    icon = 'ﰂ ',
    separator = '',
    highlight = {colors.green,colors.bg},
  }
})
table.insert(cur_section, {
  DiffModified = {
    provider = 'DiffModified',
    condition = condition.hide_in_width,
    icon = ' ',
    separator = '',
    highlight = {colors.blue, colors.bg},
  }
})

table.insert(cur_section, {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = condition.hide_in_width,
    icon = 'ﯰ ',
    separator = '',
    highlight = {colors.red,colors.bg},
  }
})

-- MID

cur_section = gls.mid

table.insert(cur_section, {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = function ()
      local tbl = {['dashboard'] = true,['']=true}
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    icon = ' LSP:',
    highlight = {colors.cyan,colors.bg,'bold'}
  }
})

-- RIGHT

cur_section = gls.right

table.insert(cur_section, {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red,colors.bg}
  }
})

table.insert(cur_section, {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.yellow,colors.bg},
  }
})

table.insert(cur_section, {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = {colors.cyan,colors.bg},
  }
})

table.insert(cur_section, {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue,colors.bg},
  }
})

table.insert(cur_section, {
  LineInfo = {
    provider = function ()
      local line = tostring(vim.fn.line("."))
      if #line % 2 ~= 0 then
        line = utils.left_pad_string(line, #line + (2 - #line % 2))
      end

      local col = tostring(vim.fn.col("."))
      if #col % 2 ~= 0 then
        col = utils.right_pad_string(col, #col + (2 - #col % 2))
      end

      local result = line .. ":" .. col
      local min_size = #result
      if min_size % 4 ~= 0 then min_size = #result + (4 - #result % 4) end

      if #result < min_size then
        result = utils.center_pad_string(result, min_size)
      end

      return result
    end,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.fg,colors.bg},
  },
})

table.insert(cur_section, {
  Percent = {
    provider = function ()
      local current_line = vim.fn.line('.')
      local total_line = vim.fn.line('$')
      local result,_ = math.modf((current_line/total_line)*100)
      return ' '.. result .. '% '
    end,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.fg,colors.bg,'bold'},
  }
})

table.insert(cur_section, {
  IndentInfo = {
    provider = function ()
      if vim.bo.expandtab then
        return "SPACES " .. vim.bo.shiftwidth
      else
        return "TABS " .. vim.bo.tabstop
      end
    end,
    icon = " ",
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.cyan, colors.bg, 'bold'},
  },
})

table.insert(cur_section, {
  FileEncode = {
    provider = 'FileEncode',
    condition = condition.hide_in_width,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.green,colors.bg,'bold'}
  }
})

table.insert(cur_section, {
  FileFormat = {
    provider = 'FileFormat',
    condition = condition.hide_in_width,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.green,colors.bg,'bold'}
  }
})

table.insert(cur_section, {
  GitIcon = {
    provider = function() return '  ' end,
    condition = condition.check_git_workspace,
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.violet,colors.bg,'bold'},
  }
})

table.insert(cur_section, {
  GitBranch = {
    provider = 'GitBranch',
    condition = condition.check_git_workspace,
    highlight = {colors.violet,colors.bg,'bold'},
  }
})

-- SHORT LINE LEFT

cur_section = gls.short_line_left

table.insert(cur_section, {
  RainbowRed = {
    provider = function() return '▊ ' end,
    highlight = {colors.blue,colors.bg}
  },
})

table.insert(cur_section, {
  BufferType = {
    provider = 'FileTypeName',
    separator = ' ',
    separator_highlight = {'NONE',colors.bg},
    highlight = {colors.blue,colors.bg,'bold'}
  }
})

table.insert(cur_section, {
  SFileName = {
    provider =  'SFileName',
    condition = condition.buffer_not_empty,
    highlight = {colors.fg,colors.bg,'bold'}
  }
})

-- SHORT LINE RIGHT

cur_section = gls.short_line_right

table.insert(cur_section, {
  BufferIcon = {
    provider= 'BufferIcon',
    highlight = {colors.fg,colors.bg}
  }
})

vim.cmd([[hi! link StatusLine GalaxySFileName]])
