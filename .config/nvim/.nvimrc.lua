local M = {}

M.lsp_config = {
  settings = {
    Lua = {
      workspace = {
        library = {
          (function(diffview_dev_path)
            return pl:readable(diffview_dev_path) and diffview_dev_path
              or pl:absolute("$HOME/.local/share/nvim/lazy/diffview.nvim/lua")
          end)(pl:absolute("$HOME/Documents/dev/nvim/plugins/diffview.nvim/lua")),
        },
      },
    },
  },
}

return M
