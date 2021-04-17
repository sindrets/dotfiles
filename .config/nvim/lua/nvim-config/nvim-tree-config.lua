local events = require'nvim-tree.events'

vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_gitignore = 0
vim.g.nvim_tree_width = 30
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_lsp_diagnostics = 1
vim.g.nvim_tree_auto_open = 0
vim.g.nvim_tree_folder_devicons = 1
vim.g.nvim_tree_special_files = {}
-- vim.g.nvim_tree_disable_keybindings = 1     -- Disable default keybindings
-- vim.g.nvim_tree_ignore = {"*.png", "*.jpg"}
vim.g.nvim_tree_show_icons = {
  git = 1,
  folders = 1,
  files = 1,
}

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
vim.g.nvim_tree_bindings = {
  ["<CR>"]           = tree_cb("edit"),
  ["o"]              = tree_cb("edit"),
  ["<2-LeftMouse>"]  = tree_cb("edit"),
  ["<2-RightMouse>"] = tree_cb("cd"),
  ["<C-]>"]          = tree_cb("cd"),
  ["v"]              = tree_cb("vsplit"),
  ["s"]              = tree_cb("split"),
  ["<C-x>"]          = "",
  ["<C-t>"]          = "",
  ["<BS>"]           = tree_cb("close_node"),
  ["<S-CR>"]         = tree_cb("close_node"),
  ["<Tab>"]          = tree_cb("preview"),
  ["I"]              = tree_cb("toggle_ignored"),
  ["H"]              = tree_cb("toggle_dotfiles"),
  ["R"]              = tree_cb("refresh"),
  ["a"]              = tree_cb("create"),
  ["d"]              = tree_cb("remove"),
  ["r"]              = tree_cb("rename"),
  ["<C-r>"]          = tree_cb("full_rename"),
  ["x"]              = tree_cb("cut"),
  ["y"]              = tree_cb("copy"),
  ["p"]              = tree_cb("paste"),
  ["[c"]             = tree_cb("prev_git_item"),
  ["]c"]             = tree_cb("next_git_item"),
  ["-"]              = tree_cb("dir_up"),
  ["q"]              = tree_cb("close"),
}

vim.g.nvim_tree_icons = {
  default = "",
  symlink = "",
  git = {
    unstaged = "",
    staged = "",
    unmerged = "",
    renamed = "",
    untracked = "",
    deleted = "",
    -- ignored = "!"
  },
  folder = {
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
    symlink_open = "",
  },
  lsp = {
    hint = "",
    info = "",
    warning = "",
    error = "",
  },
}

vim.api.nvim_exec([[
  hi! link NvimTreeGitNew diffAdded
  hi! link NvimTreeGitDeleted diffRemoved
  hi! link NvimTreeGitDirty GitDirty
  hi! link NvimTreeGitStaged diffAdded
  ]], false)

vim.api.nvim_command([[hi! link NvimTreeFolderIcon NvimTreeFolderName]])

vim.api.nvim_exec([[
  augroup InitNvimTree
    au!
    au DirChanged * lua NvimTreeUpdateCwd()
  augroup END
  ]], false)

function NvimTreeFocus()
  local view = require'nvim-tree.view'
  local lib = require'nvim-tree.lib'
  if view.win_open() then
    view.focus()
  else
    lib.open()
  end
end

function NvimTreeUpdateCwd()
  if vim.g.nvim_tree_ready == 1 then
    local view = require'nvim-tree.view'
    local lib = require'nvim-tree.lib'
    if view.win_open() then
      lib.change_dir(vim.fn.getcwd())
    end
  end
end

events.on_nvim_tree_ready(function ()
  vim.g.nvim_tree_ready = 1
end)
