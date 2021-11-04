return function ()
  require("nvim-treesitter.configs").setup({
      ensure_installed = "maintained", -- one of "all", "maintained", or a list of languages
      highlight = {
        enable = true,               -- false will disable the whole extension
        disable = { "vim", "c" },                -- list of language that will be disabled
      },
    })
end
