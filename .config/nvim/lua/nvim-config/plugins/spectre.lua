return function ()
  require('spectre').setup({
  color_devicons = true,
  line_sep_start = '┌─────────────────────────────────────────',
  result_padding = '│  ',
  line_sep       = '└─────────────────────────────────────────',
  highlight = {
    ui = "String",
    search = "DiffChange",
    replace = "DiffText"
  },
  mapping={
    ['delete_line'] = {
      map = "dd",
      cmd = "<cmd>lua require('spectre').delete()<CR>",
      desc = "toggle current item"
    },
    ['enter_file'] = {
      map = "<cr>",
      cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
      desc = "goto current file"
    },
    ['send_to_qf'] = {
      map = "<c-q>",
      cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
      desc = "send all item to quickfix"
    },
    ['replace_cmd'] = {
      map = "<leader>c",
      cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
      desc = "input replace vim command"
    },
    ['show_option_menu'] = {
      map = "<leader>o",
      cmd = "<cmd>lua require('spectre').show_options()<CR>",
      desc = "show option"
    },
    ['run_replace'] = {
      map = "<leader>R",
      cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
      desc = "replace all"
    },
    ['change_view_mode'] = {
      map = "<leader>v",
      cmd = "<cmd>lua require('spectre').change_view()<CR>",
      desc = "change result view mode"
    },
    ['toggle_ignore_case'] = {
      map = "ti",
      cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
      desc = "toggle ignore case"
    },
    ['toggle_ignore_hidden'] = {
      map = "th",
      cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
      desc = "toggle search hidden"
    },
    -- you can put your mapping here it only use normal mode
  },
  find_engine = {
    -- rg is map with finder_cmd
    ['rg'] = {
      cmd = "rg",
      -- default args
      args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
      } ,
      options = {
        ['ignore-case'] = {
          value= "--ignore-case",
          icon="[I]",
          desc="ignore case"
        },
        ['hidden'] = {
          value="--hidden",
          desc="hidden file",
          icon="[H]"
        },
        -- you can put any option you want here it can toggle with
        -- show_option function
        }
      },
      ['ag'] = {
        cmd = "ag",
        -- default args
        args = {
          '--vimgrep',
          '-s'
        } ,
        options = {
          ['ignore-case'] = {
            value= "-i",
            icon="[I]",
            desc="ignore case"
          },
          ['hidden'] = {
            value="--hidden",
            desc="hidden file",
            icon="[H]"
          },
          -- you can put any option you want here it can toggle with
          -- show_option function
          },
        },
      },
      replace_engine={
        ['sed']={
          cmd = "sed",
          args = nil
        },
        options = {
          ['ignore-case'] = {
            value= "--ignore-case",
            icon="[I]",
            desc="ignore case"
          },
        }
      },
      default = {
        find = {
          --pick one of item in find_engine
          cmd = "ag",
          options = {"ignore-case"}
        },
        replace={
          --pick one of item in replace_engine
          cmd = "sed"
        }
      },
      replace_vim_cmd = "cfdo",
      is_open_target_win = true, --open file on opener window
      is_insert_mode = false,  -- start open panel on is_insert_mode
    })

  vim.cmd([[
    augroup SpectreConfig
    au!
    au FileType spectre_panel setlocal nolist
    augroup END
    ]])
end
