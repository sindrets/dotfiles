return function()
  local utils = Config.common.utils

  local prettier = { "prettierd", "prettier" }

  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform will run multiple formatters sequentially
      python = { "isort", "black" },
      -- Use a sub-list to run only the first available formatter
      javascript = utils.vec_join({}, { prettier }),
      javascriptreact = utils.vec_join({}, { prettier }),
      typescript = utils.vec_join({}, { prettier }),
      typescriptreact = utils.vec_join({}, { prettier }),
      css = utils.vec_join({}, { prettier }),
      scss = utils.vec_join({}, { prettier }),
      sass = utils.vec_join({}, { prettier }),
      html = utils.vec_join({}, { prettier }),
      markdown = utils.vec_join({}, { prettier }),
      json = { "jq" },
    },
  })

  vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

  Config.common.au.declare_group("user.conform.nvim", {}, {
    {
      "LspAttach",
      callback = function()
        vim.opt_local.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    }
  })
end
