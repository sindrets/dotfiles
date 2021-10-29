return function ()
  local Color = require("nvim-config.color").Color
  local utils = require("nvim-config.utils")
  local M = {}

  require'neogit'.setup {
    disable_signs = false,
    disable_hint = true,
    disable_context_highlighting = false,
    status = {
      recent_commit_count = 10,
    },
    -- customize displayed signs
    signs = {
      -- { CLOSED, OPENED }
      section = { "", "" },
      item = { "", "" },
      hunk = { "", "" },
    },
    integrations = {
      diffview = true
    },
    -- override/add mappings
    mappings = {
      -- modify status buffer mappings
      status = {
        -- Adds a mapping with "B" as key that does the "BranchPopup" command
        ["B"] = "BranchPopup",
      }
    }
  }

  function M.fix_hl()
    local hl_fg_normal = utils.get_fg("Normal")
    local hl_bg_normal = utils.get_bg("Normal")

    local bg_normal = Color.from_hex(hl_bg_normal)
    local sign = bg_normal.lightness >= 0.5 and -1 or 1

    local bg_hunk_header_hl = bg_normal:shade(0.15 * sign)
    local bg_diff_context_hl = bg_normal:shade(0.075 * sign)

    utils.hi("NeogitHunkHeader", { bg = bg_diff_context_hl:to_css() })
    utils.hi("NeogitHunkHeaderHighlight", { bg = bg_hunk_header_hl:to_css() })
    utils.hi("NeogitDiffContextHighlight", { bg = bg_diff_context_hl:to_css() })
    utils.hi("NeogitDiffAddHighlight", {
      bg = utils.get_bg("DiffAdd", false) or bg_diff_context_hl:to_css(),
      fg = utils.get_fg("DiffAdd", false) or utils.get_fg("diffAdded") or hl_fg_normal,
      gui = utils.get_gui("DiffAdd", false),
    })
    utils.hi("NeogitDiffDeleteHighlight", {
      bg = utils.get_bg("DiffDelete", false) or bg_diff_context_hl:to_css(),
      fg = utils.get_fg("DiffDelete", false) or utils.get_fg("diffRemoved") or hl_fg_normal,
      gui = utils.get_gui("DiffDelete", false),
    })
  end

  vim.api.nvim_exec([[
    augroup neogit_config
      au!
      au FileType NeogitStatus setl nobl
      au FileType Neogit* setlocal nolist
      " au ColorScheme * call v:lua.Config.neogit.fix_hl()
      au FileType NeogitCommitView setl nobl
      " au BufEnter,FileType NeogitCommitView set eventignore+=CursorMoved
      " au BufLeave NeogitCommitView set eventignore-=CursorMoved
    augroup END
  ]], false)

  -- M.fix_hl()
  Config.neogit = M
end
