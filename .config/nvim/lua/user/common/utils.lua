---@diagnostic disable: duplicate-doc-field
local lz = require("user.lazy")

local winshift_lib = lz.require("winshift.lib") ---@module "winshift.lib"

local api = vim.api

local M = {}

---@diagnostic disable-next-line: unused-local
local is_windows = jit.os == "Windows"
local path_sep = package.config:sub(1, 1)

--- Path lib
M.Path = lz.require("imminent.fs.Path") ---@module "imminent.fs.Path"

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
    vim.schedule(function() M.echo_multiln(msg, hl, false) end)
    return
  end

  if type(msg) ~= "table" then msg = { msg } end

  local chunks = table.concat(msg, "\n")
  api.nvim_echo({ { chunks, hl } }, true, {})
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

  M.echo_multiln(msg, "DiagnosticSignInfo", schedule)
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

  M.echo_multiln(msg, "DiagnosticSignWarn", schedule)
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

  M.echo_multiln(msg, "DiagnosticSignError", schedule)
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

---Ternary helper for when `if_true` might be a falsy value, and you can't
---compose the expression as `condition and if_true or if_false`. The outcomes
---may be given as lists where the first index is a callable object, and the
---subsequent elements are args to be passed to the callable if the outcome is
---to be evaluated.
---
---Example:
---
---```c
--- // c
--- condition ? "yes" : "no"
--- condition ? foo(1, 2) : bar(3)
---```
---
---```lua
--- -- lua
--- ternary(condition, "yes", "no")
--- ternary(condition, { foo, 1, 2 }, { bar, 3 })
---```
---@param condition any
---@param if_true any
---@param if_false any
---@param plain? boolean Never treat `if_true` and `if_false` as arg lists.
---@return unknown
function M.ternary(condition, if_true, if_false, plain)
  if condition then
    if not plain and type(if_true) == "table" and vim.is_callable(if_true[1]) then
      return if_true[1](M.vec_select(if_true, 2))
    end

    return if_true
  else
    if not plain and type(if_false) == "table" and vim.is_callable(if_false[1]) then
      return if_false[1](M.vec_select(if_false, 2))
    end

    return if_false
  end
end

---Call the function `f` with autocommands disabled.
---@param f function
---@param ... any # Arguments
function M.noautocmd(f, ...)
  local last_eventignore = vim.o.eventignore
  vim.o.eventignore = "all"
  f(...)
  vim.o.eventignore = last_eventignore
end

---Call the function `f`, ignoring most of the window and buffer related
---events. The function is called in protected mode.
---@param f function
---@return boolean success
---@return any result Return value
function M.no_win_event_call(f)
  local last = vim.o.eventignore
  ;(vim.opt.eventignore --[[@as vim.Option ]]):prepend(
    "WinEnter,WinLeave,WinNew,WinClosed,BufWinEnter,BufWinLeave,BufEnter,BufLeave"
  )
  local ok, err = pcall(f)
  vim.opt.eventignore = last

  return ok, err
end

---Update a given window by briefly setting it as the current window.
---@param winid integer
function M.update_win(winid)
  local cur_winid = api.nvim_get_current_win()
  if cur_winid ~= winid then
    local ok, err = M.no_win_event_call(function()
      api.nvim_set_current_win(winid)
      api.nvim_set_current_win(cur_winid)
    end)
    if not ok then
      error(err)
    end
  end
end

---Pick the argument at the given index. A negative number is indexed from the
---end (`-1` is the last argument).
---@param index integer
---@param ... unknown
---@return unknown
function M.pick(index, ...)
  local args = { ... }

  if index < 0 then
    index = #args + index + 1
  end

  return args[index]
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
    --- @diagnostic disable-next-line: assign-type-mismatch
    local m = { str:match(pattern) }
    if #m > 0 then
      return unpack(m)
    end
  end
end

