local lspconfig = require("lspconfig")

return {
  root_dir = lspconfig.util.root_pattern("lua"),
  settings = {
    Lua = {
      workspace = {
        library = {
          [vim.fn.fnamemodify("~/.config/nvim", ":p")] = true
        }
      }
    }
  }
}
