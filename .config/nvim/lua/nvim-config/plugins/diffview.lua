return function ()
  local cb = require'diffview.config'.diffview_callback
  local M = {}

  require'diffview'.setup {
    diff_binaries = false,
    use_icons = true,
    enhanced_diff_hl = true,
    file_panel = {
      position = "left",
      width = 35,
      height = 10,
    },
    key_bindings = {
      disable_defaults = false,
      view = {
        ["<tab>"]     = cb("select_next_entry"),
        ["<s-tab>"]   = cb("select_prev_entry"),
        ["<leader>e"] = cb("focus_files"),
        ["<leader>b"] = cb("toggle_files"),
        ["-"]         = cb("toggle_stage_entry"),
        ["<leader>s"] = "<Cmd>sp % <bar> setl nodiff<CR>"
      },
      file_panel = {
        ["j"]             = cb("next_entry"),
        ["<down>"]        = cb("next_entry"),
        ["k"]             = cb("prev_entry"),
        ["<up>"]          = cb("prev_entry"),
        ["<cr>"]          = cb("select_entry"),
        ["o"]             = cb("select_entry"),
        ["<2-LeftMouse>"] = cb("select_entry"),
        ["-"]             = cb("toggle_stage_entry"),
        ["S"]             = cb("stage_all"),
        ["U"]             = cb("unstage_all"),
        ["R"]             = cb("refresh_files"),
        ["<tab>"]         = cb("select_next_entry"),
        ["<s-tab>"]       = cb("select_prev_entry"),
        ["<leader>e"]     = cb("focus_files"),
        ["<leader>b"]     = cb("toggle_files"),
      }
    }
  }

  function M.apply_diff_tweaks()
    local StandardView = require'diffview.views.standard.standard_view'.StandardView
    vim.schedule(function ()
      local view = require'diffview.lib'.get_current_view()
      if view and view:instanceof(StandardView) then
        local curhl = vim.wo[view.left_winid].winhl
        vim.wo[view.left_winid].winhl = table.concat({
            "DiffAdd:DiffAddAsDelete",
            curhl ~= "" and curhl or nil
          }, ",")
      end
    end)
  end

  vim.api.nvim_exec([[
    augroup diffview_config
      au!
      " au TabNew * lua DiffviewConfig.apply_diff_tweaks()
    augroup END
  ]], false)

  _G.DiffviewConfig = M
end
