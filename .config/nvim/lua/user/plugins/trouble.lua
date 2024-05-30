return function ()
  require("trouble").setup({
    auto_close = false, -- auto close when there are no items
    auto_open = false, -- auto open when there are items
    auto_preview = false, -- automatically open preview when on an item
    auto_refresh = true, -- auto refresh when open
    auto_jump = false, -- auto jump to the item when there's only one
    focus = true, -- Focus the window when opened
    restore = true, -- restores the last location in the list when opening
    follow = true, -- Follow the current item
    indent_guides = true, -- show indent guides
    max_items = 200, -- limit number of items that can be displayed per section
    multiline = true, -- render multi-line messages
    pinned = false, -- When pinned, the opened trouble window will be bound to the current buffer
    -- window options for the results window. Can be a split or a floating window.
    win = {
      type = "split",
      size = 10,
    },
    -- Window options for the preview window. Can be a split, floating window,
    -- or `main` to show the preview in the main editor window.
    preview = {
      type = "main",
      -- when a buffer is not yet loaded, the preview window will be created
      -- in a scratch buffer with only syntax highlighting enabled.
      -- Set to false, if you want the preview to always be a real loaded buffer.
      scratch = true,
      wo = {
        winbar = "",
      },
    },
    -- Throttle/Debounce settings. Should usually not be changed.
    --- @type table<string, number|{ms:number, debounce?:boolean}>
    throttle = {
      refresh = 20, -- fetches new data when needed
      update = 10, -- updates the window
      render = 10, -- renders the window
      follow = 100, -- follows the current item
      preview = { ms = 100, debounce = true }, -- shows the preview for the current item
    },
    keys = {
      ["?"] = "help",
      r = "refresh",
      R = "toggle_refresh",
      q = "close",
      o = "jump_close",
      ["<esc>"] = "cancel",
      ["<cr>"] = "jump",
      ["<2-leftmouse>"] = "jump",
      ["<c-s>"] = "jump_split",
      ["<c-v>"] = "jump_vsplit",
      -- go down to next item (accepts count)
      -- j = "next",
      ["}"] = "next",
      ["]]"] = "next",
      -- go up to prev item (accepts count)
      -- k = "prev",
      ["{"] = "prev",
      ["[["] = "prev",
      i = "inspect",
      p = "preview",
      P = "toggle_preview",
      h = "fold_close",
      l = "fold_open",
      zo = "fold_open",
      zO = "fold_open_recursive",
      zc = "fold_close",
      zC = "fold_close_recursive",
      za = "fold_toggle",
      zA = "fold_toggle_recursive",
      zm = "fold_more",
      zM = "fold_close_all",
      zr = "fold_reduce",
      zR = "fold_open_all",
      zx = "fold_update",
      zX = "fold_update_all",
      zn = "fold_disable",
      zN = "fold_enable",
      zi = "fold_toggle_enable",
    },
    icons = {
      indent = {
        top           = "│ ",
        middle        = "├╴",
        last          = "└╴",
        fold_open     = " ",
        fold_closed   = " ",
        ws            = "  ",
      },
      folder_closed   = " ",
      folder_open     = " ",
    },
  })
end
