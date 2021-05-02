local cb = require'diffview.config'.diffview_callback

require'diffview'.setup {
  diff_binaries = false,
  file_panel = {
    width = 35,
    use_icons = true
  },
  key_bindings = {
    view = {
      ["<tab>"]     = cb("select_next_entry"),
      ["<s-tab>"]   = cb("select_prev_entry"),
      ["<leader>e"] = cb("focus_files"),
      ["<leader>b"] = cb("toggle_files"),
    },
    file_panel = {
      ["j"]         = cb("next_entry"),
      ["<down>"]    = cb("next_entry"),
      ["k"]         = cb("prev_entry"),
      ["<up>"]      = cb("prev_entry"),
      ["<cr>"]      = cb("select_entry"),
      ["o"]         = cb("select_entry"),
      ["R"]         = cb("refresh_files"),
      ["<tab>"]     = cb("select_next_entry"),
      ["<s-tab>"]   = cb("select_prev_entry"),
      ["<leader>e"] = cb("focus_files"),
      ["<leader>b"] = cb("toggle_files"),
    }
  }
}
