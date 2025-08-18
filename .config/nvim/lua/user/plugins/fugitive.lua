return function()
  local au = Config.common.au
  local utils = Config.common.utils
  local api = vim.api
  local km = vim.keymap
  local fmt = string.format

  local M = {
    sid_cache = {}
  }

  ---Get the script ID of a fugitive script file.
  ---@param file? string Fugitive script file name (default: "autoload/fugitive.vim")
  ---@return integer?
  function M.get_sid(file)
    file = file or "autoload/fugitive.vim"
    if M.sid_cache[file] then return M.sid_cache[file] end

    local script_entry = api.nvim_exec("filter #vim-fugitive.*/" .. file .. "# scriptnames", true)
    M.sid_cache[file] = tonumber(script_entry:match("^(%d+)")) --[[@as integer ]]

    return M.sid_cache[file]
  end

  ---Call a fugitive function.
  ---@param file_or_sid string|integer #
  ---Either the name of the fugitive script file to call from, or the sid of
  ---its script. (Use 0 to default to "autoload/fugitive.vim")
  ---@param func string Function name.
  ---@param ... any Arguments.
  ---@return unknown
  function M.call(file_or_sid, func, ...)
    local sid

    if type(file_or_sid) == "number" then
      if file_or_sid == 0 then
        sid = M.get_sid()
      else
        sid = file_or_sid
      end
    else
      sid = M.get_sid(file_or_sid --[[@as string ]])
    end

    return vim.fn[fmt("<SNR>%d_%s", sid, func)](...)
  end

  ---Get the fugitive context for the item under the cursor.
  ---@return table?
  function M.get_status_cursor_info()
    if vim.bo.ft ~= "fugitive" then return end
    return M.call(0, "StageInfo", api.nvim_win_get_cursor(0)[1])
  end

  ---@return table?
  function M.get_blame_cursor_info()
    if vim.bo.ft ~= "fugitiveblame" then return end
    local state = M.call(0, "TempState")
    local cursor = api.nvim_win_get_cursor(0)
    local line = api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1]

    return {
      file = pl:join(state.cwd, state.blame_file),
      commit = line:match("^([a-f0-9]+)"),
    }
  end

  function M.status_open(form, opt)
    opt = opt or {}
    local curwin = api.nvim_get_current_win()
    local curbufnr = api.nvim_win_get_buf(curwin)
    local ok, err, setup, open, cleanup

    local function run_cleanup(cmd)
      if cmd then vim.cmd(cmd) end
      if api.nvim_win_is_valid(curwin) and api.nvim_buf_is_valid(curbufnr) then
        utils.noautocmd(api.nvim_win_set_buf, curwin, curbufnr)
      end
    end

    if form == "tab" then
      if opt.use_last then
        for _, id in ipairs(api.nvim_list_tabpages()) do
          if vim.t[id].fugitive_form == "tab" then
            api.nvim_set_current_tabpage(id)
            return
          end
        end
      end

      setup = "tab sp | let t:fugitive_form = 'tab'"
      open = "Git ++curwin"
      cleanup = "tabc"
    elseif form == "split" then
      open = "Git | let w:fugitive_form = 'split'"
    elseif form == "float" then
      error("Not implemented!")
    end

    if setup then vim.cmd(setup) end
    ok, err = pcall(vim.cmd --[[@as function ]], open)

    if not ok then
      if type(err) == "string" and err:match("file does not belong to a Git repository") then
        -- Try to open status from an empty buffer in case the repository can
        -- be derived from the pwd instead.
        run_cleanup(cleanup)
        if setup then vim.cmd(setup) end
        vim.cmd("keepalt noautocmd enew | setl bufhidden=wipe bt=nofile")
        ok, err = pcall(vim.cmd --[[@as function ]], open)
      end

      if not ok then
        run_cleanup(cleanup)
        utils.err(err)
      end
    end

    run_cleanup()
  end

  local function find_usable_tabs()
    local all = api.nvim_list_tabpages()
    local fugitive_tabs = vim.tbl_filter(function(v)
      return vim.t[v].fugitive_form == "tab"
    end, all)
    local other_tabs = utils.vec_diff(all, fugitive_tabs)
    local prev_tab = utils.tabnr_to_id(vim.fn.tabpagenr("#")) or -1

    if api.nvim_tabpage_is_valid(prev_tab) and not utils.vec_indexof(fugitive_tabs, prev_tab) then
      return utils.vec_join(prev_tab, other_tabs)
    else
      return other_tabs
    end
  end

  ---@param tabid integer?
  ---@return vector<integer>
  local function find_usable_wins(tabid)
    -- Make sure the tab's current window is first in the list.
    local wins = utils.vec_join(
      api.nvim_tabpage_get_win(tabid or 0),
      api.nvim_tabpage_list_wins(tabid or 0)
    )

    return vim.tbl_filter(function(v)
      return vim.bo[api.nvim_win_get_buf(v)].buftype == ""
    end, wins)
  end

  ---@param tabid integer
  ---@return vector<integer>
  local function find_commit_views(tabid)
    return vim.tbl_filter(function(v)
      if vim.fn.win_gettype(v) ~= "" then return false end
      return vim.w[v].fugitive_type == "commit_view"
    end, api.nvim_tabpage_list_wins(tabid))
  end

  au.declare_group("fugitive_config", {}, {
    {
      "BufEnter",
      pattern = "^fugitive://*",
      callback = "setl bufhidden=delete",
    },
    {
      "FileType",
      pattern = "fugitive",
      callback = function(ctx)
        -- Fugitive status buffer mappings

        km.set("n", "<Tab>", "=", { remap = true, buffer = ctx.buf })
        km.set("n", "R", "<Cmd>edit<CR>", { buffer = ctx.buf })
        km.set("n", "S", "<Cmd>silent !git add -u<CR>", { buffer = ctx.buf })
        km.set("n", "<C-s>", "<Cmd>silent !git add -A<CR>", { buffer = ctx.buf })
        km.set("n", "p", "<Cmd>Git pull<CR>", { buffer = ctx.buf })

        km.set("n", "P", function()
          utils.confirm("Confirm git push?", {
            default = true,
            callback = function(choice)
              if choice then vim.cmd("Git push") end
            end,
          })
        end, { buffer = ctx.buf })

        km.set("n", "q", function()
          Config.lib.comfy_quit({ keep_last = true })
        end, { buffer = ctx.buf })

        km.set("n", "<CR>", function()
          local info = M.get_status_cursor_info()
          if not info then return end

          if #info.paths > 0 then
            if vim.t.fugitive_form ~= "tab" then
              vim.cmd(M.call(0, "GF", "edit"))
            else
              local edit_kind = "edit"
              local tabs = find_usable_tabs()

              if #tabs == 0 then
                edit_kind = "tabedit"
              else
                api.nvim_set_current_tabpage(tabs[1])
                local wins = find_usable_wins(tabs[1])

                if #wins == 0 then
                  edit_kind = "split"
                else
                  api.nvim_set_current_win(wins[1])
                end
              end

              vim.cmd(
                fmt(
                  "G%s %s %s | norm! zv",
                  edit_kind,
                  info.offset and ("+" .. info.offset) or "",
                  vim.fn.fnameescape(info.paths[1])
                )
              )
            end
          elseif info.commit then
            local wins = find_commit_views(0)

            if #wins > 0 then
              api.nvim_set_current_win(wins[1])
            else
              local win_width = api.nvim_win_get_width(0)
              local win_height = api.nvim_win_get_height(0)
              vim.cmd(win_width / 4 > win_height and "vsplit" or "split")
              vim.w.fugitive_type = "commit_view"
            end

            vim.cmd(
              fmt(
                "Git ++curwin show --stat --patch --diff-merges=first-parent %s --",
                info.commit
              )
            )
          end
        end, { buffer = ctx.buf })

        Config.lib.mv_keymap("n", "-", "n", "s", ctx.buf)

        km.set("n", "DD", function()
          local info = M.get_status_cursor_info()

          if info then
            if #info.paths > 0 then
              vim.cmd(fmt("DiffviewOpen --selected-file=%s", vim.fn.fnameescape(info.paths[1])))
            elseif info.commit ~= "" then
              vim.cmd(fmt("DiffviewOpen %s^!", info.commit))
            end
          end
        end, {
          buffer = ctx.buf,
          desc = "Open Diffview for the item under the cursor",
        })

        km.set("n", "DH", function()
          local info = M.get_status_cursor_info()

          if info then
            if #info.paths > 0 then
              vim.cmd(fmt("DiffviewFileHistory %s", vim.fn.fnameescape(info.paths[1])))
            elseif info.commit ~= "" then
              vim.cmd(fmt("DiffviewFileHistory --range=%s", info.commit))
            end
          end
        end, {
          buffer = ctx.buf,
          desc = "Open file history for the item under the cursor",
        })
      end,
    },
    {
      "FileType",
      pattern = "fugitiveblame",
      callback = function(ctx)
        -- Fugitive blame buffer mappings

        -- Move the default `D` mapping, because it has `nowait` set.
        Config.lib.mv_keymap("n", "D", "n", "T", ctx.buf)

        km.set("n", "DD", function()
          local info = M.get_blame_cursor_info()

          if info then
            vim.cmd(
              fmt(
                "DiffviewOpen %s^! --selected-file=%s",
                info.commit,
                vim.fn.fnameescape(info.file)
              )
            )
          end
        end, {
          buffer = ctx.buf,
          desc = "Open Diffview for the blame commit under the cursor",
        })

        km.set("n", "DH", function()
          local info = M.get_blame_cursor_info()

          if info then
            vim.cmd(
              fmt(
                "DiffviewFileHistory --range=%s %s",
                info.commit,
                vim.fn.fnameescape(info.file)
              )
            )
          end
        end, {
          buffer = ctx.buf,
          desc = "Open file history from the blame commit under the cursor",
        })
      end,
    },
    {
      "FileType",
      pattern = "git",
      callback = function(ctx)
        -- Git buffer mappings

        km.set("n", "q", function()
          if not vim.bo.modifiable or vim.bo.readonly then
            return "<Cmd>lua Config.lib.comfy_quit({ keep_last = true })<CR>"
          else
            return "q"
          end
        end, { buffer = ctx.buf, expr = true })

        km.set("n", "<CR>", function()
          local commit, offset, postcmd = unpack(M.call(0, "cfile"))

          if commit then
            local wins = find_commit_views(0)

            if #wins > 0 then
              api.nvim_set_current_win(wins[1])
              vim.cmd(
                fmt(
                  "Gedit %s %s %s",
                  offset and ("+" .. offset) or "",
                  commit,
                  postcmd and ("|" .. postcmd) or ""
                )
              )
              return
            end
          end

          vim.cmd(M.call(0, "GF", "edit"))
        end, { buffer = ctx.buf })

        km.set("n", "DD", function()
          local commit = unpack(M.call(0, "cfile"))

          if commit then
            if commit:find(":") then
              local path
              commit, path = commit:match("^(.-)^?:(.*)")
              vim.cmd(
                fmt(
                  "DiffviewOpen %s^! --selected-file=%s",
                  commit,
                  vim.fn.fnameescape(pl:join(vim.fn.FugitiveWorkTree(), path))
                )
              )
            else
              vim.cmd(fmt("DiffviewOpen %s^!", commit))
            end
          end
        end, {
          buffer = ctx.buf,
          desc = "Open Diffview for the commit under the cursor",
        })

        km.set("n", "DH", function()
          local commit = unpack(M.call(0, "cfile"))

          if commit then
            if commit:find(":") then
              local path
              commit, path = commit:match("^(.-)^?:(.*)")
              vim.cmd(
                fmt(
                  "DiffviewFileHistory --range=%s %s",
                  commit,
                  vim.fn.fnameescape(pl:join(vim.fn.FugitiveWorkTree(), path))
                )
              )
            else
              vim.cmd(fmt("DiffviewFileHistory --range=%s", commit))
            end

          end
        end, {
          buffer = ctx.buf,
          desc = "Open file history from the commit under the cursor",
        })
      end,
    },
  })

  Config.plugin.fugitive = M
end
