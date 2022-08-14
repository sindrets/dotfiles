local lspconfig = require "lspconfig"
local HOME = os.getenv('HOME')

local M = {}

M.setup = function(config)
  lspconfig.intelephense.setup {
    on_attach = function(client, bufnr)
      -- null-ls handles formatting using phpcbf or phpcsfixer
      client.server_capabilities.documentFormattingProvider = false
      -- client.resolved_capabilities.document_range_formatting = false

      config.on_attach(client, bufnr)
    end,
    capabilities = config["capabilities"],
    flags = {
      debounce_text_changes = 300,
    },
    -- init_options = {
    --   clearCache = true,
    -- },
    settings = {
      intelephense = {
        environment = {
          phpVersion = "8.0",
        },
      },
    },
  }

  local null_ls = require "null-ls"

  null_ls.register(null_ls.builtins.diagnostics.phpcs.with {
    command = "./vendor/bin/phpcs",
  })

  null_ls.register(null_ls.builtins.formatting.phpcbf.with {
    command = "./vendor/bin/phpcbf",
  })

  null_ls.register(null_ls.builtins.formatting.phpcsfixer.with {
    args = {
      "--no-interaction",
      "--quiet",
      "--config=" .. HOME .. "/.config/phpcs/.php-cs-fixer.php",
      "fix",
      "$FILENAME",
    },
  })

  null_ls.register(null_ls.builtins.diagnostics.phpstan.with {
    command = "./vendor/bin/phpstan",
    condition = function(utils)
      return utils.root_has_file "phpstan.neon"
    end,
  })
end

return M
