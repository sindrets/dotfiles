local luv = vim.loop
local api = vim.api

local M = {}

function M.right_pad_string(s, min_size, fill)
  local result = s
  if not fill then fill = " " end

  while #result < min_size do
    result = result .. fill
  end

  return result
end

function M.left_pad_string(s, min_size, fill)
  local result = s
  if not fill then fill = " " end

  while #result < min_size do
    result = fill .. result
  end

  return result
end

function M.center_pad_string(s, min_size, fill)
  local result = s
  if not fill then fill = " " end

  while #result < min_size do
    if #result % 2 == 0 then
      result = result .. fill
    else
      result = fill .. result
    end
  end

  return result
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
    local success, v = pcall(api.nvim_buf_get_var, id, var)
    if success and v == value then return id end
  end

  return nil
end

function M.find_buf_with_option(option, value)
  for _, id in ipairs(api.nvim_list_bufs()) do
    local success, v = pcall(api.nvim_buf_get_option, id, option)
    if success and v == value then return id end
  end

  return nil
end

function M.wipe_all_buffers()
  for _, id in ipairs(api.nvim_list_bufs()) do
    pcall(api.nvim_buf_delete, id)
  end
end

---@class BufToggleEntry
---@field bufid integer
---@field height integer|nil
local BufToggleEntry = {}
BufToggleEntry.__index = BufToggleEntry

---BufToggleEntry constructor.
---@param opts table
---@return BufToggleEntry
function BufToggleEntry:new(opts)
  opts = opts or {}
  local this = {
    height = opts.height
  }
  setmetatable(this, self)
  return this
end

---@class BufTogglerOpts
---@field focus boolean Focus the window if it exists and is unfocused.
---@field height integer
---@field remember_height boolean Remember the height of the window when it was
    --closed, and restore it the next time its opened.

---Create a function that toggles a window with an identifiable buffer of some
---kind. The toggle logic works as follows:
--- * Open if
---   - The buffer is not found
---   - No window with the buffer is found
--- * Close if:
---   - The buffer is active in the current window.
--- * Focus if (only if the `focus` option is enabled):
---   - The buffer exists, the window exists, but the window is not active.
---@param buf_finder function A function that should return the buffer id of
---the wanted buffer if it exists, otherwise nil.
---@param cb_open function Callback when the window should open.
---@param cb_close function Callback when the window should close.
---@param opts BufTogglerOpts|nil
---@return function
function M.create_buf_toggler(buf_finder, cb_open, cb_close, opts)
  opts = opts or {}
  local toggler_entry = BufToggleEntry:new()

  local function open()
    local ok = pcall(cb_open)
    if ok and toggler_entry.height then
      vim.cmd("res " .. toggler_entry.height)
    end
  end

  local function close()
    if opts.remember_height then
      toggler_entry.height = api.nvim_win_get_height(0)
    end
    pcall(cb_close)
  end

  return function ()
    local target_bufid = buf_finder()

    if not target_bufid then
      open()
      return
    end

    local win_ids = vim.fn.win_findbuf(target_bufid)
    if vim.tbl_isempty(win_ids) then
      open()
    else
      if target_bufid == api.nvim_get_current_buf() then
        -- It's the current window: close it.
        close()
        return
      end

      if opts.focus then
        -- The window exists, but is not active: focus it.
        api.nvim_set_current_win(win_ids[1])
      else
        close()
      end
    end
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

function M.ternary(condition, if_true, if_false)
  if condition then
    return if_true
  end

  return if_false
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

function M.within_range(outer, inner)
  local o1y = outer.start.line
  local o1x = outer.start.character
  local o2y = outer['end'].line
  local o2x = outer['end'].character
  assert(o1y <= o2y, "Start must be before end: " .. vim.inspect(outer))

  local i1y = inner.start.line
  local i1x = inner.start.character
  local i2y = inner['end'].line
  local i2x = inner['end'].character
  assert(i1y <= i2y, "Start must be before end: " .. vim.inspect(inner))

  if o1y < i1y then
    if o2y > i2y then
      return true
    end
    return o2y == i2y and o2x >= i2x
  elseif o1y == i1y then
    if o2y > i2y then
      return true
    else
      return o2y == i2y and o1x <= i1x and o2x >= i2x
    end
  else
    return false
  end
end

function M.get_diagnostics_for_range(bufnr, range)
  local diagnostics = vim.lsp.diagnostic.get(bufnr)
  if not diagnostics then return {} end
  local line_diagnostics = {}
  for _, diagnostic in ipairs(diagnostics) do
    if M.within_range(diagnostic.range, range) then
      table.insert(line_diagnostics, diagnostic)
    end
  end
  if #line_diagnostics == 0 then
    -- If there is no diagnostics at the cursor position,
    -- see if there is at least something on the same line
    for _, diagnostic in ipairs(diagnostics) do
      if diagnostic.range.start.line == range.start.line then
        table.insert(line_diagnostics, diagnostic)
      end
    end
  end
  return line_diagnostics
end

M.BufToggleEntry = BufToggleEntry
return M
