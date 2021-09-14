-- defaults:
-- ~/.local/share/nvim/site/pack/packer/start/nvim-web-devicons/lua/nvim-web-devicons.lua

return function ()
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
      ["m"] = {
        icon = "",
        color = "#599eff",
        name = "CModule"
      },
      ["tl"] = {
        icon = "",
        color = "#51a0cf",
        name = "Teal",
      }
    },
    default = false
  }
end
