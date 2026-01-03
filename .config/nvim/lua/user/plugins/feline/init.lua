local lz = require("user.lazy")

local Job = lz.require("imminent.Job") ---@module "imminent.Job"
local StatusComponent = lz.require("user.plugins.feline.status_component") ---@module "user.plugins.feline.status_component"
local async = lz.require("imminent") ---@module "imminent"
local devicons = lz.require("nvim-web-devicons") ---@module "nvim-web-devicons"
local feline = lz.require("feline") ---@module "feline"
local lsp = lz.require("feline.providers.lsp") ---@module "feline.providers.lsp"
local styles = lz.require("user.plugins.feline.styles") ---@module "user.plugins.feline.styles"

local Path = Config.common.utils.Path
local utils = Config.common.utils
local pb = Config.common.pb
local hl = Config.common.hl
local api = vim.api

Config.plugin.feline = {}

---@class FelineConfig
local M = Config.plugin.feline

M.current_theme = "doom"
M.current_palette = {}
M.statusline = {}
M.components = {}

local icons = {
  modified = "󰆓",
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
    hint = "",
    info = "",
  },
}

M.mode_name_map = {
  n = 'NORMAL',
  no = 'NORMAL',
  nov = 'NORMAL',
  noV = 'NORMAL',
  nt = 'NORMAL',
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

---@class FelineApplyThemeSpec
---@field statusline table
---@field no_reload boolean

---@param theme? table|string
---@param opt? FelineApplyThemeSpec
function M.apply_theme(theme, opt)
  opt = opt or {}
  local statusline = opt.statusline or M.statusline

  if theme then
    M.current_theme = theme
  end
  theme = theme or M.current_theme

  if type(theme) == "string" then
    theme = styles.themes[theme]
    if not theme then
      utils.err(("[feline config] Theme '%s' does not exist!"):format(theme))
      M.current_theme = "simple"
      return
    end
  end

  if not opt.no_reload then
    M.reload()
    return
  end

  ---@cast theme table
  ---@cast statusline table

  local t = theme.get()
  local default_hl = {
    fg = "fg",
  }

  M.current_palette = vim.tbl_extend("keep", M.current_palette, styles.color_palettes.default)

  for _, kind in ipairs({ statusline.active, statusline.inactive }) do
    for _, section in ipairs(kind) do
      for _, component in ipairs(section) do
        local field = component.name and component.name:match("user%.(.*)") or ""
        component.hl = t[field] or component.hl
        if not component.hl then
          component.hl = vim.deepcopy(default_hl)
        end
      end
    end
  end
end

function M.process_comp_configs(configs)
  local function recurse(table_path, item)
    if item.provider then
      item:set_name(table_path)
      return
    end
    for name, entry in pairs(item) do
      recurse(("%s%s%s"):format(table_path, table_path ~= "" and "." or "", name), entry)
    end
  end
  recurse("user", configs)
end

function M.list_comp_configs(configs)
  local ret = {}

  local function recurse(item)
    if item.provider then
      table.insert(ret, item)
      return
    end

    for _, entry in pairs(item) do
      recurse(entry)
    end
  end

  recurse(configs)

  return ret
end

function M.get_custom_providers()
  local configs = M.list_comp_configs(M.components)
  local ret = {}

  for _, config in ipairs(configs) do
    ret[config.name] = config.provider.get
  end

  return ret
end

---@diagnostic disable-next-line: unused-local, unused-function
local function filler_section(size)
  return {
    provider = function()
      return string.rep(" ", size)
    end,
    hl = {
      fg = "NONE",
      bg = "bg",
    }
  }
end

local function extend_comps(components, config)
  return vim.tbl_map(function(comp)
    return vim.tbl_extend("keep", comp, config)
  end, components)
end

---@diagnostic disable-next-line: unused-local, unused-function
local function width_condition(min_width)
  return function()
    return vim.api.nvim_win_get_width(0) > min_width
  end
end

---@class feline.CompConfigs
M.components = {
  block = StatusComponent({
    provider = {
      update = { "VimEnter" },
      get = function() return "▊" end,
    },
  }),
  vi_mode = StatusComponent({
    provider = {
      update = { "ModeChanged" },
      get = function()
        return M.mode_name_map[api.nvim_get_mode().mode] or ""
      end,
    }
  }),
  paste_mode = StatusComponent({
    provider = function()
      return vim.o.paste and "[PASTE]" or ""
    end,
  }),
  lsp_server = StatusComponent({
    provider = {
      update = { "LspAttach", "LspDetach", "BufEnter" },
      get = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })

        if next(clients) then
          return table.concat(vim.tbl_map(function(v)
            return v.name
          end, clients), ",")
        end
      end,
    },
    enabled = function()
      local exclude = { [''] = true }
      if exclude[vim.bo.filetype] then
        return false
      end
      return next(vim.lsp.get_clients({ bufnr = 0 }))
    end,
    icon = icons.lsp_server .. " ",
    truncate_hide = true,
  }),
  file = {
    info = StatusComponent({
      provider = {
        update = { "BufEnter", "BufFilePost", "BufModifiedSet", "BufWritePost" },
        get = function()
          local uname = utils.get_unique_file_bufname(api.nvim_buf_get_name(0))
          local status = vim.bo.modified and (" " .. icons.modified .. " ") or ""

          local max_size = 51
          local margin = 42
          local width = vim.o.laststatus == 3 and vim.o.columns or api.nvim_win_get_width(0)
          local size = utils.clamp(width - margin, 1, max_size)

          -- Truncate name if it's too long
          if #uname > size then
            uname = "«" .. uname:sub(math.max(#uname - size, 3))
          end

          -- Escape % signs
          return (uname:gsub("%%", "%%%%")) .. status
        end,
      },
      enabled = function()
        return vim.fn.bufname() ~= ""
      end,
    }),
    icon = StatusComponent({
      provider = {
        update = { "BufEnter", "BufFilePost" },
        get = function()
          local basename, ext
          if vim.bo.buftype == "terminal" then
            basename = "sh"
          else
            local path = Path.from(api.nvim_buf_get_name(0))
            basename = path:basename()
            ext = path:extension()
          end

          local icon, _ = devicons.get_icon(basename, ext, { default = false })
          return (icon or "")
        end
      },
      enabled = function()
        return vim.fn.bufname() ~= ""
      end,
      hl = function()
        ---@diagnostic disable-next-line: redefined-local
        local fg
        local basename, ext
        if vim.bo.buftype == "terminal" then
          basename = "sh"
        else
          local path = Path.from(api.nvim_buf_get_name(0))
          basename = path:basename()
          ext = path:extension()
        end

        local _, color = devicons.get_icon_color(basename, ext)
        if color then
          fg = color
        else
          fg = "fg"
        end

        return {
          fg = fg,
        }
      end,
    }),
    filetype = StatusComponent({
      provider = {
        update = { "BufEnter", "FileType" },
        get = function()
          return vim.bo.ft
        end,
      },
      enabled = function()
        if not vim.tbl_contains({ "", "nowrite" }, vim.bo.bt)
          and not vim.fn.bufname():match("^Scratch %d+$")
        then
          return false
        end

        return vim.bo.ft ~= ""
      end,
      icon = function()
        local ft = vim.bo.ft
        local icon, icon_hl = devicons.get_icon_by_filetype(ft)

        return {
          str = (icon or "") .. " ",
          hl =  {
            fg = icon_hl and hl.get_fg(icon_hl) or "fg",
          }
        }
      end,
    }),
    format = StatusComponent({
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
    }),
    line_info = StatusComponent({
      provider = function ()
        local cursor = api.nvim_win_get_cursor(0)
        local line = tostring(cursor[1])
        if #line % 2 ~= 0 then
          line = utils.str_left_pad(line, #line + (2 - #line % 2))
        end

        local col = tostring(cursor[2])
        if #col % 2 ~= 0 then
          col = utils.str_right_pad(col, #col + (2 - #col % 2))
        end

        local result = line .. ":" .. col
        if #result % 4 ~= 0 then
          result = utils.str_center_pad(result, #result + (4 - #result % 4))
        end

        return result
      end,
    }),
    line_percent = StatusComponent({
      provider = function ()
        local current_line = api.nvim_win_get_cursor(0)[1]
        local total_line = api.nvim_buf_line_count(0)
        local result, _ = math.modf((current_line / total_line) * 100)
        return result .. "%%"
      end,
    }),
    line_count = StatusComponent({
      provider = function ()
        return tostring(api.nvim_buf_line_count(0))
      end,
      icon = icons.line_number .. " ",
    }),
    search = StatusComponent({
      provider = function()
        if vim.v.hlsearch ~= 1 then return "" end

        local ok, count = pcall(vim.fn.searchcount, { maxcount = 10000, timeout = 150 })

        if not ok or vim.tbl_isempty(count) then
          return ""
        end

        local total = count.total
        local current = count.current

        if count.incomplete == 2 then
          total = ">" .. count.maxcount
          if current > count.maxcount then current = total end
        end

        return ("[%s/%s]"):format(current, total)
      end,
    }),
    indent_info = StatusComponent({
      provider = function()
        if vim.bo.expandtab then
          return "spaces:" .. vim.bo.shiftwidth
        else
          return "tabs:" .. vim.bo.tabstop
        end
      end,
      icon = icons.indent .. " ",
      truncate_hide = true,
    }),
  },
  git = {
    branch = StatusComponent({
      provider = {
        -- update = { "BufEnter", "CmdlineLeave", "FocusGained" },
        get = function()
          local rev, path, dir

          if vim.b[0].gitsigns_head then
            rev = vim.b[0].gitsigns_head
            path = Path.from(api.nvim_buf_get_name(0))
            dir = path:parent():unwrap_or_else(Path.cwd)
          else
            rev = vim.g.gitsigns_head or ""
            path = Path.cwd()
            dir = path
          end

          if rev == "" then
            return ""
          end

          local rebasing
          rev, rebasing = pb.match_any(rev, { "(.*)(%(rebasing%))", "(.*)" })

          local desc = rebasing and ":(rebasing)" or ""
          local cache = Config.state.git.rev_name_cache
          local key = path:tostring() .. "#" .. rev

          if cache:has(key) then
            return cache:get(key) .. desc
          elseif (rev == "HEAD" or rev:match("^%x+$")) then
            -- Problem: Gitsigns shows the current HEAD as a commit SHA if it's
            -- anything other than the HEAD of a branch.
            -- Solution: Use git-name-rev to get more meaningful names.

            local name = rev

            async.spawn(function()
              -- Check reflog to find the last checkout
              local cwd = dir:is_readable():await() and dir or Path.cwd()

              local reflog = Job.new({
                cmd = {
                  "git",
                  "reflog",
                  "--pretty=format:%gs",
                  "-E",
                  "--grep-reflog=^checkout: |^rebase \\((start|finish)\\): (checkout|returning) ",
                  "-n1",
                },
                cwd = cwd,
                success_cond =
                  Job.Conditions.zero_exit *
                  Job.Conditions.non_empty_stdout,
              })

              if reflog:wait():await():is_ok() then
                name = pb.match_any(pb.line(reflog.stdout:unwrap(), 1) or "", {
                  "^checkout: moving from %S+ to (%S+)$",
                  "^rebase %(start%): checkout (%S+)",
                  "^rebase %(finish%): returning to (%S+)",
                })

                local name_rev = Job.new({
                  cmd = {
                    "git",
                    "name-rev",
                    "--name-only",
                    "--no-undefined",
                    "--always",
                    name,
                  },
                  cwd = cwd,
                  success_cond =
                    Job.Conditions.zero_exit *
                    Job.Conditions.non_empty_stdout,
                })

                if name_rev:wait():await():is_ok() then
                  name = pb.match_any(
                    pb.line(name_rev.stdout:unwrap(), 1) or "",
                    { "(.*)%^0", "(.*)" }
                  )
                end
              end
            end):block_on()

            cache:put(key, name, { ttl = 60 * 1000 })

            return name .. desc
          else
            return rev .. desc
          end
        end,
      },
      icon = icons.git.branch .. " ",
      left_sep = "█",
      right_sep = "█ ",
      -- left_sep = "█",
      -- right_sep = "█ ",
    }),
    diff_add = StatusComponent({
      provider = "git_diff_added",
      icon = icons.git.diff_add .. " ",
      truncate_hide = true,
    }),
    diff_mod = StatusComponent({
      provider = "git_diff_changed",
      icon = icons.git.diff_mod .. " ",
      truncate_hide = true,
    }),
    diff_del = StatusComponent({
      provider = "git_diff_removed",
      icon = icons.git.diff_del .. " ",
      truncate_hide = true,
    }),
  },
  diagnostic = {
    err = StatusComponent({
      provider = "diagnostic_errors",
      icon = icons.diagnostic.err .. " ",
      enabled = function()
        return lsp.diagnostics_exist(vim.diagnostic.severity.ERROR)
      end,
      truncate_hide = true,
    }),
    warn = StatusComponent({
      provider = "diagnostic_warnings",
      icon = icons.diagnostic.warn .. " ",
      enabled = function()
        return lsp.diagnostics_exist(vim.diagnostic.severity.WARN)
      end,
      truncate_hide = true,
    }),
    info = StatusComponent({
      provider = "diagnostic_info",
      icon = icons.diagnostic.info .. " ",
      enabled = function()
        return lsp.diagnostics_exist(vim.diagnostic.severity.INFO)
      end,
      truncate_hide = true,
    }),
    hint = StatusComponent({
      provider = "diagnostic_hints",
      icon = icons.diagnostic.hint .. " ",
      enabled = function()
        return lsp.diagnostics_exist(vim.diagnostic.severity.HINT)
      end,
      truncate_hide = true,
    }),
  },
}

M.process_comp_configs(M.components)

function M.update()
  local fg = hl.get_fg({ "StatusLine", "Normal" })
  local bg = hl.get_bg({ "StatusLine", "Normal" })

  if hl.get_hl_attr("StatusLine", hl.HlAttribute.reverse) then
    fg, bg = bg, fg
  end

  hl.hi("StatusLine", { fg = fg, bg = bg, gui = "NONE" })
  hl.hi("StatusLineNC", { fg = fg, bg = bg, ctermfg = 1, gui = "NONE", link = -1 })

  styles.color_palettes.default = vim.deepcopy({ fg = fg, bg = bg })

  local comps = M.components

  M.process_comp_configs(comps)

  local statusline = {
    active = {
      -- LEFT :
      extend_comps(
        {
          comps.block(),
          comps.vi_mode(),
          comps.paste_mode(),
          -- comps.file.info(),
          comps.git.branch(),
          comps.git.diff_add(),
          comps.git.diff_mod(),
          comps.git.diff_del(),
        },
        { right_sep = " " }
      ),
      -- MIDDLE :
      {},
      -- RIGHT :
      utils.vec_join(
        extend_comps(
          {
            comps.diagnostic.err(),
            comps.diagnostic.warn(),
            comps.diagnostic.hint(),
            comps.diagnostic.info(),
            comps.file.search(),
            comps.file.line_info(),
            comps.file.line_percent(),
            comps.file.line_count(),
            comps.file.filetype(),
            comps.lsp_server(),
            comps.file.indent_info(),
            comps.file.format(),
            -- comps.git.branch(),
          },
          { left_sep = " " }
        ),
        { filler_section(1) }
      ),
    },
    inactive = {
      -- LEFT :
      extend_comps(
        {
          comps.block(),
          comps.file.filetype(),
          comps.file.info(),
        },
        { right_sep = " " }
      ),
      -- MIDDLE :
      {},
      -- RIGHT :
      {},
    },
  }

  utils.tbl_clear(M.statusline)
  for k, v in pairs(statusline) do
    M.statusline[k] = v
  end

  M.apply_theme(M.current_theme, { no_reload = true })
end

function M.setup()
  feline.setup({
    custom_providers = M.get_custom_providers(),
    components = M.statusline,
    theme = M.current_palette,
    force_inactive = {
      filetypes = {
        -- "^NvimTree$",
        -- "^vista$",
        -- "^dbui$",
        -- "^packer$",
        -- "^fugitiveblame$",
        -- "^Trouble$",
        -- "^DiffviewFiles$",
        -- "^DiffviewFileHistory$",
        -- "^DiffviewFHOptionPanel$",
        -- "^Outline$",
        -- "^dashboard$",
        -- "^NeogitStatus$",
        -- "^lir$",
      },
      buftypes = {
        -- "terminal"
      },
      bufnames = {},
    },
  })
end

function M.reload()
  M.update()
  feline.use_theme(M.current_palette)
end

return function()
  Config.plugin.feline.update()
  Config.plugin.feline.setup()
end