---Smart multiline string that strips the leading indentation.
---
---Example:
---
---```lua
--- utils.info(
---   utils.mstring([[
---     Some long formatted msg
---     with multiple lines
---     and line breaks.
---   ]])
--- )
---```
---@param str string
---@param list? boolean
function M.mstring(str, list)
  local lines = vim.split(str, "\n", { plain = true, trimempty = false })
  local ret = {}
  local i = 1

  if not lines[1]:match("^%s") then i = 2 end
  if lines[#lines]:match("^%s*$") then lines[#lines] = nil end

  local indent_size = math.huge --[[@as int ]]

  for j = i, math.min(#lines, 1024) do
    if lines[j] ~= "" then
      indent_size = math.min(
        indent_size,
        lines[j]:match("^%s*()") --[[@cast -? ]] - 1
      ) --[[@as int ]]
    end
  end

  if indent_size == math.huge then indent_size = 0 end
  local content_pattern = "^" .. string.rep("%s?", indent_size) .. "(.*)$"

  for _, line in ipairs(lines) do
    ret[#ret + 1] = line:match(content_pattern)
  end

  if list then return ret end

  return table.concat(ret, "\n")
end

function M.tbl_pack(...)
  return { n = select('#',...); ... }
end

function M.tbl_unpack(t, i, j)
  return unpack(t, i or 1, j or t.n)
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

---Try property access.
---@param t table
---@param table_path string|string[] Either a `.` separated string of table keys, or a list.
---@return any?
function M.tbl_access(t, table_path)
  local keys = type(table_path) == "table"
      and table_path ---@cast table_path string
      or vim.split(table_path, ".", { plain = true })

  local cur = t

  for _, k in ipairs(keys) do
    cur = cur[k]
    if not cur then
      return nil
    end
  end

  return cur
end

---Set a value in a table, creating all missing intermediate tables in the
---table path.
---@generic T
---@param t table
---@param table_path string|string[] Either a `.` separated string of table keys, or a list.
---@param value T
---@return T value
function M.tbl_set(t, table_path, value)
  local keys = type(table_path) == "table"
      and table_path ---@cast table_path string
      or vim.split(table_path, ".", { plain = true })

  local cur = t

  for i = 1, #keys - 1 do
    local k = keys[i]

    if not cur[k] then
      cur[k] = {}
    end

    cur = cur[k]
  end

  cur[keys[#keys]] = value

  return value
end

---Ensure that the table path is a table in `t`.
---@param t table
---@param table_path string|string[] Either a `.` separated string of table keys, or a list.
function M.tbl_ensure(t, table_path)
  local keys = type(table_path) == "table"
      and table_path ---@cast table_path string
      or vim.split(table_path, ".", { plain = true })

  local ret = M.tbl_access(t, keys)
  assert(
    ret == nil or type(ret) == "table",
    "TypeError :: The table path exists and is of a non-table type!"
  )

  if not ret then
    ret = M.tbl_set(t, keys, {})
  end

  return ret
end

---Create a shallow copy of a portion of a vector. Negative numbers indexes
---from the end.
---@param t vector
---@param first? integer First index, inclusive
---@param last? integer Last index, inclusive
---@return vector
function M.vec_slice(t, first, last)
  local slice = {}

  if first and first < 0 then
    first = #t + first + 1
  end

  if last and last < 0 then
    last = #t + last + 1
  end

  for i = first or 1, last or #t do
    table.insert(slice, t[i])
  end

  return slice
end

---Return all elements in `t` between `first` and `last`. Negative numbers
---indexes from the end.
---@param t vector
---@param first integer First index, inclusive
---@param last? integer Last index, inclusive
---@return any ...
function M.vec_select(t, first, last)
  return unpack(M.vec_slice(t, first, last))
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

---Remove an object from a vector.
---@param t vector
---@param v any
---@return boolean success True if the object was removed.
function M.vec_remove(t, v)
  local idx = M.vec_indexof(t, v)

  if idx > -1 then
    table.remove(t, idx)

    return true
  end

  return false
end

--- @generic T
--- @param t T[]
--- @param comparator? fun(a: T, b: T): boolean
function M.vec_sort(t, comparator)
  local ret = M.vec_slice(t)
  table.sort(ret, comparator)

  return ret
end

---@class Config.utils.ListBufsSpec
---@field no_unloaded? boolean Filter out buffers that aren't loaded.
---@field no_unlisted? boolean Filter out buffers that aren't listed.
---@field no_hidden? boolean Filter out buffers that are hidden.
---@field tabpage? integer Filter out buffers that are not displayed in a given tabpage.
---@field pattern? string Filter out buffers whose name doesn't match a given lua pattern.
---@field options? table<string, any> Filter out buffers that don't match a given map of options.
---@field vars? table<string, any> Filter out buffers that don't match a given map of variables.

---@param opt? Config.utils.ListBufsSpec
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

  return vim.tbl_filter(function(bufnr)
    if opt.no_unloaded and not api.nvim_buf_is_loaded(bufnr) then
      return false
    end

    if opt.no_unlisted and not vim.bo[bufnr].buflisted then
      return false
    end

    if opt.pattern and not vim.fn.bufname(bufnr):match(opt.pattern) then
      return false
    end

    if opt.options then
      for name, value in pairs(opt.options) do
        if vim.bo[bufnr][name] ~= value then
          return false
        end
      end
    end

    if opt.vars then
      for name, value in pairs(opt.vars) do
        if vim.b[bufnr][name] ~= value then
          return false
        end
      end
    end

    return true
  end, bufs) --[[@as integer[] ]]
end

---@param path string
---@param opt? Config.utils.ListBufsSpec
---@return integer? bufnr
function M.find_file_buffer(path, opt)
  local p = M.Path.from(path):absolute():tostring()
  for _, id in ipairs(M.list_bufs(opt)) do
    if p == api.nvim_buf_get_name(id) then
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
---Ref. https://github.com/feline-nvim/feline.nvim
---@param filename string
---@return string
function M.get_unique_file_bufname(filename)
  local basename = vim.fn.fnamemodify(filename, ":t")

  local collisions = vim.tbl_map(function(bufnr)
    return api.nvim_buf_get_name(bufnr)
  end, M.vec_union(M.list_bufs({ no_unlisted = true }), M.list_bufs({ no_hidden = true })))

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
    end, collisions) --[[@as integer[] ]]
    idx = math.max(unpack(delta_indices) --[[@as int... ]])
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

function M.create_fill_buf(opts)
  local bufnr = api.nvim_create_buf(false, true)

  api.nvim_buf_call(bufnr, function()
    opts = vim.tbl_extend("keep", opts or {}, {
      list = false,
      number = false,
      relativenumber = false,
      buflisted = false,
      cursorline = false,
      cursorcolumn = false,
      foldcolumn = "0",
      signcolumn = "no",
      colorcolumn = "",
      swapfile = false,
      undolevels = -1,
      bufhidden = "wipe",
      winhl = "EndOfBuffer:Hidden",
    })

    for k, v in pairs(opts) do
      vim.opt_local[k] = v
    end
  end)

  return bufnr
end

function M.clear_prompt()
  vim.api.nvim_echo({ { "" } }, false, {})
  vim.cmd("redraw")
end

---@class InputCharSpec
---@field clear_prompt boolean (default: true)
---@field allow_non_ascii boolean (default: false)
---@field filter string A lua pattern that the input must match in order to be valid. (default: nil)
---@field loop boolean Loop the input prompt until a valid char is given. (default: false)
---@field prompt_hl string (default: nil)

---@param prompt string
---@param opt InputCharSpec
---@return string? Char
---@return string|number Raw
function M.input_char(prompt, opt)
  opt = vim.tbl_extend("keep", opt or {}, {
    clear_prompt = true,
    allow_non_ascii = false,
    loop = false,
    prompt_hl = nil,
  }) --[[@as InputCharSpec ]]

  --- @type boolean, string?, (string|number)?
  local valid, s, raw

  while true do
    valid = true

    if prompt then
      api.nvim_echo({ { prompt, opt.prompt_hl } }, false, {})
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

    s = type(c) == "number" and vim.fn.nr2char(c) or nil
    raw = type(c) == "number" and s or c

    if opt.filter then
      if s == nil or not s:match(opt.filter) then
        valid = false
      end
    end

    if valid or not opt.loop then break end
  end

  if not valid then
    return nil, -1
  end

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

---@class utils.confirm.Opt
---@field default boolean
---@field callback fun(choice: boolean)

---@param prompt string
---@param opt utils.confirm.Opt
function M.confirm(prompt, opt)
  local ok, s = pcall(
    M.input_char,
    ("%s %s: "):format(
      prompt,
      opt.default and "[Y/n]" or "[y/N]"
    ),
    { filter = "[yYnN\27\r]", loop = true }
  )

  M.clear_prompt()

  if not ok then
    opt.callback(false)
  else
    if s == "\27" then opt.callback(false); return end
    local value = ({
      y = true,
      n = false,
    })[(s or ""):lower()]
    if value == nil then value = opt.default end
    opt.callback(value)
  end
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

--- @class Config.utils.set_local.Opt
--- @field method "set"|"remove"|"append"|"prepend" Assignment method. (default: "set")

--- @class Config.utils.set_local.ListSpec : string[]
--- @field opt? utils.set_local.Opt

--- @param winids number[]|number Either a list of winids, or a single winid (0 for current window).
--- @param option_map WindowOptions
--- @param opt? Config.utils.set_local.Opt
function M.set_local(winids, option_map, opt)
  if type(winids) ~= "table" then
    winids = { winids }
  end

  opt = vim.tbl_extend("keep", opt or {}, { method = "set" }) --[[@as Config.utils.set_local.Opt ]]

  for _, id in ipairs(winids) do
    api.nvim_win_call(id, function()
      for option, value in pairs(option_map) do
        local o = opt
        ---@diagnostic disable-next-line: redundant-parameter
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
              vim.opt_local[fullname] = cur_value:gsub(",?" .. vim.pesc(tostring(value)), "")
            else
              vim.opt_local[fullname]:remove(value)
            end

          elseif o.method == "append" then
            if is_list_like then
              vim.opt_local[fullname] = ("%s%s"):format(
                cur_value ~= "" and cur_value .. "," or "",
                value
              )
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


---Get the byte size of a buffer in kilo bytes.
---
---Approximations of file size going by number of lines in normal code
---(i.e. not minified):
---
--- 2500 lines   ≅ 84.62 kb
--- 5000 lines   ≅ 165.76 kb
--- 10000 lines  ≅ 320.86 kb
--- 20000 lines  ≅ 649.94 kb
--- 40000 lines  ≅ 1314.56 kb
--- 80000 lines  ≅ 2634.88 kb
--- 160000 lines ≅ 5249.33 kb
--- 320000 lines ≅ 10656.35 kb
function M.buf_get_size(bufnr)
  local bytes = api.nvim_buf_get_offset(bufnr, api.nvim_buf_line_count(bufnr))
  return bytes / 1024
end

---@param winid integer
---@return boolean
function M.win_is_float(winid)
  return api.nvim_win_get_config(winid).relative ~= ""
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

---Get the id of a tab page from its tab number.
---@param tabnr integer
---@return integer?
function M.tabnr_to_id(tabnr)
  for _, id in ipairs(api.nvim_list_tabpages()) do
    if api.nvim_tabpage_get_number(id) == tabnr then
      return id
    end
  end
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

---Detect the position of a given window located on one of the far edges of the
---layout.
---@param winid integer
---@return "left"|"right"|"top"|"bottom"|"unknown"
function M.detect_win_pos(winid)
  local tree = winshift_lib.get_layout_tree()
  local node = winshift_lib.find_leaf(tree, winid)

  if node then
    if tree.type ~= "leaf" then
      if tree[1] == node then
        return tree.type == "row" and "left" or "top"
      elseif tree[#tree] == node then
        return tree.type == "row" and "right" or "bottom"
      end
    end
  end

  return "unknown"
end

--- Call a function in protected mode. If the function raises an error, include
--- a traceback in the error.
---
--- @param func function # The function to call.
--- @param ... any # Args to apply to `func`.
--- @return boolean ok
--- @return unknown|string ret # Either the first returned value from `func`, or an error if it failed.
--- @return any ... # Any subsequent values returned from `func`.
function M.trace_pcall(func, ...)
  local err
  local ret = M.tbl_pack(
    xpcall(
      func,
      function (err_msg)
        err = debug.traceback(err_msg, 2)
      end,
      ...
    )
  )

  if not ret[1] then return false, err end

  return M.tbl_unpack(ret)
end

return M
