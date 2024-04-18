local omnisharp_ext = require("omnisharp_extended")

require("lspconfig").omnisharp.setup(Config.lsp.create_config({
  cmd = { "/usr/bin/omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) },
  filetypes = { "cs", "vb" },
  init_options = {},
  -- root_dir = lspconfig.util.root_pattern(".csproj", ".sln"),
  -- root_dir = vim.fn.getcwd
  handlers = {
    ["textDocument/definition"] = omnisharp_ext.definition_handler,
    ["textDocument/typeDefinition"] = omnisharp_ext.type_definition_handler,
    ["textDocument/references"] = omnisharp_ext.references_handler,
    ["textDocument/implementation"] = omnisharp_ext.implementation_handler,
  },
  settings = {
    RoslynExtensionsOptions = {
      enableDecompilationSupport = true,
    },
  },
}))
