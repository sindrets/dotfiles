local luv = vim.loop
local api = vim.api

local M = {}

---@alias vector any[]

---Echo string with multiple lines.
---@param msg string
---@param hl? string Highlight group name.
---@param schedule? boolean Schedule the echo call.
function M.echo_multiln(msg, hl, schedule)
  if schedule then
    vim.schedule(function()
      M.echo_multiln(msg, hl, false)
    end)
    return
  end

  vim.cmd("echohl " .. (hl or "None"))
  for _, line in ipairs(vim.split(msg, "\n")) do
    vim.cmd(string.format('echom "%s"', vim.fn.escape(line, [["\]])))
  end
  vim.cmd("echohl None")
end

---@param msg string
---@param schedule? boolean Schedule the echo call.
function M.info(msg, schedule)
  M.echo_multiln(msg, "Directory", schedule)
end

---@param msg string
---@param schedule? boolean Schedule the echo call.
function M.warn(msg, schedule)
  M.echo_multiln(msg, "WarningMsg", schedule)
end

---@param msg string
---@param schedule? boolean Schedule the echo call.
function M.err(msg, schedule)
  M.echo_multiln(msg, "ErrorMsg", schedule)
end

---Replace termcodes.
---@param s string
---@return string
function M.t(s)
  return api.nvim_replace_termcodes(s, true, true, true)
end

function M.printi(...)
  local args = vim.tbl_map(function (v)
    return vim.inspect(v)
  end, M.tbl_pack(...))
  print(M.tbl_unpack(args))
end

function M.clamp(value, min, max)
  if value < min then
    return min
  end
  if value > max then
    return max
  end
  return value
end

function M.round(value)
  return math.floor(value + 0.5)
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

function M.tbl_clone(t)
  if not t then
    return
  end
  local clone = {}

  for k, v in pairs(t) do
    clone[k] = v
  end

  return clone
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

---Create a shallow copy of a portion of a vector.
---@param t vector
---@param first? integer First index, inclusive
---@param last? integer Last index, inclusive
---@return vector
function M.vec_slice(t, first, last)
  local slice = {}
  for i = first or 1, last or #t do
    table.insert(slice, t[i])
  end

  return slice
end

---Join multiple vectors into one.
---@vararg vector
---@return vector
function M.vec_join(...)
  local result = {}
  local args = {...}
  local n = 0

  for i = 1, select("#", ...) do
    if type(args[i]) ~= "nil" then
      if type(args[i]) ~= "table" then
        result[n + 1] = args[i]
        n = n + 1
      else
        for j, v in ipairs(args[i]) do
          result[n + j] = v
        end
        n = n + #args[i]
      end
    end
  end

  return result
end

---Return the first index a given object can be found in a vector, or -1 if
---it's not present.
---@param t vector
---@param v any
---@return integer
function M.vec_indexof(t, v)
  for i, vt in ipairs(t) do
    if vt == v then
      return i
    end
  end
  return -1
end

---Append any number of objects to the end of a vector. Pushing `nil`
---effectively does nothing.
---@param t vector
---@return vector t
function M.vec_push(t, ...)
  for _, v in ipairs({...}) do
    t[#t + 1] = v
  end
  return t
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
