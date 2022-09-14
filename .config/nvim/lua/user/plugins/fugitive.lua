return function()
  local M = {
    augroup = vim.api.nvim_create_augroup("fugitive_config", {}),
  }

  ---Get the script ID of a fugitive script file.
  ---@param file? string Fugitive script file name (default: "autoload/fugitive.vim")
  ---@return integer?
  function M.get_sid(file)
    file = file or "autoload/fugitive.vim"
    local script_entry = vim.api.nvim_exec("filter #vim-fugitive/" .. file .. "# scriptnames", true)
    return tonumber(script_entry:match("^(%d+)")) --[[@as integer ]]
  end

  ---Get the fugitive context for the item under the cursor.
  ---@return table?
  function M.get_info_under_cursor()
    if vim.bo.ft ~= "fugitive" then return end
    local sid = M.get_sid()

    if sid then
      return vim.call(("<SNR>%d_StageInfo"):format(sid), vim.api.nvim_win_get_cursor(0)[1])
    end
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = M.augroup,
    pattern = "fugitive",
    callback = function(ctx)
      -- Open Diffview for the item under the cursor
      vim.keymap.set("n", "D", function()
        local info = M.get_info_under_cursor()

        if info then
          if #info.paths > 0 then
            vim.cmd(("DiffviewOpen --selected-file=%s"):format(vim.fn.fnameescape(info.paths[1])))
          elseif info.commit ~= "" then
            vim.cmd(("DiffviewOpen %s^!"):format(info.commit))
          end
        end
      end, { buffer = ctx.buf })
    end,
  })

  Config.plugin.fugitive = M
end
