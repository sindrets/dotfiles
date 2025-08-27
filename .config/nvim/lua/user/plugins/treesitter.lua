return function()
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

  parser_config.haxe = {
    install_info = {
      url = "https://github.com/vantreeseba/tree-sitter-haxe",
      files = { "src/parser.c" },
      -- optional entries:
      branch = "main",
    },
    filetype = "haxe",
  }

  -- Map filetypes to TS parsers
  for ft, parser in pairs({
    handlebars = "glimmer",
  }) do
    vim.treesitter.language.register(ft, parser)
  end

  require("nvim-treesitter.configs").setup({
    ensure_installed = "all",
    ignore_install = {
      "luap",
      "comment",
    },
    indent = { enable = true },
    highlight = {
      -- false will disable the whole extension
      enable = true,
      disable = function(lang, bufnr)
        local kb = Config.common.utils.buf_get_size(bufnr)

        if kb > 320 then return true end

        return vim.tbl_contains({
          -- "vim",
          -- "help",
          -- "markdown", -- NOTE: Parser seems immature. Revisit later.
          -- "c", -- NOTE: Performance is abysmal in files of any notable length.
          -- "cpp",
          "latex",
          "comment",
          "haxe",
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
