return function ()
  local hi_link = Config.common.hl.hi_link

  require('gitsigns').setup {
    signs = {
      add = {
        hl = 'GitSignsAdd'   , text = '▍', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'
      },
      change = {
        hl = 'GitSignsChange', text = '▍', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'
      },
      delete = {
        hl = 'GitSignsDelete', text = '▍', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'
      },
      changedelete = {
        hl = 'GitSignsChange', text = '▍', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'
      },
      topdelete = {
        hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'
      },
    },
    numhl = false,
    linehl = false,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    diff_opts = {
      algorithm = "histogram",
      internal = true,
      indent_heuristic = true,
    },
    sign_priority = 6,
    update_debounce = 250,
    status_formatter = nil, -- Use default
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, { expr = true })

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, { expr = true })

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk)
      map("n", "<leader>hr", gs.reset_hunk)
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end)
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end)
      map("n", "<leader>hS", gs.stage_buffer)
      map("n", "<leader>hu", gs.undo_stage_hunk)
      -- map("n", "<leader>hR", gs.reset_buffer)
      map("n", "<leader>d", gs.preview_hunk)
      map("n", "<leader>hb", function() gs.blame_line{full=true} end)
      map("n", "<leader>tb", gs.toggle_current_line_blame)
      -- map("n", "<leader>hd", gs.diffthis)
      -- map("n", "<leader>hD", function() gs.diffthis("~") end)
      map("n", "<leader>td", gs.toggle_deleted)

      -- Text object
      map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end
  }

  hi_link("GitSignsAdd", "diffAdded", { default = true })
  hi_link("GitSignsChange", "diffChanged", { default = true })
  hi_link("GitSignsDelete", "diffRemoved", { default = true })
end
