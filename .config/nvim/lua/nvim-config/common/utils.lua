local uv = vim.loop
local api = vim.api

local M = {}

local is_windows = jit.os == "Windows"
local path_sep = package.config:sub(1, 1)
local setlocal_opr_templates = {
  set = [[setl ${option}=${value}]],
  remove = [[exe 'setl ${option}-=${value}']],
  append = [[exe 'setl ${option}=' . (&${option} == "" ? "" : &${option} . ",") . '${value}']],
  prepend = [[exe 'setl ${option}=${value}' . (&${option} == "" ? "" : "," . &${option})]],
}

---@alias vector any[]

---Echo string with multiple lines.
---@param msg string|string[]
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
  if type(msg) ~= "table" then
    msg = vim.split(msg, "\n")
  end
  for _, line in ipairs(msg) do
    line = line:gsub('"', [[\"]])
    line = line:gsub('\t', "    ")
    vim.cmd(string.format('echom "%s"', line))
  end
  vim.cmd("echohl None")
end

---@param msg string|string[]
---@param schedule? boolean Schedule the echo call.
function M.info(msg, schedule)
  if type(msg) ~= "table" then
    msg = vim.split(msg, "\n")
  end
  if not msg[1] or msg[1] == "" then
    return
  end
  M.echo_multiln(msg, "Directory", schedule)
end

---@param msg string|string[]
---@param schedule? boolean Schedule the echo call.
function M.warn(msg, schedule)
  if type(msg) ~= "table" then
    msg = vim.split(msg, "\n")
  end
  if not msg[1] or msg[1] == "" then
    return
  end
  M.echo_multiln(msg, "WarningMsg", schedule)
end

---@param msg string|string[]
---@param schedule? boolean Schedule the echo call.
function M.err(msg, schedule)
  if type(msg) ~= "table" then
    msg = vim.split(msg, "\n")
  end
  if not msg[1] or msg[1] == "" then
    return
  end
  M.echo_multiln(msg, "ErrorMsg", schedule)
end

---Replace termcodes.
---@param s string
---@return string
function M.t(s)
  return api.nvim_replace_termcodes(s, true, true, true)
end

function M.exec_lua(code, ...)
  local chunk, err = loadstring(code)
  if err then
    error(err)
  elseif chunk then
    return chunk(...)
  end
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

---Check if a given path is absolute.
---@param path string
---@return boolean
function M.path_is_abs(path)
  if is_windows then
    return path:match([[^%a:\]]) ~= nil
  else
    return path:sub(1, 1) == "/"
  end
end

---Joins an ordered list of path segments into a path string.
---@param paths string[]
---@return string
function M.path_join(paths)
  local result = paths[1]
  for i = 2, #paths do
    if tostring(paths[i]):sub(1, 1) == path_sep then
      result = result .. paths[i]
    else
      result = result .. path_sep .. paths[i]
    end
  end
  return result
end

---Explodes the path into an ordered list of path segments.
---@param path string
---@return string[]
function M.path_explode(path)
  local parts = {}
  for part in path:gmatch(string.format("([^%s]+)%s?", path_sep, path_sep)) do
    table.insert(parts, part)
  end
  return parts
end

---Get the basename of the given path.
---@param path string
---@return string
function M.path_basename(path)
  path = M.path_remove_trailing(path)
  local i = path:match("^.*()" .. path_sep)
  if not i then
    return path
  end
  return path:sub(i + 1, #path)
end

function M.path_extension(path)
  path = M.path_basename(path)
  return path:match(".+%.(.*)")
end

---Get the path to the parent directory of the given path. Returns `nil` if the
---path has no parent.
---@param path string
---@param remove_trailing boolean
---@return string|nil
function M.path_parent(path, remove_trailing)
  path = " " .. M.path_remove_trailing(path)
  local i = path:match("^.+()" .. path_sep)
  if not i then
    return nil
  end
  path = path:sub(2, i)
  if remove_trailing then
    path = M.path_remove_trailing(path)
  end
  return path
end

---Get a path relative to another path.
---@param path string
---@param relative_to string
---@return string
function M.path_relative(path, relative_to)
  local p, _ = path:gsub("^" .. M.pattern_esc(M.path_add_trailing(relative_to)), "")
  return p
end

function M.path_add_trailing(path)
  if path:sub(-1) == path_sep then
    return path
  end

  return path .. path_sep
end

function M.path_remove_trailing(path)
  local p, _ = path:gsub(path_sep .. "$", "")
  return p
end

function M.path_shorten(path, max_length)
  if string.len(path) > max_length - 1 then
    path = path:sub(string.len(path) - max_length + 1, string.len(path))
    local i = path:match("()" .. path_sep)
    if not i then
      return "…" .. path
    end
    return "…" .. path:sub(i, -1)
  else
    return path
  end
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

---Simple string templating
---Example template: "${name} is ${value}"
---@param str string Template string
---@param table table Key-value pairs to replace in the string
function M.str_template(str, table)
  return (str:gsub("($%b{})", function(w)
    return table[w:sub(3, -2)] or w
  end))
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
  local c = 0

  for i = 1, select("#", ...) do
    if type(args[i]) ~= "nil" then
      if type(args[i]) ~= "table" then
        result[c + 1] = args[i]
        c = c + 1
      else
        for j, v in ipairs(args[i]) do
          result[c + j] = v
        end
        c = c + #args[i]
      end
    end
  end

  return result
end

---Get the result of the union of the given vectors.
---@vararg vector
---@return vector
function M.vec_union(...)
  local result = {}
  local args = {...}
  local seen = {}

  for i = 1, select("#", ...) do
    if type(args[i]) ~= "nil" then
      if type(args[i]) ~= "table" and not seen[args[i]] then
        seen[args[i]] = true
        result[#result+1] = args[i]
      else
        for _, v in ipairs(args[i]) do
          if not seen[v] then
            seen[v] = true
            result[#result+1] = v
          end
        end
      end
    end
  end

  return result
end

---Get the result of the difference of the given vectors.
---@vararg vector
---@return vector
function M.vec_diff(...)
  local args = {...}
  local seen = {}

  for i = 1, select("#", ...) do
    if type(args[i]) ~= "nil" then
      if type(args[i]) ~= "table" then
        if i == 1  then
          seen[args[i]] = true
        elseif seen[args[i]] then
          seen[args[i]] = nil
        end
      else
        for _, v in ipairs(args[i]) do
          if i == 1 then
            seen[v] = true
          elseif seen[v] then
            seen[v] = nil
          end
        end
      end
    end
  end

  return vim.tbl_keys(seen)
end

---Get the result of the symmetric difference of the given vectors.
---@vararg vector
---@return vector
function M.vec_symdiff(...)
  local result = {}
  local args = {...}
  local seen = {}

  for i = 1, select("#", ...) do
    if type(args[i]) ~= "nil" then
      if type(args[i]) ~= "table" then
        seen[args[i]] = seen[args[i]] == 1 and 0 or 1
      else
        for _, v in ipairs(args[i]) do
          seen[v] = seen[v] == 1 and 0 or 1
        end
      end
    end
  end

  for v, state in pairs(seen) do
    if state == 1 then
      result[#result+1] = v
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

---@class ListBufsSpec
---@field loaded boolean Filter out buffers that aren't loaded.
---@field listed boolean Filter out buffers that aren't listed.
---@field no_hidden boolean Filter out buffers that are hidden.
---@field tabpage integer Filter out buffers that are not displayed in a given tabpage.

---@param opt? ListBufsSpec
function M.list_bufs(opt)
  opt = opt or {}
  local bufs

  if opt.no_hidden or opt.tabpage then
    local wins = opt.tabpage and api.nvim_tabpage_list_wins(opt.tabpage) or api.nvim_list_wins()
    local bufnr
    local seen = {}
    bufs = {}
    for _, winid in ipairs(wins) do
      bufnr = api.nvim_win_get_buf(winid)
      if not seen[bufnr] then
        bufs[#bufs+1] = bufnr
      end
      seen[bufnr] = true
    end
  else
    bufs = api.nvim_list_bufs()
  end

  return vim.tbl_filter(function(v)
    if opt.loaded and not api.nvim_buf_is_loaded(v) then
      return false
    end
    if opt.listed and not vim.bo[v].buflisted then
      return false
    end
    return true
  end, bufs)
end

---@param pattern string Lua pattern mathed against the buffer name.
---@param opt? ListBufsSpec
---@return integer?
function M.find_buf_with_pattern(pattern, opt)
  for _, id in ipairs(M.list_bufs(opt or {})) do
    local m = vim.fn.bufname(id):match(pattern)
    if m then return id end
  end

  return nil
end

---@param var string Variable name.
---@param value any Predicate value.
---@param opt? ListBufsSpec
---@return integer?
function M.find_buf_with_var(var, value, opt)
  for _, id in ipairs(M.list_bufs(opt or {})) do
    local ok, v = pcall(api.nvim_buf_get_var, id, var)
    if ok and v == value then return id end
  end

  return nil
end

---@param option string Option name.
---@param value any Predicate value.
---@param opt? ListBufsSpec
---@return integer?
function M.find_buf_with_option(option, value, opt)
  for _, id in ipairs(M.list_bufs(opt or {})) do
    local ok, v = pcall(api.nvim_buf_get_option, id, option)
    if ok and v == value then return id end
  end

  return nil
end

function M.wipe_all_buffers()
  for _, id in ipairs(api.nvim_list_bufs()) do
    pcall(api.nvim_buf_delete, id, {})
  end
end

function M.get_unique_file_bufname(filename)
  local basename = vim.fn.fnamemodify(filename, ":t")
  local collisions = vim.tbl_map(function(bufnr)
    return api.nvim_buf_get_name(bufnr)
  end, M.list_bufs({ listed = true }))
  collisions = vim.tbl_filter(function(name)
    return name ~= filename and vim.fn.fnamemodify(name, ":t") == basename
  end, collisions)

  -- Derived from: feline.nvim

  -- Reverse filenames in order to compare their names
  filename = string.reverse(filename)
  collisions = vim.tbl_map(string.reverse, collisions)

  local idx = 1

  -- For every other filename, compare it with the name of the current file
  -- char-by-char to find the minimum idx `i` where the i-th character is
  -- different for the two filenames After doing it for every filename, get the
  -- maximum value of `i`
  if next(collisions) then
    local delta_indices = vim.tbl_map(function(filename_other)
        for i = 1, #filename do
          -- Compare i-th character of both names until they aren't equal
          if filename:sub(i, i) ~= filename_other:sub(i, i) then
            return i
          end
        end
        return 1
      end,
      collisions
    )
    idx = math.max(unpack(delta_indices))
  end

  -- Iterate backwards (since filename is reversed) until a path sep is found
  -- in order to show a valid file path
  while idx <= #filename do
    if filename:sub(idx, idx) == path_sep then
      idx = idx - 1
      break
    end

    idx = idx + 1
  end

  return string.reverse(string.sub(filename, 1, idx))
end

---@class SetLocalSpec
---@field method '"set"'|'"remove"'|'"append"'|'"prepend"' Assignment method. (default: "set")

---@class SetLocalListSpec : string[]
---@field opt SetLocalSpec

---HACK: workaround for inconsistent behavior from `vim.opt_local`.
---@see [Neovim issue](https://github.com/neovim/neovim/issues/14670)
---@param winids number[]|number Either a list of winids, or a single winid (0
---for current window).
---@param option_map table<string, SetLocalListSpec|string|boolean>
---@param opt? SetLocalSpec
function M.set_local(winids, option_map, opt)
  if type(winids) ~= "table" then
    winids = { winids }
  end

  opt = vim.tbl_extend("keep", opt or {}, { method = "set" })

  local cmd
  for _, id in ipairs(winids) do
    api.nvim_win_call(id, function()
      for option, value in pairs(option_map) do
        if type(value) == "boolean" then
          cmd = string.format("setl %s%s", value and "" or "no", option)
        else
          ---@type SetLocalSpec
          local o = opt
          if type(value) == "table" then
            o = vim.tbl_extend("force", opt, value.opt or {})
            value = table.concat(value, ",")
          end

          cmd = M.str_template(
            setlocal_opr_templates[o.method],
            { option = option, value = tostring(value):gsub("'", "''") }
          )
        end

        vim.cmd(cmd)
      end
    end)
  end
end

---@param winids number[]|number Either a list of winids, or a single winid (0
---for current window).
---@param option string
function M.unset_local(winids, option)
  if type(winids) ~= "table" then
    winids = { winids }
  end

  for _, id in ipairs(winids) do
    api.nvim_win_call(id, function()
      vim.cmd(string.format("set %s<", option))
    end)
  end
end

---Get a list of all windows that contain the given buffer.
---@param bufid integer
---@param tabpage? integer Only search windows in the given tabpage.
---@return integer[]
function M.win_find_buf(bufid, tabpage)
  local result = {}
  local wins

  if tabpage then
    wins = api.nvim_tabpage_list_wins(tabpage)
  else
    wins = api.nvim_list_wins()
  end

  for _, id in ipairs(wins) do
    if api.nvim_win_get_buf(id) == bufid then
      table.insert(result, id)
    end
  end

  return result
end

function M.file_readable(path)
  local p = uv.fs_realpath(path)
  if p then
    return uv.fs_access(p, "R")
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
