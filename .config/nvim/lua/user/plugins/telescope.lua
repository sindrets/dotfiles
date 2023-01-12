return function ()
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  require('telescope').setup{
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case'
      },
      prompt_prefix = "  ",
      selection_caret = "➤ ",
      entry_prefix = "  ",
      initial_mode = "insert",
      results_title = false,
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
        preview_cutoff = 120,
        width = 0.75,
        horizontal = {
          mirror = false,
        },
        vertical = {
          mirror = false,
        },
      },
      path_display = {
        "absolute"
      },
      file_sorter =  require'telescope.sorters'.get_fuzzy_file,
      file_ignore_patterns = {},
      generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
      winblend = 0,
      border = {},
      borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      color_devicons = true,
      use_less = true,
      set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker,
      mappings = {
        i = {
          ["<c-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<c-b>"] = actions.preview_scrolling_up,
          ["<c-f>"] = actions.preview_scrolling_down,
          ["<c-j>"] = false,
        },
        n = {
          ["<c-b>"] = actions.preview_scrolling_up,
          ["<c-f>"] = actions.preview_scrolling_down,
        },
      },
    },
    pickers = {
      find_files = {
        results_title = false,
      },
      git_files = {
        results_title = false,
      },
      git_status = {
        expand_dir = false,
      },
      git_commits = {
        mappings = {
          i = {
            ["<C-M-d>"] = function()
              -- Open in diffview
              local entry = action_state.get_selected_entry()
              -- close Telescope window properly prior to switching windows
              vim.api.nvim_win_close(0, true)
              vim.cmd("stopinsert")
              vim.schedule(function()
                vim.cmd(("DiffviewOpen %s^!"):format(entry.value))
              end)
            end,
          }
        }
      },
      current_buffer_fuzzy_find = {
        tiebreak = function(a, b)
          -- Sort tiebreaks by line number
          return a.lnum < b.lnum
        end,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = false, -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                         -- the default case_mode is "smart_case"
      },
      media_files = {
        -- filetypes whitelist
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = { "png", "webp", "jpg", "jpeg", "mp4", "webm", "pdf" },
        find_cmd = "fd"
        -- find_cmd = "rg" -- find command (defaults to `fd`)
      },
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({})
      },
    }
  }

  -- Load extensions
  require('telescope').load_extension('notify')
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('media_files')
  require('telescope').load_extension('ui-select')
end
