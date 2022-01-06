local utils = Config.common.utils
local hl = Config.common.hl
local api = vim.api

Config.feline = {}

local M = Config.feline

M.statusline = {}
M.components = {}
M.colors = {}

local icons = {
  modified = "",
  line_number = "",
  lsp_server = "",
  indent = "",
  os = {
    unix = "",
    windows = "",
    mac = "",
  },
  git = {
    branch = "",
    diff_add = "",
    diff_del = "",
    diff_mod = "",
  },
  diagnostic = {
    err = "",
    warn = "",
    info = "",
    hint = "",
  },
}

function M.update()
  local lsp = require("feline.providers.lsp")

  local fg = hl.get_fg({ "StatusLine", "Normal" })
  local bg = hl.get_bg({ "StatusLine", "Normal" })

  if hl.get_hl_attr("StatusLine", "reverse") == "1" then
    fg, bg = bg, fg
  end

  hl.hi("StatusLine", { fg = fg, bg = bg, gui = "NONE" })
  hl.hi("StatusLineNC", { fg = fg, bg = bg, gui = "NONE" })
  hl.hi_link("StatusLineNC")

  if vim.o.background == "light" then
    M.colors = {
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
    M.colors = {
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

  local colors = M.colors
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

  local mode_name_map = {
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

  local function extend_comps(components, config)
    return vim.tbl_map(function(comp)
      return vim.tbl_extend("force", comp, config)
    end, components)
  end

  ---@diagnostic disable-next-line: unused-local, unused-function
  local function filler_section(size)
    return {
      provider = function()
        return string.rep(" ", size)
      end,
      hl = {
        fg = "NONE",
        bg = colors.bg,
      }
    }
  end

  ---@diagnostic disable-next-line: unused-local, unused-function
  local function width_condition(min_width)
    return function()
      return vim.api.nvim_win_get_width(0) > min_width
    end
  end

  M.components = {
    block = {
      provider = function() return "▊" end,
      hl = {
        fg = colors.blue,
      }
    },
    vi_mode = {
      provider = function()
        return mode_name_map[api.nvim_get_mode().mode]
      end,
      hl = function()
        local mode = api.nvim_get_mode().mode
        return {
          fg = mode_colors[mode],
          style = "bold",
        }
      end,
    },
    lsp_server = {
      provider = function()
        if #vim.tbl_keys(vim.lsp.buf_get_clients(0)) > 0 then
          return vim.bo.filetype
        end
      end,
      enabled = function()
        local exclude = { [''] = true }
        if exclude[vim.bo.filetype] then
          return false
        end
        return next(vim.lsp.buf_get_clients(0))
      end,
      icon = icons.lsp_server .. " ",
      hl = {
        fg = colors.red,
        style = "bold",
      },
      truncate_hide = true,
    },
    file = {
      info = {
        provider = function()
          local uname = utils.get_unique_file_bufname(api.nvim_buf_get_name(0))
          local status = vim.bo.modified and (" " .. icons.modified .. " ") or ""
          return uname .. status
        end,
        enabled = function()
          return vim.fn.bufname() ~= ""
        end,
        hl = function()
          local active = (
            api.nvim_get_current_buf() == tonumber(vim.g.actual_curbuf)
            and api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)
          )
          return {
            fg = active and colors.magenta or colors.fg,
            style = "bold",
          }
        end,
      },
      icon = {
        provider = function()
          local basename = vim.fn.expand("%:t")
          local ext = vim.fn.fnamemodify(basename, ":e")

          local devicons = require("nvim-web-devicons")
          local icon, _ = devicons.get_icon(basename, ext, { default = false })
          return (icon or "")
        end,
        enabled = function()
          return vim.fn.bufname() ~= ""
        end,
        hl = function()
          ---@diagnostic disable-next-line: redefined-local
          local fg
          local basename = vim.fn.expand("%:t")
          local ext = vim.fn.fnamemodify(basename, ":e")

          local devicons = require("nvim-web-devicons")
          local _, color = devicons.get_icon_color(basename, ext)
          if color then
            fg = color
          else
            fg = colors.fg
          end

          return {
            fg = fg,
          }
        end,
      },
      filetype = {
        provider = function()
          return string.upper(vim.bo.ft)
        end,
        hl = {
          fg = colors.blue,
          style = "bold",
        },
      },
      format = {
        provider = function ()
          local format = vim.bo.fileformat
          local enc = vim.bo.fileencoding
          local icon
          enc = (enc ~= "" and enc or format):upper()
          if format == "unix" then
            icon = icons.os.unix
          elseif format == "dos" then
            icon = icons.os.windows
          elseif format == "mac" then
            icon = icons.os.mac
          end
          if icon then
            return ("%s %s"):format(icon, enc)
          end
          return format:upper()
        end,
        truncate_hide = true,
        hl = {
          fg = colors.green,
          style = 'bold',
        },
      },
      line_info = {
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
        hl = {
          fg = colors.fg,
        },
      },
      line_percent = {
        provider = function ()
          local current_line = vim.fn.line(".")
          local total_line = vim.fn.line("$")
          local result, _ = math.modf((current_line / total_line) * 100)
          return result .. "%%"
        end,
        hl = {
          fg = colors.fg,
          style = "bold",
        },
      },
      line_count = {
        provider = function ()
          return tostring(vim.fn.line("$"))
        end,
        icon = icons.line_number .. " ",
        hl = {
          fg = colors.fg,
        },
      },
      indent_info = {
        provider = function()
          if vim.bo.expandtab then
            return "SPACES " .. vim.bo.shiftwidth
          else
            return "TABS " .. vim.bo.tabstop
          end
        end,
        icon = icons.indent .. " ",
        truncate_hide = true,
        hl = {
          fg = colors.cyan,
          style = "bold",
        },
      },
    },
    git = {
      branch = {
        provider = "git_branch",
        icon = icons.git.branch .. " ",
        hl = {
          fg = colors.violet,
          style = "bold",
        }
      },
      diff_add = {
        provider = "git_diff_added",
        icon = icons.git.diff_add .. " ",
        hl = {
          fg = colors.green,
        },
        truncate_hide = true,
      },
      diff_mod = {
        provider = "git_diff_changed",
        icon = icons.git.diff_mod .. " ",
        hl = {
          fg = colors.blue,
        },
        truncate_hide = true,
      },
      diff_del = {
        provider = "git_diff_removed",
        icon = icons.git.diff_del .. " ",
        hl = {
          fg = colors.red,
        },
        truncate_hide = true,
      },
    },
    diagnostic = {
      err = {
        provider = "diagnostic_errors",
        icon = icons.diagnostic.err .. " ",
        enabled = function()
          return lsp.diagnostics_exist(vim.diagnostic.severity.ERROR)
        end,
        hl = {
          fg = colors.red,
        },
        truncate_hide = true,
      },
      warn = {
        provider = "diagnostic_warnings",
        icon = icons.diagnostic.warn .. " ",
        enabled = function()
          return lsp.diagnostics_exist(vim.diagnostic.severity.WARNING)
        end,
        hl = {
          fg = colors.yellow,
        },
        truncate_hide = true,
      },
      info = {
        provider = "diagnostic_info",
        icon = icons.diagnostic.info .. " ",
        enabled = function()
          return lsp.diagnostics_exist(vim.diagnostic.severity.INFO)
        end,
        hl = {
          fg = colors.blue,
        },
        truncate_hide = true,
      },
      hint = {
        provider = "diagnostic_hints",
        icon = icons.diagnostic.hint .. " ",
        enabled = function()
          return lsp.diagnostics_exist(vim.diagnostic.severity.HINT)
        end,
        hl = {
          fg = colors.cyan,
        },
        truncate_hide = true,
      },
    },
  }

  local comps = M.components
  M.statusline = {
    active = {
      -- LEFT
      [1] = extend_comps(
        {
          comps.block,
          comps.vi_mode,
          comps.file.icon,
          comps.file.info,
          comps.git.diff_add,
          comps.git.diff_mod,
          comps.git.diff_del,
        },
        { right_sep = " " }
      ),
      -- MIDDLE
      [2] = {},
      -- RIGHT
      [3] = utils.vec_join(
        extend_comps(
          {
            comps.diagnostic.err,
            comps.diagnostic.warn,
            comps.diagnostic.hint,
            comps.diagnostic.info,
            comps.file.line_info,
            comps.file.line_percent,
            comps.file.line_count,
            comps.lsp_server,
            comps.file.indent_info,
            comps.file.format,
            comps.git.branch,
          },
          { left_sep = " " }
        ),
        { filler_section(1) }
      ),
    },
    inactive = {
      -- LEFT
      [1] = extend_comps(
        {
          comps.block,
          comps.file.filetype,
          comps.file.info,
        },
        { right_sep = " " }
      ),
      -- MIDDLE
      [2] = {},
      -- RIGHT
      [3] = {},
    },
  }
end

function M.setup()
  require("feline").setup({
    components = M.statusline,
    theme = M.colors,
    force_inactive = {
      filetypes = {
        "^NvimTree$",
        "^vista$",
        "^dbui$",
        "^packer$",
        "^fugitiveblame$",
        "^Trouble$",
        "^DiffviewFiles$",
        "^DiffviewFileHistory$",
        "^DiffviewFHOptionPanel$",
        "^Outline$",
        "^dashboard$",
        "^NeogitStatus$",
        "^lir$",
      },
      buftypes = { "terminal" },
      bufnames = {},
    },
  })
end

function M.reload()
  M.update()
  M.setup()
end

return function()
  vim.api.nvim_exec([[
    augroup feline_config
      au!
      au ColorScheme * lua Config.feline.reload()
    augroup END
  ]], false)

  Config.feline.update()
  Config.feline.setup()
end
