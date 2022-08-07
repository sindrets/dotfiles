local M = {}

M.setup = function(config)
  local lspconfig = require "lspconfig"
  local typescript = require "typescript"

  typescript.setup({
    disable_commands = false, -- prevent the plugin from creating Vim commands
    debug = false, -- enable debug logging for commands
    server = { -- pass options to lspconfig's setup method
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false -- 0.8 and later
        config.on_attach(client, bufnr)
      end
    },
  })

  lspconfig.eslint.setup(config)
  -- vim.api.nvim_exec([[
  --   augroup eslint_format
  --     au!
  --     au BufEnter *.ts,*.tsx,*.js,*.jsx nnoremap <buffer> <silent> <leader>f <Cmd>EslintFixAll<CR>
  --   augroup END
  -- ]], false)

  local null_ls = require "null-ls"
  null_ls.register(null_ls.builtins.diagnostics.stylelint.with {
    filetypes = { "typescript", "typescriptreact" },
    command = "./node_modules/.bin/stylelint",
    -- args = { "--formatter", "json", "--stdin", "$FILENAME" },
    condition = function(utils)
      return utils.root_has_file ".stylelintrc"
    end,
  })
  null_ls.register(null_ls.builtins.formatting.stylelint.with {
    filetypes = { "typescript", "typescriptreact" },
    command = "./node_modules/.bin/stylelint",
    condition = function(utils)
      -- Temp disable
      return false
      -- return utils.root_has_file ".stylelintrc"
    end,
  })
end

return M
