return function ()
  require("nvim-treesitter.configs").setup({
    ensure_installed = "all",
    highlight = {
      -- false will disable the whole extension
      enable = true,
      -- list of language that will be disabled
      disable = {
        "vim",
        "help",
        -- "markdown", -- NOTE: Parser seems immature. Revisit later.
        "c", -- NOTE: Performance is abysmal in files of any notable length.
        "cpp",
      },
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
