return function ()
  local lib = require("nvim-config.lib")
  local utils = Config.common.utils

  require("trouble").setup {
    height = 10, -- height of the trouble list
    icons = true, -- use dev-icons for filenames
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "", -- icon used for open folds
    fold_closed = "", -- icon used for closed folds
    action_keys = { -- key mappings for actions in the trouble list
      close = "q", -- close the list
      refresh = "R", -- manually refresh
      jump = "<cr>", -- jump to the diagnostic or open / close folds
      toggle_mode = "m", -- toggle between "workspace" and "document" mode
      toggle_preview = "P", -- toggle auto_preview
      preview = "p", -- preview the diagnostic location
      close_folds = "zM", -- close all folds
      cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
      open_folds = "zR", -- open all folds
      previous = "k", -- preview item
      next = "j" -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = false, -- automatically preview the location of the diagnostic. <esc> to close preview and go back
    signs = {
      -- icons / text used for a diagnostic
      error = "",
      warning = "",
      hint = "",
      information = ""
    },
    use_lsp_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
  }

  Config.fn.toggle_diagnostics = lib.create_buf_toggler(
    function ()
      return utils.find_buf_with_option("filetype", "Trouble", { no_hidden = true, tabpage = 0 })
    end,
    function ()
      vim.cmd("Trouble")
    end,
    function ()
      vim.cmd("wincmd p | TroubleClose")
    end,
    { focus = true, remember_height = true }
  )

  vim.api.nvim_exec([[
    augroup LspTroubleConfig
      au!
      au FileType Trouble setlocal cc=
    augroup END
    ]], false)
end
