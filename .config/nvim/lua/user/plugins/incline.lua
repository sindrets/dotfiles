return function()
  local web_devicons = require("nvim-web-devicons")
  local utils = Config.common.utils

  local USE_COLOR = false
  local MAX_NAME_SIZE = 50

  require('incline').setup {
    render = function(props)
      local p = vim.api.nvim_buf_get_name(props.buf)
      local basename = pl:basename(p)
      local name = basename == "" and "[No Name]" or basename
      local ext

      if #name > MAX_NAME_SIZE + 1 then
        name = "«" .. name:sub(-MAX_NAME_SIZE)
      end

      if vim.bo[props.buf].buftype == "terminal" then
        basename = "sh"
      else
        ext = pl:extension(p)
      end

      if type(vim.b[props.buf].incline_state) == "nil" then
        vim.b[props.buf].incline_state = {
          ftype = pl:type(p),
        }
      end
      local state = vim.b[props.buf].incline_state

      local icon, color
      if state.ftype == "directory" then
        icon, color = web_devicons.get_icon_color("lir_folder_icon")
      else
        icon, color = web_devicons.get_icon_color(basename, ext, { default = true })
      end

      return utils.vec_join(
        {{ icon .. " ", guifg = USE_COLOR and color or nil }},
        {{ name }},
        vim.bo[props.buf].modified and {{ " [+]" }} or nil
      )
    end,
    debounce_threshold = {
      falling = 50,
      rising = 0,
    },
    hide = {
      cursorline = true,
      focused_win = false,
      only_win = true,
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
      zindex = 10,
    },
  }
end
