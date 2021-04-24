local events = require'nvim-tree.events'
local M = {}

vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_gitignore = 0
vim.g.nvim_tree_width = 30
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_lsp_diagnostics = 1
vim.g.nvim_tree_auto_open = 0
vim.g.nvim_tree_hijack_netrw = 0
vim.g.nvim_tree_disable_netrw = 0
vim.g.nvim_tree_folder_devicons = 1
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_special_files = {}
vim.g.nvim_tree_disable_keybindings = 1     -- Disable default keybindings
vim.g.nvim_tree_highlight_opened_files = false
-- vim.g.nvim_tree_window_picker_chars = "QWERTYUIOPASDFGHJKLZXCVBNM1234567890"
vim.g.nvim_tree_window_picker_chars = "aoeuidhtnsgcrld;qjkxbmwv"
vim.g.nvim_tree_show_icons = {
  git = 1,
  folders = 1,
  files = 1,
}
-- vim.g.nvim_tree_ignore = {"*.png", "*.jpg"}

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
    ignored = "◌"
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

local tree_cb = require'nvim-tree.config'.nvim_tree_callback
local bindings = {
  ["<CR>"]           = tree_cb("edit"),
  ["o"]              = ":lua NvimTreeXdgOpen()<CR>",
  ["<2-LeftMouse>"]  = tree_cb("edit"),
  ["<2-RightMouse>"] = tree_cb("cd"),
  ["<C-]>"]          = tree_cb("cd"),
  ["v"]              = tree_cb("vsplit"),
  ["s"]              = tree_cb("split"),
  ["<BS>"]           = tree_cb("close_node"),
  ["<S-CR>"]         = tree_cb("close_node"),
  ["K"]              = tree_cb("first_sibling"),
  ["J"]              = tree_cb("last_sibling"),
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

local function setup_bindings(buf_id)
  for key, cb in pairs(bindings) do
    vim.api.nvim_buf_set_keymap(buf_id, "n", key, cb, { noremap = true, silent = true })
  end
end

function M.custom_setup()
  local buf_id = vim.api.nvim_get_current_buf()
  local success, custom_setup_done = pcall(vim.api.nvim_buf_get_var, buf_id, "custom_setup_done")

  if success and custom_setup_done == 1 then
    return
  end

  vim.api.nvim_buf_set_var(buf_id, "custom_setup_done", 1)
  setup_bindings(buf_id)
end

function M.focus()
  local view = require'nvim-tree.view'
  local lib = require'nvim-tree.lib'
  if view.win_open() then
    view.focus()
  else
    lib.open()
  end
end

function M.toggle_no_focus()
  local lib = require'nvim-tree.lib'
  local view = require'nvim-tree.view'
  if view.win_open() then
    view.close()
  else
    lib.open()
    vim.cmd("wincmd p")
  end
end

function M.update_cwd()
  if vim.g.nvim_tree_ready == 1 then
    local view = require'nvim-tree.view'
    local lib = require'nvim-tree.lib'
    if view.win_open() then
      lib.change_dir(vim.fn.getcwd())
    end
  end
end

function M.xdg_open()
  local lib = require'nvim-tree.lib'
  local node = lib.get_node_at_cursor()
  if node then
    vim.fn.jobstart("xdg-open '" .. node.absolute_path .. "' &", { detach = true })
  end
end

function M.global_bufenter()
  local buf_path = vim.fn.expand('%')
  if vim.fn.isdirectory(buf_path) == 1 then
    vim.cmd("cd " .. buf_path)
    vim.cmd("NvimTreeOpen")
    M.refresh_needed = true
  end
end

events.on_nvim_tree_ready(function ()
  if M.refresh_needed then
    vim.cmd("NvimTreeRefresh")
    M.refresh_needed = false
  end

  vim.g.nvim_tree_ready = 1
end)

vim.api.nvim_exec([[
  hi! link NvimTreeGitNew diffAdded
  hi! link NvimTreeGitDeleted diffRemoved
  hi! link NvimTreeGitDirty GitDirty
  hi! link NvimTreeGitStaged diffAdded
  hi! link NvimTreeFolderIcon NvimTreeFolderName
  ]], false)

vim.api.nvim_exec([[
  augroup NvimTreeConfig
    au!
    au FileType NvimTree lua NvimTreeConfig.custom_setup()
    au DirChanged * lua NvimTreeConfig.update_cwd()
    au BufEnter * lua NvimTreeConfig.global_bufenter()
  augroup END
  ]], false)

_G.NvimTreeConfig = M
