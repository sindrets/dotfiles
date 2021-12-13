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
          ["<c-q>"] = actions.send_to_qflist + actions.open_qflist,
        },
        n = {},
      },
    },
    pickers = {
      find_files = {
        results_title = false,
      },
      git_files = {
        results_title = false,
      },
      git_commits = {
        mappings = {
          i = {
            ["<C-M-d>"] = function()
              -- Open in diffview
              local selected_entry = action_state.get_selected_entry()
              local value = selected_entry.value
              -- close Telescope window properly prior to switching windows
              vim.api.nvim_win_close(0, true)
              vim.cmd("stopinsert")
              vim.schedule(function()
                vim.cmd(("DiffviewOpen %s^!"):format(value))
              end)
            end,
          }
        }
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
      }
    }
  }

  -- Load extensions
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('media_files')
end
