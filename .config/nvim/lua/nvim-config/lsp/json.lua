local null_ls = require("null-ls")
local lspconfig = require("lspconfig")

local schemas = {
  {
    description = "Package JSON file",
    fileMatch = { "package.json" },
    url = "https://json.schemastore.org/package.json",
  },
  {
    description = "TypeScript compiler configuration file",
    fileMatch = { "tsconfig.json", "tsconfig.*.json" },
    url = "http://json.schemastore.org/tsconfig",
  },
  {
    description = "Lerna config",
    fileMatch = { "lerna.json" },
    url = "http://json.schemastore.org/lerna",
  },
  {

    description = "Babel configuration",

    fileMatch = { ".babelrc.json", ".babelrc", "babel.config.json" },
    url = "http://json.schemastore.org/lerna",
  },
  {
    description = "ESLint config",

    fileMatch = { ".eslintrc.json", ".eslintrc" },
    url = "http://json.schemastore.org/eslintrc",
  },
  {
    description = "Prettier config",

    fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
    url = "http://json.schemastore.org/prettierrc",
  },
  {
    description = "Stylelint config",
    fileMatch = { ".stylelintrc", ".stylelintrc.json", "stylelint.config.json" },
    url = "http://json.schemastore.org/stylelintrc",
  },
}


local capabilities = vim.tbl_deep_extend("force", LspGetDefaultConfig()["capabilities"], {
  textDocument = {
    completion = {
      completionItem = {
        snippetSupport = true,
      },
    },
  },
})

lspconfig.jsonls.setup {
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    LspCommonOnAttach(client, bufnr)
  end,
  capabilities = capabilities,
  settings = {
    json = {
      schemas = schemas,
    },
  },
}

null_ls.register(null_ls.builtins.formatting.prettier.with {
  filetypes = { "json", "jsonc", "yaml", "markdown" },
})
