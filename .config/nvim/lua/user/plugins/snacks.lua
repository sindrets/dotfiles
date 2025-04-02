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

  vim.ui.select = Snacks.picker.select
end
