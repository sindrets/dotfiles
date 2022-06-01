return function()
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")

  local api = vim.api
  local au = Config.common.au
  local hl = Config.common.hl
  local lib = Config.lib
  local utils = Config.common.utils

  local banner = {
    "⠀⢀⣴⣦⠀⠀⠀⠀⢰⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣰⣿⣿⣿⣷⡀⠀⠀⢸⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣿⣿⣿⣿⣿⣿⣄⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⣿⣿⣿⠈⢿⣿⣿⣦⢸⣿⣿⡇⠀⣠⠴⠒⠢⣄⠀⠀⣠⠴⠲⠦⣄⠐⣶⣆⠀⠀⢀⣶⡖⢰⣶⠀⢰⣶⣴⡶⣶⣆⣴⡶⣶⣶⡄",
    "⣿⣿⣿⠀⠀⠻⣿⣿⣿⣿⣿⡇⢸⣁⣀⣀⣀⣘⡆⣼⠁⠀⠀⠀⠘⡇⠹⣿⡄⠀⣼⡿⠀⢸⣿⠀⢸⣿⠁⠀⢸⣿⡏⠀⠀⣿⣿",
    "⠹⣿⣿⠀⠀⠀⠙⣿⣿⣿⡿⠃⢸⡀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⢀⡏⠀⢻⣿⣸⣿⠁⠀⢸⣿⠀⢸⣿⠀⠀⢸⣿⡇⠀⠀⣿⣿",
    "⠀⠈⠻⠀⠀⠀⠀⠈⠿⠋⠀⠀⠈⠳⢤⣀⣠⠴⠀⠈⠧⣄⣀⡠⠞⠁⠀⠀⠿⠿⠃⠀⠀⢸⣿⠀⢸⣿⠀⠀⠸⣿⡇⠀⠀⣿⡿",
  }

  local header = {
    type = "text",
    val = {},
    opts = {
      position = "center",
      hl = "DashboardHeader",
    },
  }

  local footer = {
    type = "text",
    val = {},
    opts = {
      position = "center",
      hl = "DashboardFooter",
    },
  }

  if api.nvim_win_get_height(0) < 30 then
    header.val = {}
  else
    header.val = banner
  end

  local version_lines = vim.split(vim.api.nvim_exec("version", true), "\n", {})
  footer.val = { " " ..  version_lines[2] }

  for k, v in pairs(header) do
    dashboard.section.header[k] = v
  end
  for k, v in pairs(footer) do
    dashboard.section.footer[k] = v
  end

  local function button(label, callback, mapping)
    local keys = utils.t(mapping)
    return {
      type = "button",
      val = label,
      on_press = function()
        api.nvim_feedkeys(keys, "normal", false)
      end,
      opts = {
        position = "center",
        shortcut = (" %s "):format(mapping),
        align_shortcut = "right",
        hl = "DashboardCenter",
        hl_shortcut = "DashboardShortCut",
        cursor = 0,
        width = 40,
      },
      keymap = { "n", mapping, callback, { nowait = true, silent = true } }
    }
  end

  local function setup_buffer(bufnr)
    vim.opt_local.list = false
    vim.opt_local.winhl = table.concat({
      "Normal:DashboardNormal",
      "EndOfBuffer:DashboardEndOfBuffer",
    }, ",")
    for _, btn in ipairs(dashboard.section.buttons.val) do
      local m = utils.vec_slice(btn.keymap)
      m[4] = vim.tbl_extend("force", m[4] or {}, { buffer = bufnr })
      vim.keymap.set(m[1], m[2], m[3], m[4])
    end
  end

  local function setup_highlights()
    hl.hi_link("DashboardNormal", "Normal", { default = true })
    hl.hi("DashboardEndOfBuffer", { fg = "bg", bg = "bg", default = true })
    hl.hi_link("DashboardHeader", "Type", { default = true })
    hl.hi_link("DashboardCenter", "Keyword", { default = true })
    -- hl.hi_link("DashboardShortCut", "String", { default = true })
    hl.hi("DashboardShortCut", { fg = hl.get_fg("String"), gui = "bold,reverse", default = true })
    hl.hi_link("DashboardFooter", "Number", { default = true })
  end

  au.declare_group("alpha_config", {}, {
    {
      "User",
      {
        pattern = "AlphaReady",
        callback = function(state)
          setup_buffer(state.buf)
        end,
      },
    },
    {
      "ColorScheme",
      {
        pattern = "*",
        callback = function(_)
          setup_highlights()
        end,
      }
    }
  })

  dashboard.section.buttons.val = {
    button("  New File", "<Cmd>enew<CR>", "n"),
    button("  Find File", function() lib.workspace_files() end, "ff"),
    button("  Git Status", "<Cmd>Telescope git_status<CR>", "gs"),
    button("  Recently Used Files", "<Cmd>Telescope oldfiles<CR>", "rf"),
    button("  Find Word", "<Cmd>Telescope live_grep<CR>", "fw"),
    button("  Jump to Mark", "<Cmd>Telescope marks<CR>", "fm"),
    button("  Quit", "<Cmd>wincmd q<CR>", "q"),
  }

  setup_highlights()
  alpha.setup(dashboard.config)
end
