local luv = vim.loop
local api = vim.api

local M = {}

function M._echo_multiline(msg, hl)
  local chunks = vim.tbl_map(function(line)
    return { line, hl }
  end, vim.split(msg, "\n"))
  vim.api.nvim_echo(chunks, true, {})
end

function M.info(msg)
  M._echo_multiline(msg, "Directory")
end

function M.warn(msg)
  M._echo_multiline(msg, "WarningMsg")
end

function M.err(msg)
  M._echo_multiline(msg, "ErrorMsg")
end

function M.printi(...)
  local args = vim.tbl_map(function (v)
    return vim.inspect(v)
  end, M.tbl_pack(...))
  print(M.tbl_unpack(args))
end

function M.str_right_pad(s, min_size, fill)
  if #s >= min_size then
    return s
  end
  if not fill then fill = " " end
  return s .. string.rep(fill, math.ceil((min_size - #s) / #fill))
end

function M.str_left_pad(s, min_size, fill)
  if #s >= min_size then
    return s
  end
  if not fill then fill = " " end
  return string.rep(fill, math.ceil((min_size - #s) / #fill)) .. s
end

function M.str_center_pad(s, min_size, fill)
  if #s >= min_size then
    return s
  end
  if not fill then fill = " " end
  local left_len = math.floor((min_size - #s) / #fill / 2)
  local right_len = math.ceil((min_size - #s) / #fill / 2)
  return string.rep(fill, left_len) .. s .. string.rep(fill, right_len)
end

function M.tbl_pack(...)
  return { n = select('#',...); ... }
end

function M.tbl_unpack(t, i, j)
  return unpack(t, i or 1, j or t.n or #t)
end

---Create a shallow copy of a portion of a list.
---@param t table
---@param first integer First index, inclusive
---@param last integer Last index, inclusive
---@return any[]
function M.tbl_slice(t, first, last)
  local slice = {}
  for i = first or 1, last or #t do
    table.insert(slice, t[i])
  end

  return slice
end

function M.tbl_concat(...)
  local result = {}
  local n = 0

  for _, t in ipairs({...}) do
    for i, v in ipairs(t) do
      result[n + i] = v
    end
    n = n + #t
  end

  return result
end

function M.tbl_deep_clone(t)
  if not t then return end
  local clone = {}

  for k, v in pairs(t) do
    if type(v) == "table" then
      clone[k] = M.tbl_deep_clone(v)
    else
      clone[k] = v
    end
  end

  return clone
end

function M.get_hl_attr(hl_group_name, attr)
  local id = api.nvim_get_hl_id_by_name(hl_group_name)
  if not id then return end

  local value = vim.fn.synIDattr(id, attr)
  if not value or value == "" then return end

  return value
end

function M.get_fg(hl_group_name)
  return M.get_hl_attr(hl_group_name, "fg")
end

function M.get_bg(hl_group_name)
  return M.get_hl_attr(hl_group_name, "bg")
end

function M.get_gui(hl_group_name)
  return M.get_hl_attr(hl_group_name, "gui")
end

function M.find_buf_with_pattern(pattern)
  for _, id in ipairs(api.nvim_list_bufs()) do
    local m = vim.fn.bufname(id):match(pattern)
    if m then return id end
  end

  return nil
end

function M.find_buf_with_var(var, value)
  for _, id in ipairs(api.nvim_list_bufs()) do
    local ok, v = pcall(api.nvim_buf_get_var, id, var)
    if ok and v == value then return id end
  end

  return nil
end

function M.find_buf_with_option(option, value)
  for _, id in ipairs(api.nvim_list_bufs()) do
    local ok, v = pcall(api.nvim_buf_get_option, id, option)
    if ok and v == value then return id end
  end

  return nil
end

function M.wipe_all_buffers()
  for _, id in ipairs(api.nvim_list_bufs()) do
    pcall(api.nvim_buf_delete, id)
  end
end

---Create a new table that represents the union of the values in a and b.
---@return table
function M.union(...)
  local seen = {}
  local result = {}

  for _, t in ipairs({...}) do
    for _, v in ipairs(t) do
      if not seen[v] then
        seen[v] = true
        table.insert(result, v)
      end
    end
  end

  return result
end

function M.file_readable(path)
  local fd = luv.fs_open(path, "r", 438)
  if fd then
    luv.fs_close(fd)
    return true
  end

  return false
end

function M.git_get_detached_head()
  local git_branches_file = io.popen("git branch -a --no-abbrev --contains", "r")
  if not git_branches_file then return end
  local git_branches_data = git_branches_file:read("*l")
  io.close(git_branches_file)
  if not git_branches_data then return end

  local branch_name = git_branches_data:match('.*HEAD (detached %w+ [%w/-]+)')
  if branch_name and string.len(branch_name) > 0 then
    return branch_name
  end
end

function M.lsp_organize_imports()
  local context = { source = { organizeImports = true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  local method = "textDocument/codeAction"
  local timeout = 1000 -- ms

  local resp = vim.lsp.buf_request_sync(0, method, params, timeout)
  if not resp then return end

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if resp[client.id] then
      local result = resp[client.id].result
      if not result or not result[1] then return end

      local edit = result[1].edit
      vim.lsp.util.apply_workspace_edit(edit)
    end
  end
end

return M
