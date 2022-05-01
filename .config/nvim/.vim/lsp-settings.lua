return {
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
