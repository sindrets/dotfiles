return function ()
  local cb = require'diffview.config'.diffview_callback
  local M = {}

  require'diffview'.setup {
    diff_binaries = false,
    enhanced_diff_hl = true,
    use_icons = true,
    icons = {
      folder_closed = "",
      folder_open = "",
    },
    signs = {
      fold_closed = "",
      fold_open = "",
    },
    file_panel = {
      position = "left",
      width = 35,
      height = 10,
      listing_style = "tree",       -- One of 'list' or 'tree'
      tree_options = {              -- Only applies when listing_style is 'tree'
        flatten_dirs = true,
        folder_statuses = "only_folded"  -- One of 'never', 'only_folded' or 'always'.
      }
    },
    default_args = {
      DiffviewOpen = {},
      DiffviewFileHistory = {},
    },
    hooks = {
      view_opened = function(view)
        local DiffView = require("diffview.views.diff.diff_view").DiffView
        if view:instanceof(DiffView) then
          local watcher = vim.loop.new_fs_poll()
          ---@diagnostic disable-next-line: unused-local
          watcher:start(view.git_dir .. "/index", 1000, function(err, prev, cur)
            if not err then
              vim.schedule(function()
                vim.cmd("DiffviewRefresh")
              end)
            end
          end)

          ---@diagnostic disable-next-line: undefined-global
          DiffviewGlobal.emitter:on("view_closed", function(v)
            if v == view then
              watcher:stop()
            end
          end)
        end
      end,
    },
    key_bindings = {
      disable_defaults = false,
      view = {
        ["<tab>"]      = cb("select_next_entry"),
        ["<s-tab>"]    = cb("select_prev_entry"),
        ["gf"]         = cb("goto_file_edit"),
        ["<C-w><C-f>"] = cb("goto_file_split"),
        ["<C-w>gf"]    = cb("goto_file_tab"),
        ["<leader>e"]  = cb("focus_files"),
        ["<leader>b"]  = cb("toggle_files"),
      },
      file_panel = {
        ["j"]             = cb("next_entry"),
        ["<down>"]        = cb("next_entry"),
        ["k"]             = cb("prev_entry"),
        ["<up>"]          = cb("prev_entry"),
        ["<cr>"]          = cb("focus_entry"),
        ["o"]             = cb("select_entry"),
        ["<2-LeftMouse>"] = cb("select_entry"),
        ["-"]             = cb("toggle_stage_entry"),
        ["s"]             = cb("toggle_stage_entry"),
        ["S"]             = cb("stage_all"),
        ["U"]             = cb("unstage_all"),
        ["R"]             = cb("refresh_files"),
        ["<tab>"]         = cb("select_next_entry"),
        ["<s-tab>"]       = cb("select_prev_entry"),
        ["gf"]            = cb("goto_file_edit"),
        ["<C-w><C-f>"]    = cb("goto_file_split"),
        ["<C-w>gf"]       = cb("goto_file_tab"),
        ["<leader>e"]     = cb("focus_files"),
        ["<leader>b"]     = cb("toggle_files"),
      },
      file_history_panel = {
        ["g!"]            = cb("options"),            -- Open the option panel
        ["<C-A-d>"]       = cb("open_in_diffview"),   -- Open the entry under the cursor in a diffview
        ["y"]             = cb("copy_hash"),          -- Copy the commit hash of the entry under the cursor
        ["zR"]            = cb("open_all_folds"),
        ["zM"]            = cb("close_all_folds"),
        ["j"]             = cb("next_entry"),
        ["<down>"]        = cb("next_entry"),
        ["k"]             = cb("prev_entry"),
        ["<up>"]          = cb("prev_entry"),
        ["<cr>"]          = cb("focus_entry"),
        ["o"]             = cb("select_entry"),
        ["<2-LeftMouse>"] = cb("select_entry"),
        ["<tab>"]         = cb("select_next_entry"),
        ["<s-tab>"]       = cb("select_prev_entry"),
        ["gf"]            = cb("goto_file_edit"),
        ["<C-w><C-f>"]    = cb("goto_file_split"),
        ["<C-w>gf"]       = cb("goto_file_tab"),
        ["<leader>e"]     = cb("focus_files"),
        ["<leader>b"]     = cb("toggle_files"),
      },
      option_panel = {
        ["<tab>"] = cb("select"),
        ["q"]     = cb("close"),
      },
    }
  }

  _G.Config.diffview = M
end
