return function()
  local nvim_treesitter = require("nvim-treesitter")

  local pb = Config.common.pb

  local custom_parsers = {
    haxe = {
      install_info = {
        url = "https://github.com/vantreeseba/tree-sitter-haxe",
        -- optional entries:
        branch = "main",
      },
      filetype = "haxe",
    },
  }

  vim.api.nvim_create_autocmd('User', {
    pattern = 'TSUpdate',
    callback = function()
      local parsers = require('nvim-treesitter.parsers')
      for lang, config in pairs(custom_parsers) do
        parsers[lang] = config
      end
    end,
  })

  -- Map filetypes to TS parsers
  for ft, parser in pairs({
    handlebars = "glimmer",
  }) do
    vim.treesitter.language.register(ft, parser)
  end

  nvim_treesitter.setup({
    -- FIXME: This isn't an option anymore
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
  })

  nvim_treesitter.install(
    pb.iter(nvim_treesitter.get_available(2) --[[@as string[] ]])
      :filter(function(lang)
        return not vim.tbl_contains({
          "luap",
          "comment",
        }, lang)
      end)
      :chain(pb.keys(custom_parsers))
      :totable()
  )
end
