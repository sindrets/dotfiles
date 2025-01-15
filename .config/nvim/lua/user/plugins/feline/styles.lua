local lz = require("user.lazy")

---@type FelineConfig|LazyModule
local c = lz.get(_G, "Config.plugin.feline")

local hl = Config.common.hl

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

---@alias FelineThemeName "simple"|"duo"|"doom"

M.themes = {
  -- Mostly monotone theme
  simple = {
    get = function()
      c.current_palette = {
        dim100 = hl.get_fg("StatusLineDim100"),
        dim200 = hl.get_fg("StatusLineDim200"),
        dim300 = hl.get_fg("StatusLineDim300"),
        dim400 = hl.get_fg("StatusLineDim400"),
        dim500 = hl.get_fg("StatusLineDim500"),
        dim600 = hl.get_fg("StatusLineDim600"),
        dim700 = hl.get_fg("StatusLineDim700"),
        dim800 = hl.get_fg("StatusLineDim800"),
        dim900 = hl.get_fg("StatusLineDim900"),
        add = hl.get_fg("diffAdded"),
        mod = hl.get_fg("diffChanged"),
        del = hl.get_fg("diffRemoved"),
        error = hl.get_fg("DiagnosticSignError"),
        warn = hl.get_fg("DiagnosticSignWarn"),
        info = hl.get_fg("DiagnosticSignInfo"),
        hint = hl.get_fg("DiagnosticSignHint"),
      }

      return {
        vi_mode = {
          style = "bold",
        },
        ["file.icon"] = {
          fg = "fg",
        },
        ["file.info"] = {
          fg = "dim300",
        },
        ["file.search"] = {
          fg = "dim400",
        },
        ["file.line_info"] = {
          fg = "dim400",
        },
        ["file.line_percent"] = {
          fg = "dim400",
          style = "bold",
        },
        ["file.line_count"] = {
          fg = "dim400",
        },
        ["git.diff_add"] = {
          fg = "add",
        },
        ["git.diff_mod"] = {
          fg = "mod",
        },
        ["git.diff_del"] = {
          fg = "del",
        },
        ["diagnostic.err"] = {
          fg = "error",
        },
        ["diagnostic.warn"] = {
          fg = "warn",
        },
        ["diagnostic.info"] = {
          fg = "info",
        },
        ["diagnostic.hint"] = {
          fg = "hint",
        },
      }
    end,
  },

  -- 2-color theme
  duo = {
    get = function()
      c.current_palette = {
        primary = hl.get_fg("Primary"),
        accent = hl.get_fg("Accent"),
        dim100 = hl.get_fg("StatusLineDim100"),
        dim200 = hl.get_fg("StatusLineDim200"),
        dim300 = hl.get_fg("StatusLineDim300"),
        dim400 = hl.get_fg("StatusLineDim400"),
        dim500 = hl.get_fg("StatusLineDim500"),
        dim600 = hl.get_fg("StatusLineDim600"),
        dim700 = hl.get_fg("StatusLineDim700"),
        dim800 = hl.get_fg("StatusLineDim800"),
        dim900 = hl.get_fg("StatusLineDim900"),
        add = hl.get_fg("diffAdded"),
        mod = hl.get_fg("diffChanged"),
        del = hl.get_fg("diffRemoved"),
        error = hl.get_fg("DiagnosticSignError"),
        warn = hl.get_fg("DiagnosticSignWarn"),
        info = hl.get_fg("DiagnosticSignInfo"),
        hint = hl.get_fg("DiagnosticSignHint"),
      }

      return {
        block = {
          fg = "primary",
        },
        vi_mode = function()
          local mode = api.nvim_get_mode().mode
          return {
            fg = mode == "n" and "primary" or "accent",
            style = "bold",
          }
        end,
        paste_mode = {
          fg = "accent",
          style = "bold",
        },
        lsp_server = {
          fg = "primary",
          style = "bold",
        },
        ["file.info"] = {
          fg = "dim300",
        },
        ["file.search"] = {
          fg = "dim400",
        },
        ["file.line_info"] = {
          fg = "dim400",
        },
        ["file.line_percent"] = {
          fg = "dim400",
          style = "bold",
        },
        ["file.line_count"] = {
          fg = "dim400",
        },
        ["git.diff_add"] = {
          fg = "add",
        },
        ["git.diff_mod"] = {
          fg = "mod",
        },
        ["git.diff_del"] = {
          fg = "del",
        },
        ["diagnostic.err"] = {
          fg = "error",
        },
        ["diagnostic.warn"] = {
          fg = "warn",
        },
        ["diagnostic.info"] = {
          fg = "info",
        },
        ["diagnostic.hint"] = {
          fg = "hint",
        },
        ["file.filetype"] = {
          style = "bold",
        },
        ["file.format"] = {
          fg = "primary",
          style = "bold",
        },
        ["file.indent_info"] = {
          fg = "primary",
          style = "bold",
        },
        ["git.branch"] = {
          fg = "dim200",
          bg = "dim700",
          -- style = "bold",
        },
      }
    end,
  },

  -- Doom emacs colors
  doom = {
    get = function()
      local base_palette = vim.o.background == "light"
          and M.color_palettes.doom_light
          or M.color_palettes.doom_dark

      c.current_palette = vim.tbl_deep_extend("force", base_palette, {
        dim100 = hl.get_fg("StatusLineDim100"),
        dim200 = hl.get_fg("StatusLineDim200"),
        dim300 = hl.get_fg("StatusLineDim300"),
        dim400 = hl.get_fg("StatusLineDim400"),
        dim500 = hl.get_fg("StatusLineDim500"),
        dim600 = hl.get_fg("StatusLineDim600"),
        dim700 = hl.get_fg("StatusLineDim700"),
        dim800 = hl.get_fg("StatusLineDim800"),
        dim900 = hl.get_fg("StatusLineDim900"),
      })

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
        ["file.search"] = {
          fg = "dim400",
        },
        ["file.line_info"] = {
          fg = "dim400",
        },
        ["file.line_percent"] = {
          fg = "dim400",
          style = "bold",
        },
        ["file.line_count"] = {
          fg = "dim400",
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
