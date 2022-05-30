return function ()
  local actions = require("diffview.actions")
  local lazy = require("nvim-config.lazy")

  ---@module "diffview.lib"
  local lib = lazy.require("diffview.lib")

  local utils = Config.common.utils

  local M = {}

  require('diffview').setup({
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
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 35,
      },
    },
    file_history_panel = {
      log_options = {
        max_count = 256,
        follow = false,
        all = false,
        merges = false,
        no_merges = false,
        reverse = false,
      },
      win_config = {
        position = "bottom",
        height = 16,
      },
    },
    commit_log_panel = {
      win_config = {},
    },
    default_args = {
      DiffviewOpen = {},
      DiffviewFileHistory = {},
    },
    hooks = {
      view_opened = function(view)
        -- Update diffviews whenever the index changes.
        -- TODO: should probably implement this in the plugin at some point.
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
              watcher:close()
            end
          end)
        end
      end,
      diff_buf_read = function(bufnr)
        -- Disable some performance heavy stuff in long files.
        if vim.api.nvim_buf_line_count(bufnr) >= 2500 then
          vim.cmd("IndentBlanklineDisable")
        end
      end,
      diff_buf_win_enter = function(_)
        local view = lib.get_current_view()
        ---@cast view StandardView

        -- Highlight 'DiffChange' as 'DiffDelete' on the left, and 'DiffAdd' on
        -- the right.
        if view then
          local curwin = vim.api.nvim_get_current_win()
          vim.schedule(function()
            if curwin == view.left_winid then
                utils.set_local(curwin, {
                  winhl = {
                    "DiffChange:DiffAddAsDelete",
                    "DiffText:DiffDeleteText",
                    opt = { method = "append" },
                  }
                })
            elseif curwin == view.right_winid then
              utils.set_local(curwin, {
                winhl = {
                  "DiffChange:DiffAdd",
                  "DiffText:DiffAddText",
                  opt = { method = "append" },
                }
              })
            end
          end)
        end
      end,
    },
    keymaps = {
      view = {
        ["gf"] = actions.goto_file_edit,
        ["-"] = actions.toggle_stage_entry,
      },
      file_panel = {
        ["<cr>"] = actions.focus_entry,
        ["s"] = actions.toggle_stage_entry,
        ["gf"] = actions.goto_file_edit,
      },
      file_history_panel = {
        ["<cr>"] = actions.focus_entry,
        ["gf"] = actions.goto_file_edit,
      },
    }
  })

  _G.Config.plugin.diffview = M
end
