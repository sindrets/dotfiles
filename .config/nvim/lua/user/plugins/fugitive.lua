return function()
  local au = Config.common.au
  local api = vim.api

  local M = {
    sid_cache = {}
  }

  ---Get the script ID of a fugitive script file.
  ---@param file? string Fugitive script file name (default: "autoload/fugitive.vim")
  ---@return integer?
  function M.get_sid(file)
    file = file or "autoload/fugitive.vim"
    if M.sid_cache[file] then return M.sid_cache[file] end

    local script_entry = api.nvim_exec("filter #vim-fugitive/" .. file .. "# scriptnames", true)
    M.sid_cache[file] = tonumber(script_entry:match("^(%d+)")) --[[@as integer ]]

    return M.sid_cache[file]
  end

  ---Call a fugitive function.
  ---@param file_or_sid string|integer Either the name of the fugitive script file to call from, or the sid of its script. (Use 0 to default to "autoload/fugitive.vim")
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

    return vim.call(("<SNR>%d_%s"):format(sid, func, ...))
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

  au.declare_group("fugitive_config", {}, {
    {
      "FileType",
      pattern = "fugitive",
      callback = function(ctx)
        -- Fugitive status buffer mappings

        vim.keymap.set("n", "DD", function()
          local info = M.get_status_cursor_info()

          if info then
            if #info.paths > 0 then
              vim.cmd(("DiffviewOpen --selected-file=%s"):format(vim.fn.fnameescape(info.paths[1])))
            elseif info.commit ~= "" then
              vim.cmd(("DiffviewOpen %s^!"):format(info.commit))
            end
          end
        end, {
          buffer = ctx.buf,
          desc = "Open Diffview for the item under the cursor",
        })

        vim.keymap.set("n", "DH", function()
          local info = M.get_status_cursor_info()

          if info then
            if #info.paths > 0 then
              vim.cmd(("DiffviewFileHistory %s"):format(vim.fn.fnameescape(info.file)))
            elseif info.commit ~= "" then
              vim.cmd(("DiffviewFileHistory --range=%s"):format(info.commit))
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

        vim.keymap.set("n", "DD", function()
          local info = M.get_blame_cursor_info()

          if info then
            vim.cmd(("DiffviewOpen %s^! --selected-file=%s"):format(
              info.commit,
              vim.fn.fnameescape(info.file)
            ))
          end
        end, {
          buffer = ctx.buf,
          desc = "Open Diffview for the blame commit under the cursor",
        })

        vim.keymap.set("n", "DH", function()
          local info = M.get_blame_cursor_info()

          if info then
            vim.cmd(("DiffviewFileHistory --range=%s %s"):format(
              info.commit,
              vim.fn.fnameescape(info.file)
            ))
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

        vim.keymap.set("n", "DD", function()
          local commit = unpack(M.call(0, "cfile"))

          if commit then
            if commit:find(":") then
              local path
              commit, path = commit:match("^(.-):(.*)")
              vim.cmd(("DiffviewOpen %s^! --selected-file=%s"):format(
                commit,
                vim.fn.fnameescape(path)
              ))
            else
              vim.cmd(("DiffviewOpen %s^!"):format(commit))
            end
          end
        end, {
          buffer = ctx.buf,
          desc = "Open Diffview for the commit under the cursor",
        })

        vim.keymap.set("n", "DH", function()
          local commit = unpack(M.call(0, "cfile"))

          if commit then
            vim.cmd(("DiffviewFileHistory --range=%s"):format(commit))
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
