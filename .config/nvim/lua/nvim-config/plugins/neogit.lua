return function ()
  local M = {}

  require('neogit').setup {
    disable_signs = false,
    disable_hint = true,
    disable_context_highlighting = false,
    disable_builtin_notifications = true,
    status = {
      recent_commit_count = 10,
    },
    -- customize displayed signs
    signs = {
      -- { CLOSED, OPENED }
      section = { "", "" },
      item = { "", "" },
      hunk = { "", "" },
    },
    integrations = {
      diffview = true
    },
    sections = {
      recent = {
        folded = false,
      },
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

  Config.common.au.declare_group("neogit_config", {}, {
    { "FileType", pattern = "Neogit*", command = "setl nolist" },
    { { "BufEnter", "FileType" }, pattern = "NeogitCommitView", command = "setl eventignore+=CursorMoved" },
    { "BufLeave", pattern = "NeogitCommitView", command = "setl eventignore-=CursorMoved" },
  })

  Config.plugin.neogit = M
end
