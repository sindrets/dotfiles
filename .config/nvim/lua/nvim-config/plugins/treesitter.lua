return function ()
  require("nvim-treesitter.configs").setup({
      ensure_installed = "maintained", -- one of "all", "maintained", or a list of languages
      highlight = {
        enable = true,               -- false will disable the whole extension
        disable = { "vim" },                -- list of language that will be disabled
      },
      -- incremental_selection = {
      --   enable = true,
      --   keymaps = {
      --     init_selection = '<CR>',
      --     scope_incremental = '<CR>',
      --     node_incremental = '<TAB>',
      --     node_decremental = '<S-TAB>',
      --   },
      -- },
    })
end
