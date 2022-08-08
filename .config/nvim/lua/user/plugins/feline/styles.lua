local lazy = require("user.lazy")

---@type FelineConfig|LazyModule
local c = lazy.access(_G, "Config.plugin.feline")

local api = vim.api

local M = {}

M.color_palettes = {
  doom_dark = {
    yellow = "#ECBE7B",
    cyan = "#538080",
    darkblue = "#081633",
    green = "#98be65",
    orange = "#FF8800",
    violet = "#a9a1e1",
    magenta = "#c678dd",
    blue = "#51afef",
    red = "#ec5f67",
  },
  doom_light = {
    yellow = "#e69500",
    cyan = "#408080",
    darkblue = "#081633",
    green = "#7f9f54",
    orange = "#FF8800",
    violet = "#958ec7",
    magenta = "#c678dd",
    blue = "#4596cd",
    red = "#ec5f67",
  },
}

---@alias FelineThemeName '"basic"'|'"doom"'

M.themes = {
  basic = {
    get = function()
      c.current_palette = {}
      return {
        vi_mode = {
          style = "bold",
        },
        ["file.icon"] = {
          fg = "fg",
        },
        ["file.line_percent"] = {
          fg = "fg",
          style = "bold",
        },
      }
    end,
  },
  doom = {
    get = function()
      c.current_palette = vim.deepcopy(
        vim.o.background == "light"
          and M.color_palettes.doom_light
          or M.color_palettes.doom_dark
      )

      local mode_colors = {
        ["NORMAL"] = "blue",
        ["VISUAL"] = "magenta",
        ["VISUAL LINE"] = "magenta",
        ["VISUAL BLOCK"] = "magenta",
        ["SELECT"] = "magenta",
        ["SELECT LINE"] = "magenta",
        ["SELECT BLOCK"] = "magenta",
        ["INSERT"] = "green",
        ["COMPLETION"] = "green",
        ["REPLACE"] = "red",
        ["COMMAND"] = "orange",
        ["EX"] = "orange",
        ["NORMAL EX"] = "orange",
        ["PROMPT"] = "cyan",
        ["CONFIRM"] = "cyan",
        ["SHELL"] = "cyan",
        ["TERMINAL"] = "orange",
      }

      return {
        block = {
          fg = "blue",
        },
        vi_mode = function()
          local mode = api.nvim_get_mode().mode
          local mode_name = c.mode_name_map[mode]
          return {
            fg = mode_colors[mode_name] or "NONE",
            style = "bold",
          }
        end,
        paste_mode = {
          fg = "orange",
          style = "bold",
        },
        lsp_server = {
          fg = "red",
          style = "bold",
        },
        ["file.info"] = function()
          local active = (
            api.nvim_get_current_buf() == tonumber(vim.g.actual_curbuf)
            and api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)
          )
          return {
            fg = active and "magenta" or "fg",
            style = "bold",
          }
        end,
        ["file.filetype"] = {
          fg = "blue",
          style = "bold",
        },
        ["file.format"] = {
          fg = "green",
          style = "bold",
        },
        ["file.line_info"] = {
          fg = "fg",
        },
        ["file.line_percent"] = {
          fg = "fg",
          style = "bold",
        },
        ["file.line_count"] = {
          fg = "fg",
        },
        ["file.indent_info"] = {
          fg = "cyan",
          style = "bold",
        },
        ["git.branch"] = {
          fg = "violet",
          style = "bold",
        },
        ["git.diff_add"] = {
          fg = "green",
        },
        ["git.diff_mod"] = {
          fg = "blue",
        },
        ["git.diff_del"] = {
          fg = "red",
        },
        ["diagnostic.err"] = {
          fg = "red",
        },
        ["diagnostic.warn"] = {
          fg = "yellow",
        },
        ["diagnostic.info"] = {
          fg = "blue",
        },
        ["diagnostic.hint"] = {
          fg = "blue",
        },
      }
    end,
  },
}

return M
