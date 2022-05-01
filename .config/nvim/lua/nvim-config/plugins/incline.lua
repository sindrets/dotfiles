return function()
  local web_devicons = require("nvim-web-devicons")
  local utils = Config.common.utils

  local USE_COLOR = false

  require('incline').setup {
    render = function(props)
      local path = require("diffview.utils").path
      local p = vim.api.nvim_buf_get_name(props.buf)
      local name = path:basename(p)
      name = name == "" and "[No Name]" or name

      local icon, color
      if path:is_directory(p) then
        icon, color = web_devicons.get_icon_color("lir_folder_icon")
      else
        icon, color = web_devicons.get_icon_color(name, path:extension(p), { default = true })
      end

      return utils.vec_join(
        {{ icon .. " ", guifg = USE_COLOR and color or nil }},
        {{ name }},
        vim.bo[props.buf].modified and {{ " [+]" }} or nil
      )
    end,
    debounce_threshold = {
      falling = 50,
      rising = 10
    },
    hide = {
      focused_win = false,
    },
    highlight = {
      groups = {
        InclineNormal = "NONE",
        InclineNormalNC = "NONE"
      },
    },
    ignore = {
      buftypes = {},
      filetypes = {
        "fugitiveblame",
        "DiffviewFiles",
        "DiffviewFileHistory",
        "DiffviewFHOptionPanel",
        "Outline",
        "dashboard",
      },
      floating_wins = true,
      unlisted_buffers = false,
      wintypes = "special",
    },
    window = {
      margin = {
        horizontal = {
          left = 0,
          right = 1,
        },
        vertical = {
          bottom = 0,
          top = 1,
        },
      },
      options = {
        winblend = 20,
        signcolumn = "no",
        wrap = false,
      },
      padding = {
        left = 2,
        right = 2,
      },
      padding_char = " ",
      placement = {
        vertical = "top",
        horizontal = "right",
      },
      width = "fit",
      winhighlight = {
        active = {
          EndOfBuffer = "None",
          Normal = "InclineNormal",
          Search = "None",
        },
        inactive = {
          EndOfBuffer = "None",
          Normal = "InclineNormalNC",
          Search = "None",
        }
      },
      zindex = 50,
    },
  }
end
