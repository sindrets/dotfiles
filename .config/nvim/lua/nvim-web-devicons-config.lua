-- defaults:
-- ~/.vim/plug/nvim-web-devicons/lua/nvim-web-devicons.lua

require("nvim-web-devicons").setup {
  -- your personnal icons can go here (to override)
  -- DevIcon will be appended to `name`
  override = {
    ["xml"] = {
      icon = "",
      color = "#e37933",
      name = "Xml",
    },
    ["cs"] = {
      icon = "",
      color = "#0d5786",
      name = "Cs",
    },
  },
}
