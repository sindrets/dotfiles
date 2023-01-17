return function ()
  local actions = require("diffview.actions")

  local utils = Config.common.utils

  local M = {}

  require('diffview').setup({
    diff_binaries = false,
    enhanced_diff_hl = true,
    git_cmd = { "git" },
    use_icons = true,
    show_help_hints = false,
    icons = {
      folder_closed = "",
      folder_open = "",
    },
    signs = {
      fold_closed = "",
      fold_open = "",
    },
    view = {
      default = {
        winbar_info = false,
      },
      merge_tool = {
        layout = "diff3_mixed",
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        winbar_info = false,
      },
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
        git = {
          single_file = {
            diff_merges = "combined",
            follow = true,
          },
          multi_file = {
            diff_merges = "first-parent",
          },
        },
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
      ---@param view StandardView
      view_opened = function(view)
        -- Highlight 'DiffChange' as 'DiffDelete' on the left, and 'DiffAdd' on
        -- the right.
        local function post_layout()
          utils.tbl_ensure(view, "winopts.diff2.a")
          utils.tbl_ensure(view, "winopts.diff2.b")
          view.winopts.diff2.a = utils.tbl_union_extend(view.winopts.diff2.a, {
            winhl = {
              "DiffChange:DiffAddAsDelete",
              "DiffText:DiffDeleteText",
            },
          })
          view.winopts.diff2.b = utils.tbl_union_extend(view.winopts.diff2.b, {
            winhl = {
              "DiffChange:DiffAdd",
              "DiffText:DiffAddText",
            },
          })
        end

        view.emitter:on("post_layout", post_layout)
        post_layout()
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
        ["cc"] = "<Cmd>Git commit <bar> wincmd J<CR>",
        ["ca"] = "<Cmd>Git commit --amend <bar> wincmd J<CR>",
        ["cs"] = "<Cmd>Git commit --squash <bar> wincmd J<CR>",
        ["c<Space>"] = ":Git commit ",
      },
      file_history_panel = {
        ["<cr>"] = actions.focus_entry,
        ["gf"] = actions.goto_file_edit,
      },
    }
  })

  _G.Config.plugin.diffview = M
end
