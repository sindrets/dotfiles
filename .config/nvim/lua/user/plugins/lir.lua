return function()
  local actions = require("lir.actions")
  local clipboard_actions = require("lir.clipboard.actions")
  local float = require("lir.float")
  local lazy = require("user.lazy")
  local lir = require("lir")
  local mark_actions = require("lir.mark.actions")

  ---@module "diffview.arg_parser"
  local arg_parser = lazy.require("diffview.arg_parser")

  local pl = Config.common.utils.pl
  local utils = Config.common.utils
  local notify = Config.common.notify

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
        local c = arg_parser.scan(cmd_line, { cur_pos = cur_pos })
        return arg_parser.process_candidates(vim.fn.getcompletion(c.arg_lead, "file"), c, true)
      end,

      callback = function(new_paths)
        cd(old_dir)
        utils.clear_prompt()

        if not new_paths then
          return
        end

        local c = arg_parser.scan(new_paths)

        local new_abs, new_dir

        for _, arg in ipairs(c.args) do
          new_abs = pl:absolute(arg, ctx.dir)

          if vim.endswith(arg, "/") then
            new_abs = new_abs .. "/"
          end

          new_dir = new_abs:match("(.*)/")

          if not pl:readable(new_abs) then
            if new_dir and not pl:is_dir(new_dir) then
              ---@diagnostic disable-next-line: redefined-local
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

  function actions.system_open()
    local ctx = lir.get_context()
    local cur = ctx:current()
    vim.fn.jobstart({ "xdg-open", cur.fullpath }, { detach = true })
  end

  ---Stage the current file.
  function actions.git_stage()
    local ctx = lir.get_context()
    local cur = ctx:current()
    local toplevel = utils.tbl_access(ctx, "git.toplevel")

    if not toplevel then
      return
    end

    local _, code, err = utils.job({ "git", "add", cur.fullpath }, toplevel)

    if code ~= 0 then
      notify.git.error("Failed to stage path: " .. err)
    end

    actions.reload()
  end

  ---Stage the current directory.
  function actions.git_stage_all()
    local ctx = lir.get_context()
    local toplevel = utils.tbl_access(ctx, "git.toplevel")

    if not toplevel then
      return
    end

    local _, code, err = utils.job({ "git", "add", ctx.dir }, toplevel)

    if code ~= 0 then
      notify.git.error("Failed to stage path: " .. err)
    end

    actions.reload()
  end

  ---Unstage the current file.
  function actions.git_reset()
    local ctx = lir.get_context()
    local cur = ctx:current()
    local toplevel = utils.tbl_access(ctx, "git.toplevel")

    if not toplevel then
      return
    end

    local _, code, err = utils.job({ "git", "reset", "--", cur.fullpath }, toplevel)

    if code ~= 0 then
      notify.git.error("Failed to reset path: " .. err)
    end

    actions.reload()
  end

  ---Unstage the current directory.
  function actions.git_reset_all()
    local ctx = lir.get_context()
    local toplevel = utils.tbl_access(ctx, "git.toplevel")

    if not toplevel then
      return
    end

    local _, code, err = utils.job({ "git", "reset", "--", ctx.dir }, toplevel)

    if code ~= 0 then
      notify.git.error("Failed to reset path: " .. err)
    end

    actions.reload()
  end

  ---Stage / unstage the current file.
  function actions.git_toggle_stage()
    local ctx = lir.get_context()
    local cur = ctx:current()
    local status = utils.tbl_access(cur, "git.status")

    if not status or status:sub(2, 2) ~= " " then
      actions.git_stage()
    elseif status and status:sub(1, 1) then
      actions.git_reset()
    end
  end

  require('lir').setup({
    show_hidden_files = true,
    devicons = {
      enable = true,
      highlight_dirname = true,
    },
    hide_cursor = true,
    mappings = {
      ['R']     = actions.reload,               -- [R]eload
      ['<CR>']  = actions.edit,
      ['o']     = actions.edit,                 -- [o]pen
      ['l']     = actions.edit,
      ['<C-s>'] = actions.split,                -- Open in [s]plit
      ['<C-v>'] = actions.vsplit,               -- Open in [v]ertical split
      ['<C-t>'] = actions.tabedit,              -- Open in [t]ab

      ['-'] = actions.up,
      ['h'] = actions.up,
      ['q'] = function()                        -- [q]uit
        Config.lib.remove_buffer(true)
        if vim.w.lir_is_float then
          vim.cmd("wincmd q")
        end
      end,

      ['e']     = actions.newfile,              -- [e]dit
      ['a']     = actions.create_paths,         -- [a]dd
      ['m']     = actions.move,                 -- [m]ove
      ['<C-]>'] = actions.cd,
      ['gy']    = actions.yank_path,            -- [y]ank path
      ['gx']    = actions.system_open,
      ['<C-h>'] = actions.toggle_show_hidden,   -- toggle [h]idden
      ['d']     = actions.delete,               -- [d]elete

      ['t'] = mark_actions.toggle_mark,         -- [t]oggle mark
      ['J'] = function()
        mark_actions.toggle_mark()
        vim.cmd('norm! j')
      end,
      ['K'] = function()
        mark_actions.toggle_mark()
        vim.cmd('norm! k')
      end,
      ['y'] = clipboard_actions.copy,             -- [y]ank file
      ['x'] = clipboard_actions.cut,
      ['p'] = clipboard_actions.paste,            -- [p]aste file

      ['s'] = actions.git_toggle_stage,           -- toggle [s]tage file
      ['S'] = actions.git_stage_all,              -- [S]tage all
      ['u'] = actions.git_reset,                  -- [u]nstage file
      ['U'] = actions.git_reset_all,              -- [U]nstage all
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

  ---@param path? string
  local function derive_dir(path)
    local abs_path = pl:absolute(pl:vim_expand(path or "%"))

    if not (pl:readable(abs_path) or pl:readable(pl:parent(abs_path) or "")) then
      -- Target cannot be derived to a readable directory: use cwd.
      abs_path = pl:absolute(uv.cwd())
    elseif not pl:is_dir(abs_path) then
      -- Target is not a directory: use the parent.
      abs_path = pl:parent(abs_path)
    end

    return abs_path
  end

  function M.explore(path)
    vim.cmd("e " .. vim.fn.fnameescape(derive_dir(path)))
  end

  function M.open_float(path)
    local abs_path

    if path then
      abs_path = pl:absolute(pl:vim_expand(path))
    end

    float.init(abs_path or nil)
  end

  function M.toggle_float(path)
    float.toggle(derive_dir(path) or nil)
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
