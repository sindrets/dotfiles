return function ()
  require'neogit'.setup {
    disable_signs = false,
    disable_context_highlighting = false,
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

  vim.api.nvim_exec([[
    augroup neogit_config
      au FileType NeogitStatus setl nobl
      au FileType Neogit* setlocal nolist
    augroup END
  ]], false)
end
