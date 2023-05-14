return function()
  local alpha = require("alpha")
  local banners = require("user.plugins.alpha.banners")

  local api = vim.api
  local au = Config.common.au
  local hl = Config.common.hl
  local lib = Config.lib
  local utils = Config.common.utils

  local elements = {
    header = {},
    buttons = {},
    footer = {},
  }

  local function get_banner()
    local height = api.nvim_win_get_height(0)
    local list = { "majora", "nvim" }
    local bg = vim.o.background
    local result

    for _, name in ipairs(list) do
      local banner = banners[name .. "_" .. bg] or banners[name]
      result = vim.split(banner, "\n", {})
      if height >= #result + 20 then
        return result
      end
    end

    return {}
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
    for _, btn in ipairs(elements.buttons) do
      local m = utils.vec_slice(btn.keymap)
      m[4] = vim.tbl_extend("force", m[4] or {}, { buffer = bufnr })
      vim.keymap.set(m[1], m[2], m[3], m[4])
    end
  end

  local function setup_highlights()
    hl.hi_link("DashboardNormal", "Normal", { default = true })
    hl.hi("DashboardEndOfBuffer", { fg = hl.get_bg("Normal"), bg = hl.get_bg("Normal"), default = true })
    hl.hi_link("DashboardHeader", "Type", { default = true })
    hl.hi_link("DashboardCenter", "Keyword", { default = true })
    -- hl.hi_link("DashboardShortCut", "String", { default = true })
    hl.hi("DashboardShortCut", { fg = hl.get_fg("String"), gui = "bold,reverse", default = true })
    hl.hi_link("DashboardFooter", "Number", { default = true })
  end

  local function init_elements()
    local version_lines = vim.split(vim.api.nvim_exec("version", true), "\n", {})

    elements.header = {
      type = "text",
      val = get_banner(),
      opts = {
        position = "center",
        hl = "DashboardHeader",
      },
    }

    elements.footer = {
      type = "text",
      val = { " " ..  version_lines[2] },
      opts = {
        position = "center",
        hl = "DashboardFooter",
      },
    }

    elements.buttons = {
      button("  New File", "<Cmd>enew<CR>", "n"),
      button("  Find File", function() lib.workspace_files() end, "ff"),
      button("󰊢  Git Status", "<Cmd>Telescope git_status<CR>", "gs"),
      button("  Recently Used Files", "<Cmd>Telescope oldfiles<CR>", "rf"),
      button("󰊄  Find Word", "<Cmd>Telescope live_grep<CR>", "fw"),
      button("  Jump to Mark", "<Cmd>Telescope marks<CR>", "fm"),
      button("󰅚  Quit", "<Cmd>wincmd q<CR>", "q"),
    }
  end

  au.declare_group("alpha_config", {}, {
    {
      "User",
      pattern = "AlphaReady",
      callback = function(state)
        setup_buffer(state.buf)
      end,
    },
    {
      "ColorScheme",
      pattern = "*",
      callback = function(_)
        setup_highlights()
      end,
    }
  })

  init_elements()
  setup_highlights()

  alpha.setup({
    opts = {
      margin = 5,
    },
    layout = {
      { type = "padding", val = 1, },
      elements.header,
      { type = "padding", val = 2, },
      {
        type = "group",
        opts = {
          spacing = 1,
        },
        val = elements.buttons,
      },
      elements.footer,
    },
  })
end
