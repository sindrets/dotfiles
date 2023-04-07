local M = {}

vim.env.GIT_DIR = vim.fn.expand("~/.dotfiles")

M.lsp_config = {
  settings = {
    Lua = {
      workspace = {
        library = {
          -- pl:realpath(vim.fn.stdpath("data") .. "/site/pack/packer/start/diffview.nvim"),
          pl:realpath(pl:expand("$HOME/Documents/dev/nvim/plugins/diffview.nvim/lua")),
        },
      },
    },
  },
}

return M
