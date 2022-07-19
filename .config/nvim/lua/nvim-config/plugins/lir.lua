return function()
  local actions = require("lir.actions")
  local clipboard_actions = require("lir.clipboard.actions")
  local float = require("lir.float")
  local mark_actions = require("lir.mark.actions")

  local pl = Config.common.utils.pl

  local M = {}

  actions.reload = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("edit")
    vim.fn.cursor(pos[1], 0)
  end

  require('lir').setup({
    show_hidden_files = true,
    devicons_enable = true,
    hide_cursor = true,
    mappings = {
      ['R']     = actions.reload,
      ['<CR>']  = actions.edit,
      ['o']     = actions.edit,
      ['l']     = actions.edit,
      ['<C-s>'] = actions.split,
      ['<C-v>'] = actions.vsplit,
      ['<C-t>'] = actions.tabedit,

      ['-'] = actions.up,
      ['h'] = actions.up,
      ['q'] = function()
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

  -- require('lir.git_status').setup({
  --   show_ignored = true
  -- })

  function M.explore(path)
    local abs_path = pl:absolute(pl:vim_expand(path or "%"))
    if not (pl:readable(abs_path) or pl:readable(pl:parent(abs_path))) then
      abs_path = pl:absolute(uv.cwd())
    elseif not pl:is_directory(abs_path) then
      abs_path = pl:parent(abs_path)
    end
    vim.cmd("e " .. vim.fn.fnameescape(abs_path))
  end

  function M.open_float(path)
    local abs_path
    if path then
      abs_path = pl:absolute(pl:vim_expand(path))
    end
    float.init(abs_path or nil)
  end

  function M.toggle_float(path)
    local abs_path = pl:absolute(pl:vim_expand(path or "%"))
    if not (pl:readable(abs_path) or pl:readable(pl:parent(abs_path))) then
      abs_path = pl:absolute(uv.cwd())
    elseif not pl:is_directory(abs_path) then
      abs_path = pl:parent(abs_path)
    end
    float.toggle(abs_path or nil)
  end

  vim.api.nvim_create_user_command("LirExplore", function(state)
    M.explore(state.fargs[1] ~= "" and state.fargs[1] or nil)
  end, {
    complete = "dir",
    bar = true,
    nargs = "?",
  })
  vim.api.nvim_create_user_command("LirFloat", function(state)
    M.open_float(state.fargs[1] ~= "" and state.fargs[1] or nil)
  end, {
    complete = "dir",
    bar = true,
    nargs = "?",
  })

  Config.plugin.lir = M
end
