return function ()
  local actions = require("diffview.actions")

  local M = {}

  require('diffview').setup({
    diff_binaries = false,
    enhanced_diff_hl = false, -- Set up hihglights in the hooks instead
    git_cmd = { "git" },
    hg_cmd = { "chg" },
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
        -- layout = "diff1_inline",
        winbar_info = false,
      },
      merge_tool = {
        layout = "diff3_mixed",
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        -- layout = "diff1_inline",
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
    default_args = {
      DiffviewOpen = {},
      DiffviewFileHistory = {},
    },
    hooks = {
      ---@diagnostic disable-next-line: unused-local
      diff_buf_win_enter = function(bufnr, winid, ctx)
        -- Highlight 'DiffChange' as 'DiffDelete' on the left, and 'DiffAdd' on
        -- the right.
        if ctx.layout_name:match("^diff2") then
          if ctx.symbol == "a" then
            vim.opt_local.winhl = table.concat({
              "DiffAdd:DiffviewDiffAddAsDelete",
              "DiffDelete:DiffviewDiffDelete",
              "DiffChange:DiffAddAsDelete",
              "DiffText:DiffDeleteText",
            }, ",")
          elseif ctx.symbol == "b" then
            vim.opt_local.winhl = table.concat({
              "DiffDelete:DiffviewDiffDelete",
              "DiffChange:DiffAdd",
              "DiffText:DiffAddText",
            }, ",")
          end
        end
      end,
    },
    keymaps = {
      view = {
        ["-"] = actions.toggle_stage_entry,
      },
      file_panel = {
        ["<cr>"] = actions.focus_entry,
        ["s"] = actions.toggle_stage_entry,
        ["cc"] = "<Cmd>Git commit <bar> wincmd J<CR>",
        ["ca"] = "<Cmd>Git commit --amend <bar> wincmd J<CR>",
        ["c<Space>"] = ":Git commit ",
      },
      file_history_panel = {
        ["<cr>"] = actions.focus_entry,
      },
    }
  })

  _G.Config.plugin.diffview = M
end
