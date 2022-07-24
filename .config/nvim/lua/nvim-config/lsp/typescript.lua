local M = {}

M.setup = function(config)
  local lspconfig = require "lspconfig"

  lspconfig.tsserver.setup {
    init_options = require("nvim-lsp-ts-utils").init_options,
    on_attach = function(client, bufnr)
      -- disable tsserver formatting if you plan on formatting via null-ls
      client.server_capabilities.documentFormattingProvider = false

      local ts_utils = require "nvim-lsp-ts-utils"

      ts_utils.setup {
        -- debug = true,
        enable_import_on_completion = true,
        import_all_scan_buffers = 100,

        update_imports_on_move = true,
        -- filter out dumb module warning
        filter_out_diagnostics_by_code = { 80001 },

        -- inlay hints
        auto_inlay_hints = true, -- getting many annoynig errors
        inlay_hints_highlight = "Comment",
      }

      ts_utils.setup_client(client)
      config.on_attach(client, bufnr)
    end,
    capabilities = config["capabilities"],
  }

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
