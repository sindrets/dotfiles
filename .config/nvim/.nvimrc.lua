local lazy = require("user.lazy")

vim.env.GIT_DIR = vim.fn.expand("~/.dotfiles")

return lazy.wrap({}, function(_)
  return {
    lsp_config = {
      root_dir = require("lspconfig").util.root_pattern("lua"),
      settings = {
        Lua = {
          workspace = {
            library = {
              vim.fn.fnamemodify("~/.config/nvim", ":p"),
            },
          },
        },
      },
    },
  }
end)
