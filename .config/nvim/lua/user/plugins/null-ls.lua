return function()
  local nls = require("null-ls")
  local builtins = nls.builtins

  nls.setup({
    sources = {
      builtins.formatting.raco_fmt.with({
        filetypes = { "racket", "scheme" },
      }),
      builtins.formatting.prettier,
    },
  })
end
