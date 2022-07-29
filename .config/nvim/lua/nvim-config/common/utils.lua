local lazy = require("nvim-config.lazy")

local api = vim.api

local M = {}

---@diagnostic disable-next-line: unused-local
local is_windows = jit.os == "Windows"
local path_sep = package.config:sub(1, 1)

---Path lib
---@type PathLib
M.pl = lazy.require("diffview.path", function(m)
  local pl = m.PathLib({ separator = "/" })

  -- TODO: remove when pushed to upstream diffview.nvim
  if not pl.is_dir then
    ---@class PathLib
    ---@field is_dir fun(self: PathLib, path: string): boolean

    pl.is_dir = pl.is_directory
  end

  return pl
end)

-- Set up completion wrapper used by `vim.ui.input()`
vim.cmd([[
  function! Config__ui_input_completion(...) abort
    return luaeval("Config.state.current_completer(
          \ unpack(vim.fn.eval('a:000')))")
  endfunction
]])

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
    msg = vim.split(msg, "\n", {})
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
    msg = vim.split(msg, "\n", {})
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
    msg = vim.split(msg, "\n", {})
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
    msg = vim.split(msg, "\n", {})
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
  return api.nvim_replace_termcodes(s, true, true, true) --[[@as string ]]
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

---@class utils.StrQuoteSpec
---@field esc_fmt string Format string for escaping quotes. Passed to `string.format()`.
---@field prefer_single boolean Prefer single quotes.
---@field only_if_whitespace boolean Only quote the string if it contains whitespace.

