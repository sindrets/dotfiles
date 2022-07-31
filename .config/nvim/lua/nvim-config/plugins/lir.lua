return function()
  local actions = require("lir.actions")
  local clipboard_actions = require("lir.clipboard.actions")
  local float = require("lir.float")
  local lazy = require("nvim-config.lazy")
  local lir = require("lir")
  local mark_actions = require("lir.mark.actions")

  ---@module "diffview.arg_parser"
  local arg_parser = lazy.require("diffview.arg_parser")

  local pl = Config.common.utils.pl
  local utils = Config.common.utils

  local M = {}

  local function cd(path)
    vim.cmd("noau cd " .. vim.fn.fnameescape(path))
  end

  ---Bring the cursor to the item matching the given name.
  ---@param name string
  local function highlight_item(name)
    local ctx = lir.get_context()
    local rel_path = pl:relative(name, ctx.dir)

    local lnum = ctx:indexof(pl:explode(rel_path)[1])
    if lnum then
      utils.set_cursor(0, lnum, 0)
    end
  end

  function actions.reload()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("edit")
    utils.set_cursor(0, pos[1], 0)
  end

  ---Move a file, close all its currently open buffers, and bring the cursor to
  ---the moved item.
  function actions.move()
    local ctx = lir.get_context()
    local cur = ctx:current()
    local old_name = string.gsub(cur.value, pl.sep .. "$", "")
    local old_dir = uv.cwd()
    local old_path = cur.fullpath

    cd(ctx.dir)

    utils.input("Move: ", {
      completion = "file",
      default = old_name,

      callback = function(new_name)
        cd(old_dir)
        utils.clear_prompt()

        if new_name == nil or new_name == old_name then
          return
        end

        -- If target is a directory, move the file into the directory.
        -- Makes it work like linux `mv`
        local stat = uv.fs_stat(new_name)
        if stat and stat.type == "directory" then
          new_name = pl:join(new_name, old_name)
        end

        -- Delete any currently open buffers 
        local bufnr = utils.find_file_buffer(old_path)
        if bufnr then
          Config.lib.remove_buffer(false, bufnr)
        end

        local ok = uv.fs_rename(pl:join(ctx.dir, old_name), pl:join(ctx.dir, new_name))
        actions.reload()

        if not ok then
          utils.err("Rename failed!")
          return
        end

        highlight_item(new_name)
      end
    })
  end

  ---Create the path structures described by the given path arguments.
  ---Intermediate directories are created as necessary. Create empty
  ---directories by ending a path with a "/". Arguments are separated by
  ---whitespace, and may be quoted if they contain whitespace.
  ---
  ---```sh
  ---Create paths: foo/bar/baz "some/path with/whitespace" dir/
  ---````
  function actions.create_paths()
    local ctx = lir.get_context()
    local old_dir = uv.cwd()

    cd(ctx.dir)

    utils.input("Create paths: ", {
      completion = function(_, cmd_line, cur_pos)
        local args, argidx = arg_parser.scan_sh_args(cmd_line, cur_pos)
        argidx = math.max(1, argidx)
        local leading_args = utils.vec_slice(args, 1, argidx)

        return vim.tbl_map(function(v)
          leading_args[argidx] = utils.str_quote(v, { only_if_whitespace = true })
          return table.concat(leading_args, " ")
        end, vim.fn.getcompletion(args[argidx] or "", "file"))
      end,

      callback = function(new_paths)
        cd(old_dir)
        utils.clear_prompt()

        if not new_paths then
          return
        end

        local args = arg_parser.scan_sh_args(new_paths, #new_paths)
        local new_abs, new_dir

        for _, arg in ipairs(args) do
          new_abs = pl:absolute(arg, ctx.dir)

          if vim.endswith(arg, "/") then
            new_abs = new_abs .. "/"
          end

          new_dir = new_abs:match("(.*)/")

          if not pl:readable(new_abs) then
            if new_dir and not pl:is_dir(new_dir) then
              local ok, ret = pcall(vim.fn.mkdir, new_dir, "p")

              if not ok or ret ~= 1 then
                utils.err({ "Failed to create path!", type(ret) == "string" and ret or nil })
                return
              end
            end

            if new_dir .. "/" ~= new_abs then
              local fd = uv.fs_open(new_abs, "w", 420)

              if not fd then
                utils.err("Could not create file: " .. new_abs)
                return
              end

              uv.fs_close(fd)
            end
          end
        end

        vim.cmd("e " .. vim.fn.fnameescape(new_dir))
        highlight_item(new_abs)
      end,
    })
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
      ['e']     = actions.newfile,
      ['a']     = actions.create_paths,
      ['r']     = actions.move,
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
    if not (pl:readable(abs_path) or pl:readable(pl:parent(abs_path) or "")) then
      abs_path = pl:absolute(uv.cwd())
    elseif not pl:is_dir(abs_path) then
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
    if not (pl:readable(abs_path) or pl:readable(pl:parent(abs_path) or "")) then
      abs_path = pl:absolute(uv.cwd())
    elseif not pl:is_dir(abs_path) then
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
