--[[
  Auto command callbacks etc.
]]

local Path = Config.common.utils.Path
local utils = Config.common.utils
local notify = Config.common.notify
local api = vim.api

local M = {}

M.project_config_paths = {
  ".vim/init.vim",
  ".vim/init.lua",
  ".vim/nvimrc.vim",
  ".vim/nvimrc.lua",
  ".vim/nvimrc",
  ".nvimrc.vim",
  ".nvimrc.lua",
  ".nvimrc",
}

local last_sourced_config = nil
local last_sourced_session = nil

function M.source_project_config()
  for _, file in ipairs(M.project_config_paths) do
    local path = Path.from_str(file):unwrap()
    if path:is_readable():block_on() then
      local project_config_path = path:realpath():block_on():unwrap()

      if last_sourced_config ~= project_config_path then
        local ext = path:extension()

        if ext == "lua" or ext == nil then
          local data = vim.secure.read(path:tostring())
          if not data then return end
          local code_chunk = loadfile(path:tostring())

          if code_chunk then
            local ok, out = utils.trace_pcall(code_chunk)

            if not ok then
              notify.config.error(pb.concat(
                ("Failed to load project config %s:"):format(utils.str_quote(file)),
                vim.split(out, "\n")
              ))
              return
            end

            Config.state.project_config = out
          end
        else
          local data = vim.secure.read(path:tostring())
          if data then vim.cmd.source(path:tostring()) end
        end

        last_sourced_config = project_config_path
        notify.config(
          "Using project config: "
          .. utils.str_quote(vim.fn.fnamemodify(file, ":."))
        )
        break
      end
    end
  end
end

function M.source_project_session()
  local session_path = Path.from(".vim/Session.vim")
  if #vim.v.argv == 1 and session_path:is_readable():block_on() then
    local project_config_path = session_path:realpath():block_on():unwrap()

    if last_sourced_session ~= project_config_path then
      vim.cmd("source .vim/Session.vim")
      last_sourced_session = project_config_path
    end
  end
end

--- Open a file at a specific line + column.
--- Example location: `foo/bar/baz:128:17`
--- @param location string
function M.open_file_location(location)
  local bufnr = vim.fn.expand("<abuf>")
  if bufnr == "" then
    return
  end

  bufnr = tonumber(bufnr)
  local l = vim.trim(location)
  local file = utils.str_match(l, { "(.*):%d+:%d+:?$", "(.*):%d+:?$", "(.*):$" })
  local line = tonumber(utils.str_match(l, { ".*:(%d+):%d+:?$", ".*:(%d+):?$" }))
  local col = tonumber(l:match(".*:%d+:(%d+):?$")) or 1
  local file_path = Path.from(file)

  if file_path:is_readable():block_on() then
    vim.cmd("keepalt edit " .. vim.fn.fnameescape(file_path:tostring()))

    if line then
      api.nvim_exec_autocmds("BufRead", {})
      utils.set_cursor(0, line, col - 1)
      pcall(api.nvim_buf_delete, bufnr, {})
      pcall(api.nvim_exec2, "argd " .. vim.fn.fnameescape(l), { output = false })
    end
  end
end

return M
