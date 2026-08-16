return function()
  local alpha = require("alpha")
  local banners = require("user.plugins.alpha.banners")
  local alpha_utils = require("user.plugins.alpha.utils")

  local api = vim.api
  local au = Config.common.au
  local hl = Config.common.hl
  local lib = Config.lib
  local pb = Config.common.pb
  local utils = Config.common.utils

  local elements = {
    header = {},
    buttons = {},
    footer = {},
  }

  local function get_banner()
    local height = api.nvim_win_get_height(0)
    local banner_candidates = { banners.lain_2, banners.nvim }
    local bg = vim.o.background
    local result

    for _, banner in ipairs(banner_candidates) do
      local display = banner.display
      if banner.bg and banner.bg ~= bg then
        display = alpha_utils.invert_braille_str(banner.display)
      end

      result = vim.split(display, "\n", {})
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
      local m = pb.slice(btn.keymap)
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
    local version_str = pb.line(api.nvim_exec2("version", { output = true }).output, 1)

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
      val = { "󰀘 " .. version_str },
      opts = {
        position = "center",
        hl = "DashboardFooter",
      },
    }

    elements.buttons = {
      button("  New File", "<Cmd>enew<CR>", "n"),
      button("  Find File", function() lib.workspace_files() end, "ff"),
      button("󰊢  Git Status", Snacks.picker.git_status, "gs"),
      button("  Recently Used Files", Snacks.picker.recent, "rf"),
      button("󰊄  Find Word", Snacks.picker.grep, "fw"),
      button("  Jump to Mark", Snacks.picker.marks, "fm"),
      button("󰅚  Quit", "<Cmd>wincmd q<CR>", "q"),
    }
  end

  local function update_alpha()
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
        if elements and elements.header then
          elements.header.val = get_banner()
        else
          init_elements()
        end

        setup_highlights()
        update_alpha()
        vim.cmd("AlphaRedraw")
      end,
    }
  })

  init_elements()
  setup_highlights()
  update_alpha()
end
