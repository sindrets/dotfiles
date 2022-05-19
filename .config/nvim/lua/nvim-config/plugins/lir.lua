return function()
  local M = {}
  local utils = Config.common.utils
  local float = require("lir.float")
  local actions = require("lir.actions")
  local mark_actions = require("lir.mark.actions")
  local clipboard_actions = require("lir.clipboard.actions")

  require('lir').setup({
    show_hidden_files = true,
    devicons_enable = true,
    hide_cursor = true,
    mappings = {
      ['<CR>']  = actions.edit,
      ['o']     = actions.edit,
      ['l']     = actions.edit,
      ['<C-s>'] = actions.split,
      ['<C-v>'] = actions.vsplit,
      ['<C-t>'] = actions.tabedit,

      ['-']     = actions.up,
      ['h']     = actions.up,
      ['q']     = function()
        Config.lib.remove_buffer(true)
        if vim.w.lir_is_float then
          vim.cmd("wincmd q")
        end
      end,

      ['m']     = actions.mkdir,
      ['a']     = actions.newfile,
      ['r']     = actions.rename,
      ['<C-]>'] = actions.cd,
      ['gy']    = actions.yank_path,
      ['<C-h>'] = actions.toggle_show_hidden,
      ['d']     = actions.delete,

      ['t'] = mark_actions.toggle_mark,
      ['J'] = function()
        mark_actions.toggle_mark()
        vim.cmd('norm! j')
      end,
      ['K'] = function()
        mark_actions.toggle_mark()
        vim.cmd('norm! k')
      end,
      ['y'] = clipboard_actions.copy,
      ['x'] = clipboard_actions.cut,
      ['p'] = clipboard_actions.paste,
    },
    float = {
      winblend = 0,

      -- -- You can define a function that returns a table to be passed as the third
      -- -- argument of nvim_open_win().
      win_opts = function()
        -- local width = math.floor(vim.o.columns * 0.8)
        -- local height = math.floor(vim.o.lines * 0.8)
        -- return {
        --   border = require("lir.float.helper").make_border_opts({
        --     "+", "─", "+", "│", "+", "─", "+", "│",
        --   }, "Normal"),
        --   width = width,
        --   height = height,
        --   row = 1,
        --   col = math.floor((vim.o.columns - width) / 2),
        -- }
        return {
          border = "single",
        }
      end,
    },
  })

  require('lir.git_status').setup({
    show_ignored = true
  })

  function M.explore(path)
    local abs_path = vim.fn.expand(path or "%", ":p")
    if vim.fn.filereadable(abs_path) == 0 then
      abs_path = vim.fn.fnamemodify(vim.loop.cwd(), ":p")
    elseif vim.fn.isdirectory(abs_path) == 0 then
      abs_path = vim.fn.fnamemodify(abs_path, ":h")
    end
    vim.cmd("e " .. vim.fn.fnameescape(utils.path_remove_trailing(abs_path)))
  end

  function M.open_float(path)
    local abs_path
    if path then
      abs_path = utils.path_remove_trailing(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
    end
    float.init(abs_path or nil)
  end

  function M.toggle_float(path)
    local abs_path = vim.fn.expand(path or "%", ":p")
    if vim.fn.filereadable(abs_path) == 0 then
      abs_path = vim.fn.fnamemodify(vim.loop.cwd(), ":p")
    elseif vim.fn.isdirectory(abs_path) == 0 then
      abs_path = vim.fn.fnamemodify(abs_path, ":h")
    end
    float.toggle(abs_path and utils.path_remove_trailing(abs_path) or nil)
  end

  vim.api.nvim_exec([[
    command! -bar -nargs=? -complete=dir LirExplore call v:lua.Config.plugin.lir.explore(<f-args>)
    command! -bar -nargs=? -complete=dir LirFloat call v:lua.Config.plugin.lir.open_float(<f-args>)
  ]], false)

  Config.plugin.lir = M
end
