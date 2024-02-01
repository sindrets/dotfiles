-- defaults:
-- ~/.local/share/nvim/site/pack/packer/start/nvim-web-devicons/lua/nvim-web-devicons.lua

return function ()
  require("nvim-web-devicons").setup({
    -- your personnal icons can go here (to override)
    -- DevIcon will be appended to `name`
    override = {
      xml = {
        icon = "",
        color = "#e37933",
        name = "Xml",
      },
      cs = {
        icon = "󰌛",
        color = "#0d5786",
        name = "Cs",
      },
      m = {
        icon = "",
        color = "#599eff",
        name = "CModule",
      },
      tl = {
        icon = "",
        color = "#51a0cf",
        name = "Teal",
      },
      el = {
        icon = "󰘧",
        color = "#5D439C",
        name = "Elisp",
      },
      lisp = {
        icon = "󰘧",
        color = "#264B8B",
        name = "Lisp",
      },
      scm = {
        icon = "󰘧",
        color = "#264B8B",
        name = "Scheme",
      },
      rkt = {
        icon = "󰘧",
        color = "#264B8B",
        name = "Racket",
      },
      Makefile = {
        icon = "",
        color = "#6d8086",
        name = "Makefile",
      },
      makefile = {
        icon = "",
        color = "#6d8086",
        name = "Makefile",
      },
      lir_folder_icon = {
        icon = "",
        color = "#7ebae4",
        name = "LirFolderNode",
      },
      patch = {
        icon = "",
        color = "#41535b",
        name = "Patch",
      },
      hx = {
        icon = "",
        color = "#e37933",
        name = "Haxe",
      },
      hxml = {
        icon = "",
        color = "#6d8086",
        name = "HaxeBuildConfig",
      },
    },
    default = false
  })
end
