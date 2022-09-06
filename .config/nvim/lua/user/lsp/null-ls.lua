local null_ls = require("null-ls")

-- code action sources
local code_actions = null_ls.builtins.code_actions
-- diagnostic sources
local diagnostics = null_ls.builtins.diagnostics
-- formatting sources
local formatting = null_ls.builtins.formatting

local common_config = {
  method = null_ls.methods.DIAGNOSTICS_ON_SAVE
}

local function with_common_config(builtin)
  builtin.with(common_config)
end

require("null-ls").setup({
  sources = {

    diagnostics.ansiblelint,
    with_common_config(diagnostics.markdownlint),
    with_common_config(diagnostics.stylelint),
    with_common_config(diagnostics.phpcs.with {
      command = "./vendor/bin/phpcs",
    }),
    with_common_config(diagnostics.phpstan.with {
      command = "./vendor/bin/phpstan",
      -- condition = function(utils)
      --   return utils.root_has_file "phpstan.neon"
      -- end,
    }),
    with_common_config(diagnostics.yamllint),
    with_common_config(diagnostics.zsh),


    formatting.prettier,
    formatting.stylelint.with {
      filetypes = { "scss", "less", "css", "sass", "typescript", "typescriptreact" },
      command = "./node_modules/.bin/stylelint",
    },
    formatting.phpcbf.with {
      command = "./vendor/bin/phpcbf",
    },
    formatting.phpcsfixer.with {
      args = {
        "--no-interaction",
        "--quiet",
        "--config=" .. vim.fn.expand("~/.config/phpcs/.php-cs-fixer.php"),
        "fix",
        "$FILENAME",
      },
    },
    formatting.mdformat
  }
})
