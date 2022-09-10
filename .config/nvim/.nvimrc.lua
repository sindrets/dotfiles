local M = {}

vim.env.GIT_DIR = vim.fn.expand("~/.dotfiles")

M.lsp_config = {
  settings = {
    Lua = {
      workspace = {
        library = {
          pl:realpath(vim.fn.stdpath("data") .. "/site/pack/packer/start/diffview.nvim"),
        },
      },
    },
  },
}

return M
