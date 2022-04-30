return function()
  local web_devicons = require("nvim-web-devicons")
  local hl = Config.common.hl

  require('incline').setup {
    render = function(props)
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      name = name == "" and "[No Name]" or name
      local ext = name:match("^.+%.(.*)$") or ""
      local icon, hl_group = web_devicons.get_icon(name, ext, { default = true })

      return {
        -- { icon .. " ", guifg = hl.get_fg(hl_group) },
        { icon .. " " },
        { name },
      }
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
