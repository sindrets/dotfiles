return function()
  require("snacks").setup({
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    image = { enabled = true },
    notifier = { enabled = false, timeout = 3000 },
    picker = {
      enabled = true,
      ui_select = true,
      formatters = {
        file = {
          truncate = math.huge,
        },
      },
      jump = {
        jumplist = true, -- save the current position in the jumplist
        tagstack = false, -- save the current position in the tagstack
        reuse_win = false, -- reuse an existing window if the buffer is already open
        close = true, -- close the picker when jumping/editing to a location (defaults to true)
        match = false, -- jump to the first match position. (useful for `lines`)
      },
      main = {
        float = true, -- main window can be a floating window (defaults to false)
        file = false, -- main window should be a file (defaults to true)
        current = true, -- main window should be the current window (defaults to false)
      },
      layouts = {
        select = {
          layout = {
            relative = "cursor",
            row = 1,
            width = 0.35,
          },
        },
      },
      icons = {
        git = {
          commit = " ",
        },
      },
    },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  })
end
