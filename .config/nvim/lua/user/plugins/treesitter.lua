return function ()
  local api = vim.api

  require("nvim-treesitter.configs").setup({
    ensure_installed = "all",
    highlight = {
      -- false will disable the whole extension
      enable = true,
      disable = function(lang, bufnr)
        if api.nvim_buf_line_count(bufnr) > 10000 then return true end
        return vim.tbl_contains({
          -- "vim",
          -- "help",
          -- "markdown", -- NOTE: Parser seems immature. Revisit later.
          "c", -- NOTE: Performance is abysmal in files of any notable length.
          "cpp",
          "latex",
        }, lang)
      end,
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