---@param s string
---@param opt? utils.StrQuoteSpec
function M.str_quote(s, opt)
  ---@cast opt utils.StrQuoteSpec
  s = tostring(s)
  opt = vim.tbl_extend("keep", opt or {}, {
    esc_fmt = [[\%s]],
    prefer_single = false,
    only_if_whitespace = false,
  }) --[[@as utils.StrQuoteSpec ]]

  if opt.only_if_whitespace and not s:find("%s") then
    return s
  end

  local primary, secondary = [["]], [[']]
  if opt.prefer_single then
    primary, secondary = [[']], [["]]
  end

  local has_primary = s:find(primary) ~= nil
  local has_secondary = s:find(secondary) ~= nil

  if has_primary and not has_secondary then
    return secondary .. s .. secondary
  else
    local esc = opt.esc_fmt:format(primary)
    -- First un-escape already escaped quotes to avoid incorrectly applied escapes.
    s, _ = s:gsub(vim.pesc(esc), primary)
    s, _ = s:gsub(primary, esc)
    return primary .. s .. primary
  end
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

---Match a given string against multiple patterns.
---@param str string
---@param patterns string[]
---@return ... captured: The first match, or `nil` if no patterns matched.
function M.str_match(str, patterns)
  for _, pattern in ipairs(patterns) do
    local m = { str:match(pattern) }
    if #m > 0 then
      return unpack(m)
    end
  end
end

function M.tbl_pack(...)
  return { n = select('#',...); ... }
end

function M.tbl_unpack(t, i, j)
  return unpack(t, i or 1, j or t.n or #t)
end

function M.tbl_clear(t)
  for k, _ in pairs(t) do
    t[k] = nil
  end
end

function M.tbl_clone(t)
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

---Deep extend a table, and also perform a union on all sub-tables.
---@param t table
---@param ... table
---@return table
function M.tbl_union_extend(t, ...)
  local res = M.tbl_clone(t)

  local function recurse(ours, theirs)
    -- Get the union of the two tables
    local sub = M.vec_union(ours, theirs)

    for k, v in pairs(ours) do
      if type(k) ~= "number" then
        sub[k] = v
      end
    end

    for k, v in pairs(theirs) do
      if type(k) ~= "number" then
        if type(v) == "table" then
          sub[k] = recurse(sub[k] or {}, v)
        else
          sub[k] = v
        end
      end
    end

    return sub
  end

  for _, theirs in ipairs({ ... }) do
    res = recurse(res, theirs)
  end

  return res
end

---Perform a map and also filter out index values that would become `nil`.
---@param t table
---@param func fun(value: any): any?
---@return table
function M.tbl_fmap(t, func)
  local ret = {}

  for key, item in pairs(t) do
    local v = func(item)
    if v ~= nil then
      if type(key) == "number" then
        table.insert(ret, v)
      else
        ret[key] = v
      end
    end
  end

  return ret
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
---@param ... any
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
---@param ... vector
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
---@param ... vector
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
---@param ... vector
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
---@return integer[] #Buffer numbers of matched buffers.
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
  end, bufs) --[[@as integer[] ]]
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

---@param path string
---@param opt? ListBufsSpec
---@return integer? bufnr
function M.find_file_buffer(path, opt)
  local p = M.pl:absolute(path)
  for _, id in ipairs(M.list_bufs(opt)) do
    if p == vim.api.nvim_buf_get_name(id) then
      return id
    end
  end
end

function M.wipe_all_buffers()
  for _, id in ipairs(api.nvim_list_bufs()) do
    pcall(api.nvim_buf_delete, id, {})
  end
end

---Get the filename with the least amount of path segments necessary to make it
---unique among the currently listed buffers.
---
---Derived from feline.nvim.
---@see [feline.nvim](https://github.com/feline-nvim/feline.nvim)
---@param filename string
---@return string
function M.get_unique_file_bufname(filename)
  local basename = vim.fn.fnamemodify(filename, ":t")

  local collisions = vim.tbl_map(function(bufnr)
    return api.nvim_buf_get_name(bufnr)
  end, M.list_bufs({ listed = true }))

  collisions = vim.tbl_filter(function(name)
    return name ~= filename and vim.fn.fnamemodify(name, ":t") == basename
  end, collisions)

  -- Reverse filenames in order to compare their names
  filename = string.reverse(filename)
  collisions = vim.tbl_map(string.reverse, collisions) --[[@as string[] ]]

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
    ) --[[@as integer[] ]]
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

function M.clear_prompt()
  vim.api.nvim_echo({ { "" } }, false, {})
  vim.cmd("redraw")
end

---@class InputCharSpec
---@field clear_prompt boolean (default: true)
---@field allow_non_ascii boolean (default: true)
---@field prompt_hl string (default: nil)

---@param prompt string
---@param opt InputCharSpec
---@return string? Char
---@return string|number Raw
function M.input_char(prompt, opt)
  opt = vim.tbl_extend("keep", opt or {}, {
    clear_prompt = true,
    allow_non_ascii = false,
    prompt_hl = nil,
  }) --[[@as InputCharSpec ]]

  if prompt then
    vim.api.nvim_echo({ { prompt, opt.prompt_hl } }, false, {})
  end

  local c
  if not opt.allow_non_ascii then
    while type(c) ~= "number" do
      c = vim.fn.getchar()
    end
  else
    c = vim.fn.getchar()
  end

  if opt.clear_prompt then
    M.clear_prompt()
  end

  local s = type(c) == "number" and vim.fn.nr2char(c) or nil
  local raw = type(c) == "number" and s or c
  return s, raw
end

---@class InputSpec
---@field default string
---@field completion string|function
---@field cancelreturn string
---@field callback fun(response: string?)

---@param prompt string
---@param opt InputSpec
function M.input(prompt, opt)
  local completion = opt.completion
  if type(completion) == "function" then
    Config.state.current_completer = completion
    completion = "customlist,Config__ui_input_completion"
  end

  vim.ui.input({
    prompt = prompt,
    default = opt.default,
    completion = completion,
    cancelreturn = opt.cancelreturn,
  }, opt.callback)

  M.clear_prompt()
end

function M.raw_key(vim_key)
  return api.nvim_eval(string.format([["\%s"]], vim_key))
end

---@param msg? string
function M.pause(msg)
  vim.cmd("redraw")
  M.input_char(
    "-- PRESS ANY KEY TO CONTINUE -- " .. (msg or ""),
    { allow_non_ascii = true, prompt_hl = "Directory" }
  )
end

---Map of options that accept comma separated, list-like values, but don't work
---correctly with Option:set(), Option:append(), Option:prepend(), and
---Option:remove() (seemingly for legacy reasons).
---WARN: This map is incomplete!
local list_like_options = {
  winhighlight = true,
  listchars = true,
  fillchars = true,
}

---@class utils.set_local.Opt
---@field method '"set"'|'"remove"'|'"append"'|'"prepend"' Assignment method. (default: "set")

---@class utils.set_local.ListSpec : string[]
---@field opt utils.set_local.Opt

---@alias WindowOptions table<string, boolean|integer|string|utils.set_local.ListSpec>

---@param winids number[]|number Either a list of winids, or a single winid (0 for current window).
---@param option_map WindowOptions
---@param opt? utils.set_local.Opt
function M.set_local(winids, option_map, opt)
  if type(winids) ~= "table" then
    winids = { winids }
  end

  opt = vim.tbl_extend("keep", opt or {}, { method = "set" }) --[[@as table ]]

  for _, id in ipairs(winids) do
    api.nvim_win_call(id, function()
      for option, value in pairs(option_map) do
        local o = opt
        local fullname = api.nvim_get_option_info(option).name
        local is_list_like = list_like_options[fullname]
        local cur_value = vim.o[fullname]

        if type(value) == "table" then
          if value.opt then
            o = vim.tbl_extend("force", opt, value.opt) --[[@as table ]]
          end

          if is_list_like then
            value = table.concat(value, ",")
          end
        end

        if o.method == "set" then
          vim.opt_local[option] = value

        else
          if o.method == "remove" then
            if is_list_like then
              vim.opt_local[fullname] = cur_value:gsub(",?" .. vim.pesc(value), "")
            else
              vim.opt_local[fullname]:remove(value)
            end

          elseif o.method == "append" then
            if is_list_like then
              vim.opt_local[fullname] = ("%s%s"):format(cur_value ~= "" and cur_value .. ",", value)
            else
              vim.opt_local[fullname]:append(value)
            end

          elseif o.method == "prepend" then
            if is_list_like then
              vim.opt_local[fullname] = ("%s%s%s"):format(
                value,
                cur_value ~= "" and "," or "",
                cur_value
              )
            else
              vim.opt_local[fullname]:prepend(value)
            end
          end
        end
      end
    end)
  end
end

---@param winids number[]|number Either a list of winids, or a single winid (0 for current window).
---@param option string
function M.unset_local(winids, option)
  if type(winids) ~= "table" then
    winids = { winids }
  end

  for _, id in ipairs(winids) do
    api.nvim_win_call(id, function()
      vim.opt_local[option] = nil
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

---Set the (1,0)-indexed cursor position without having to worry about
---out-of-bounds coordinates. The line number is clamped to the number of lines
---in the target buffer.
---@param winid integer
---@param line? integer
---@param column? integer
function M.set_cursor(winid, line, column)
  local bufnr = api.nvim_win_get_buf(winid)

  pcall(api.nvim_win_set_cursor, winid, {
    M.clamp(line or 1, 1, api.nvim_buf_line_count(bufnr)),
    math.max(0, column or 0)
  })
end

return M
