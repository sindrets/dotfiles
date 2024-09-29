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
        disable_diagnostics = false,
        winbar_info = false,
      },
      merge_tool = {
        layout = "diff3_mixed",
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        -- layout = "diff1_inline",
        disable_diagnostics = false,
        winbar_info = false,
      },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = function()
        local editor_width = vim.o.columns
        return {
          position = "left",
          width = editor_width >= 247 and 45 or 35,
        }
      end,
    },
    file_history_panel = {
      log_options = {
        git = {
          single_file = {
            diff_merges = "first-parent",
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
      diff_buf_read = function()
        vim.opt_local.wrap = false
      end,
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
        { "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
        { "n", "gd", function () actions.goto_file_edit(); vim.lsp.buf.definition() end },
      },
      file_panel = {
        { "n", "<cr>", actions.focus_entry, { desc = "Focus the selected entry" } },
        { "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
        { "n", "cc",  "<Cmd>Git commit <bar> wincmd J<CR>", { desc = "Commit staged changes" } },
        { "n", "ca",   "<Cmd>Git commit --amend <bar> wincmd J<CR>", { desc = "Amend the last commit" } },
        { "n", "c<space>",  ":Git commit ", { desc = "Populate command line with \":Git commit \"" } },
        { "n", "rr",  "<Cmd>Git rebase --continue <bar> wincmd J<CR>", { desc = "Continue the current rebase" } },
        { "n", "re",  "<Cmd>Git rebase --edit-todo <bar> wincmd J<CR>", { desc = "Edit the current rebase todo list." } },
        {
          "n", "[c",
          actions.view_windo(function(_, sym)
            if sym == "b" then vim.cmd("norm! [c") end
          end)
        },
        {
          "n", "]c",
          actions.view_windo(function(_, sym)
            if sym == "b" then vim.cmd("norm! ]c") end
          end)
        },
        {
          "n", "do",
          actions.view_windo(function(_, sym)
            if sym == "b" then vim.cmd("norm! do") end
          end)
        },
        {
          "n", "dp",
          actions.view_windo(function(_, sym)
            if sym == "b" then vim.cmd("norm! dp") end
          end)
        },
      },
      file_history_panel = {
        { "n", "[n", actions.select_prev_commit },
        { "n", "]n", actions.select_next_commit },
        { "n", "<cr>", actions.focus_entry, { desc = "Focus the selected entry" } },
      },
    }
  })

  _G.Config.plugin.diffview = M
end
