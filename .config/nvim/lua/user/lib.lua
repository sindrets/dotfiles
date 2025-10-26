local Path = Config.common.utils.Path
local utils = Config.common.utils
local pb = Config.common.pb

local api = vim.api
local fmt = string.format

local M = {}

  ---Expression mapping functions.
local expr = {}
  ---Command callbacks.
local cmd = {}

local scratch_counter = 1

---@class BufToggleEntry
---@field last_winid integer
---@field height integer|nil
local BufToggleEntry = {}
BufToggleEntry.__index = BufToggleEntry

---BufToggleEntry constructor.
---@param opts table
---@return BufToggleEntry
function BufToggleEntry.new(opts)
  opts = opts or {}
  local self = {
    height = opts.height
  }
  setmetatable(self, BufToggleEntry)
  return self
end

--- @class lib.create_view_toggler.Opt
--- A function that should return the buffer id of the wanted buffer if it
--- exists, otherwise nil.
--- @field find fun(): integer?
--- A function that opens the window.
--- @field open fun()
--- A function that closes the window.
--- @field close fun()
--- Focus the window if it exists and is unfocused.
--- @field focus? boolean
--- Adjust the height of the window after opening.
--- @field height? integer
--- Remember the height of the window when it was closed, and restore it the next time its opened.
--- @field remember_height? boolean

--- Create a function that toggles a window with an identifiable buffer of some
--- kind. The toggle logic works as follows:
---
--- - Open if:
---   - The buffer is not found
---   - No window with the buffer is found
--- - Close if:
---   - The buffer is active in the current window.
--- - Focus if (only if the `focus` option is enabled):
---   - The buffer exists, the window exists, but the window is not active.
---@param opts? lib.create_view_toggler.Opt
---@return function
function M.create_view_toggler(opts)
  opts = opts or {}
  local toggler_entry = BufToggleEntry.new({ height = opts.height })

  --- @return { winid: integer, bufnr: integer }? target
  local function find_win()
    local target_bufnr = opts.find()

    if target_bufnr then
      local win_ids = vim.fn.win_findbuf(target_bufnr)

      if next(win_ids) then
        return {
          winid = win_ids[1],
          bufnr = target_bufnr,
        }
      end
    end
  end

  local function open()
    toggler_entry.last_winid = api.nvim_get_current_win()
    local ok, err = pcall(opts.open)

    if not ok then
      return utils.err("[BufToggler] Open callback failed: " .. err)
    end

    if toggler_entry.height then
      local target = find_win()

      if target then
        api.nvim_win_set_height(target.winid, toggler_entry.height)
      else
        -- The window didn't immediately open. Create an autocommand waiting
        -- for the window to appear.
        vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
          callback = function(e)
            target = find_win()

            if target and e.buf == target.bufnr then
              api.nvim_win_set_height(target.winid, toggler_entry.height)
              return true
            end
          end,
        })
      end
    end
  end

  local function close()
    if opts.remember_height then
      toggler_entry.height = api.nvim_win_get_height(0)
    end

    local ok, err = pcall(opts.close)

    if not ok then
      return utils.err("[BufToggler] Close callback failed: " .. err)
    end

    if api.nvim_win_is_valid(toggler_entry.last_winid or -1) then
      api.nvim_set_current_win(toggler_entry.last_winid)
    else
      vim.cmd("wincmd p")
    end
  end

  return function()
    local target = find_win()

    if not target then
      open()
    else
      if target.bufnr == api.nvim_get_current_buf() then
        -- It's the current window: close it.
        close()
        return
      end

      if opts.focus then
        -- The window exists, but is not active: focus it.
        toggler_entry.last_winid = api.nvim_get_current_win()
        api.nvim_set_current_win(target.winid)
      else
        api.nvim_win_call(target.winid, close)
      end
    end
  end
end

function M.execute_macro_over_visual_range()
  print("@" .. vim.fn.getcmdline())
  vim.fn.execute(":'<,'>normal @" .. vim.fn.nr2char(vim.fn.getchar()))
end

---@param range CommandRange
---@param ... string
function M.read_ex(range, ...)
  local args = vim.tbl_map(function (v)
    return vim.fn.expand(v)
  end, { ... })

  local ok, out = pcall(api.nvim_exec, table.concat(args, " "), true)

  if not ok then
    if out and out ~= "" then
      utils.err(out)
    end

    return
  end

  local line = range[1] > 0 and range[2] or "."
  vim.fn.setreg("x", out)
  vim.cmd(line .. "put =@x")
end

---@param range CommandRange
---@param ... string
function M.read_shell(range, ...)
  local args = vim.tbl_map(function(v)
    return ("'%s'"):format(vim.fn.expand(v):gsub("'", [['"'"']]))
  end, { ... }) --[[@as vector ]]

  local line = range[1] > 0 and range[2] or "."
  vim.fn.execute(line .. "r! " .. table.concat(args, " "))
end

---@return string[]
function M.get_visual_selection()
  local pos = vim.fn.getpos("'<")
  local line_start = pos[2]
  local column_start = pos[3]

  pos = vim.fn.getpos("'>")
  local line_end = pos[2]
  local column_end = pos[3]

  local lines = api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
  if #lines == 0 then
    return { "" }
  end

  local selection = vim.o.selection
  lines[#lines] = lines[#lines]:sub(1, column_end - (selection == "inclusive" and 0 or 1))
  lines[1] = lines[1]:sub(column_start, -1)

  return lines
end

function M.diff_saved()
  local filetype = api.nvim_buf_get_option(0, "filetype")
  vim.cmd("tab split | diffthis")
  vim.cmd("aboveleft vnew | r # | normal! 1Gdd")
  vim.cmd("diffthis")
  vim.cmd("setlocal bt=nofile bh=wipe nobl noswf ro ft=" .. filetype)
  vim.cmd("wincmd l")
end

function M.workspace_files(opt)
  opt = opt or {}

  if opt.all then
    Snacks.picker.files({
      hidden = true,
      cmd = "fd",
      args = { "--type", "f", "-uu", "--strip-cwd-prefix" },
    })
  elseif vim.env.GIT_DIR or Path.from("./.git"):is_readable():block_on() then
    Snacks.picker.git_files({
      untracked = true,
    })
  else
    Snacks.picker.files({
      hidden = true,
      cmd = "fd",
      args = { "--type", "f", "--strip-cwd-prefix" },
    })
  end
end

---Delete a buffer while also preserving the window layout. Changes the current
---buffer to the alt buffer if available, and then deletes it.
---@param force boolean Ignore unsaved changes.
---@param bufnr? integer
function M.remove_buffer(force, bufnr)
  local new_bufnr
  local cur_bufnr = api.nvim_get_current_buf()
  bufnr = bufnr or cur_bufnr

  if not api.nvim_buf_is_valid(bufnr) then return end

  if not force and vim.bo[bufnr].modified then
    utils.err("No write since last change!")
    return
  end

  -- Get all windows that currently display the target
  local wins = vim.tbl_filter(function(v)
    return api.nvim_win_get_buf(v) == bufnr
  end, api.nvim_list_wins()) --[[@as vector ]]

  if #wins == 0 then
    new_bufnr = api.nvim_get_current_buf()

    if new_bufnr == bufnr then
      new_bufnr = api.nvim_create_buf(true, false)
    end
  else
    local alt_win

    if api.nvim_get_current_buf() == bufnr then
      alt_win = api.nvim_get_current_win()
    else
      alt_win = wins[1]
    end

    api.nvim_win_call(alt_win, function()
      -- bufnr("#") only works correctly when called from the current buffer.
      local alt_bufnr = bufnr == cur_bufnr and vim.fn.bufnr("#") or -1

      if alt_bufnr ~= -1 and api.nvim_buf_is_loaded(alt_bufnr) then
        api.nvim_set_current_buf(alt_bufnr)
      else
        local listed = utils.list_bufs({ no_unlisted = true })
        if #listed > (vim.bo[bufnr].buflisted and 1 or 0) then
          vim.cmd("silent! bp")
        else
          vim.cmd("enew")
        end
      end

      new_bufnr = api.nvim_get_current_buf()
    end)
  end

  -- Change the buffer in all windows that currently display the target
  -- buffer.
  for _, winid in ipairs(wins) do
    api.nvim_win_set_buf(winid, new_bufnr)
  end

  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_delete(bufnr, { unload = true, force = true })
    vim.bo[bufnr].buflisted = false
  end
end

--- @param force boolean
--- @param bufnr? number
function M.smart_buf_delete(force, bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()

  local wins = vim.tbl_filter(
    function(win) return not utils.win_is_float(win) end,
    api.nvim_tabpage_list_wins(0)
  )

  if #wins > 1 then
    local cur_winid = api.nvim_get_current_win()
    vim.cmd("wincmd p")
    api.nvim_win_close(cur_winid, false)
  end

  pcall(M.remove_buffer, force, bufnr)
end

---Split a line on all matches of a given pattern.
---@param pattern string Vim pattern.
---@param range integer[]
---@param noformat? boolean Don't format the split lines.
function M.split_on_pattern(pattern, range, noformat)
  if pattern == "" then
    pattern = vim.fn.getreg("/")
  end
  local epattern = pattern:gsub("/", "\\/")
  local last_line = api.nvim_win_get_cursor(0)[1]

  local ok, err = pcall(vim.cmd, string.format(
    [[%ss/%s/\0\r/g]],
    range[1] == 0 and "" or ("%d,%d"):format(range[2], range[3]),
    epattern,
    epattern
  ))
  vim.cmd("noh")

  if not ok then
    utils.err(err)
    return
  end

  if not noformat then
    local new_line = api.nvim_win_get_cursor(0)[1]
    local delta = math.abs(new_line - last_line)
    if delta > 1 then
      local view = vim.fn.winsaveview()
      vim.cmd(("norm! =%dk"):format(delta - 1))
      vim.fn.winrestview(view)
    end
  end
end

function M.indent_size()
  if vim.o.expandtab then
    return vim.o.shiftwidth
  else
    return vim.o.tabstop
  end
end

---Get the expected indent size of the current line.
---@return integer
function M.get_cline_indent_size()
  -- [lnum, col]
  local save_cursor = api.nvim_win_get_cursor(0)
  if save_cursor[1] == 0 then return 0 end

  local ok, size
  local indentexpr = vim.bo.indentexpr

  if indentexpr and indentexpr ~= "" then
    ok, size = pcall(vim.api.nvim_eval, indentexpr)

    -- Restore cursor pos. 'indentexpr' is allowed to move the cursor.
    api.nvim_win_set_cursor(0, save_cursor)

    if ok then
      return size
    end
  end

  local indent = vim.fn.cindent(save_cursor[1])

  return indent
end

function M.full_indent()
  local pos = api.nvim_win_get_cursor(0)
  local col = pos[2]
  local cline = api.nvim_get_current_line()
  local last_col = #cline
  local first_nonspace = cline:match("^%s*()%S")

  local tab_char = "	"
  if first_nonspace or col < last_col then
    api.nvim_feedkeys(tab_char, "n", false)
    return
  end

  local et = vim.bo.et
  local sw = vim.bo.sw
  local ts = vim.bo.ts

  if not et and sw ~= ts then
    vim.opt_local.sw = ts
  end

  local indent = M.get_cline_indent_size()

  if et then
    if indent == 0 then
      indent = sw > 0 and sw or 4
    end

    if indent <= col then
      api.nvim_feedkeys(tab_char, "n", false)
      return
    end

    vim.cmd("normal! d0x")
    api.nvim_feedkeys(string.rep(" ", indent), "n", false)
  else
    if indent == 0 then
      indent = ts > 0 and ts or 4
    end

    if (indent / ts) <= col then
      api.nvim_feedkeys(tab_char, "n", false)
      return
    end

    local ntabs = math.floor(indent / ts)
    local nspaces = indent - ntabs * ts
    vim.cmd("normal! d0x")
    api.nvim_feedkeys(
      string.rep(tab_char, ntabs) .. string.rep(" ", nspaces),
      "n", false
    )
  end
end

function M.name_syn_stack()
  local stack = vim.fn.synstack(vim.fn.line("."), vim.fn.col("."))
  stack = vim.tbl_map(function(v)
    return vim.fn.synIDattr(v, "name")
  end, stack)
  return stack
end

function M.print_syn_group()
  local id = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)
  print("synstack:", vim.inspect(M.name_syn_stack()))
  print(vim.fn.synIDattr(id, "name") .. " -> " .. vim.fn.synIDattr(vim.fn.synIDtrans(id), "name"))
end

---@param filetype? string
function M.new_scratch_buf(filetype)
  local bufid = api.nvim_create_buf(true, true)
  local name = "Scratch " .. scratch_counter
  scratch_counter = scratch_counter + 1
  api.nvim_buf_set_name(bufid, name)
  api.nvim_win_set_buf(0, bufid)
  vim.bo[bufid].buftype = "nowrite"

  if filetype then
    vim.bo[bufid].filetype = filetype
  end

  return bufid
end

---@class lib.comfy_quit.Opt
---@field keep_last boolean Don't close the window if it's the last window.

---Close the current window and bring focus to the last used window.
---@param opt? lib.comfy_quit.Opt
function M.comfy_quit(opt)
  opt = opt or {}
  local cur_win = api.nvim_get_current_win()
  local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
  local command = "q"
  local ok, err

  if opt.keep_last then
    local wins = vim.tbl_filter(function(v)
      return api.nvim_win_get_config(v).relative == ""
    end, api.nvim_list_wins())

    if #wins == 1 then
      command = "bd"
    end
  end

  ok, err = pcall(vim.cmd, command)

  if not ok then
    utils.err(err)
  elseif cur_win ~= prev_win then
    api.nvim_set_current_win(prev_win)
  end
end

---Perform a `:grep` command, populate and open the quickfix list, and set the
---`/` register to a vim pattern matching the given regex pattern.
---@param use_loclist boolean Use the location list for the current window.
---@param ... string Args passed to the 'grepprg'.
function M.comfy_grep(use_loclist, ...)
  local args = { ... }
  local cargs = vim.tbl_map(function(arg)
    return (vim.fn.shellescape(arg):gsub("[|]", { ["'"] = "''", ["|"] = "\\|" }))
  end, args) --[[@as table ]]

  local command = use_loclist and "lgrep! " or "grep! "

  local ok, err = pcall(vim.api.nvim_exec, command .. table.concat(cargs, " "), true)
  if not ok then
    utils.err(err)
    return
  end

  vim.fn.setreg("/", M.regex_to_pattern(args[1]))
  vim.opt.hlsearch = true
  if use_loclist then
    vim.cmd("belowright lope")
  else
    vim.cmd("belowright cope")
  end
end

---Convert a PCRE regex to a vim pattern. WARN: Conversion is incomplete.
---@param exp string
---@return string
function M.regex_to_pattern(exp)
  local subs = {
    { "@", "\\@" },                                 -- Escape at sign
    { "~", "\\~" },                                 -- Escape tilde
    { "([^\\]?)%((%?<%=)([^)]-)%)", "%1(%3)@<=" },  -- Positive lookbehind
    { "([^\\]?)%((%?<%!)([^)]-)%)", "%1(%3)@<!" },  -- Negative lookbehind
    { "([^\\]?)%((%?%=)([^)]-)%)", "%1(%3)@=" },    -- Positive lookahead
    { "([^\\]?)%((%?%!)([^)]-)%)", "%1(%3)@!" },    -- Negative lookahead
    { "([^\\]?)%(%?:", "%1%%(" },                   -- Non-capturing group
    { "%*%?", "{-}" },                              -- Lazy quantifier
    { "([^?]?)<", "%1\\<" },                        -- Escape chevrons
    { "([^?]?)>", "%1\\>" },
    { "\\b", "%%(<|>)" },                           -- Word boundary
    { "([^?<]?)=", "%1\\=" },                       -- Escape equal sign
  }
  for _, sub in ipairs(subs) do
    exp = exp:gsub(sub[1], sub[2])
  end
  return "\\v" .. exp
end

--- Filter the items in the quickfix list either by a given pattern, or the
--- pattern in the `/` register.
---
--- @param invert boolean # Invert the predicate. Filter _out_ anything that matches.
--- @param pattern? string
function M.filter_qf(invert, pattern)
  if not pattern then
    pattern = vim.fn.getreg("/")
    if pattern == "" then
      utils.err("No filter pattern provided, and no pattern in the '/' register!")
      return
    end
  end

  local pat = assert(vim.regex(pattern), fmt("Invalid vim regex: %s", pattern))

  vim.fn.setqflist(
    pb.Iter
      .new(vim.fn.getqflist())
      :filter(function(item)
        local filename = api.nvim_buf_get_name(item.bufnr)
        local matches = not not (pat:match_str(item.text) or pat:match_str(filename))
        if invert then return not matches end

        return matches
      end)
      :totable()
  )
end

---When enabled: always keep the cursor centered in the current window while
---scrolling.
---@param flag? boolean Acts as a toggle when the flag value is omitted.
function M.set_center_cursor(flag)
  -- Just some arbitrarily high number
  local scrolloff_center = 4096
  local cur_scrolloff = vim.go.scrolloff

  if type(flag) ~= "boolean" then
    flag = cur_scrolloff ~= scrolloff_center
  end

  local last = Config.state.last_scrolloff or (
      cur_scrolloff ~= scrolloff_center and cur_scrolloff or 0
  )
  local scrolloff_target = flag and scrolloff_center or last

  if cur_scrolloff == scrolloff_target then
    return
  end

  if flag then
    Config.state.last_scrolloff = vim.go.scrolloff
  end

  vim.opt.scrolloff = scrolloff_target

  if flag then
    utils.info("Cursor centered.")
  else
    utils.info("Cursor unlocked.")
  end
end

---Move a keymap.
---@param mode string Current mode.
---@param lhs string Current lhs.
---@param new_mode string
---@param new_lhs string
---@param buffer? integer
function M.mv_keymap(mode, lhs, new_mode, new_lhs, buffer)
  local mapinfo

  if buffer then
    mapinfo = api.nvim_buf_get_keymap(buffer, mode)
  else
    mapinfo = api.nvim_get_keymap(mode)
  end

  for _, map in ipairs(mapinfo) do
    if map.mode == mode and map.lhs == lhs then
      local opts = {
        buffer = buffer,
        expr = map.expr == 1,
        remap = map.noremap == 0,
        nowait = map.nowait == 1,
        silent = map.silent == 1,
      }

      vim.keymap.set(new_mode, new_lhs, map.rhs or map.callback, opts)
      vim.keymap.del(mode, lhs, { buffer = buffer })
    end
  end
end

---@alias CommandRange { [1]: integer, [2]: integer, [3]: integer }

function cmd.read_new(...)
  local args = { ... }

  if #args == 0 then return end

  local prefix = args[1]:sub(1, 1) or nil
  local ex_mode, shell_mode = false, false

  vim.cmd("enew")

  if prefix == ":" then
    ex_mode = true
    args[1] = args[1]:sub(2)
    M.read_ex({ 0 }, unpack(args))
  elseif prefix == "!" then
    shell_mode = true
    args[1] = args[1]:sub(2)
    M.read_shell({ 0 }, unpack(args))
  else
    vim.cmd("read " .. table.concat(args, " "))
  end

  if ex_mode or shell_mode then
    vim.opt_local.filetype = "log"
  end

  vim.cmd('norm! gg"_ddG')
end

---[EXPR] Search for the current word without jumping forward. Respects
---`v:count`.
---@param reverse boolean
---@param count integer
---@return string
function expr.comfy_star(reverse, count)
  count = count or vim.v.count
  vim.fn.setreg("/", "\\<" .. vim.fn.expand("<cword>") .. "\\>")
  local ret = "<Cmd>set hlsearch <Bar> exe 'norm! wN'"

  if count > 0 then
    ret = string.format(
      "%s <Bar> norm! %d%s",
      ret,
      count,
      reverse and "N" or "n"
    )
  end

  return utils.t(ret .. "<CR>")
end

---[EXPR] Jump to the next reference of the item under the cursor. Uses LSP
---when available, otherwise performs a normal search for the current word.
---@param reverse boolean
---@return string
function expr.next_reference(reverse)
  if type(reverse) ~= "boolean" then
    reverse = false
  end
  if #vim.lsp.get_active_clients({ bufnr = 0 }) > 0 then
    return utils.t(string.format(
      '<Cmd>lua require("illuminate").goto_%s_reference()<CR>',
      reverse and "prev" or "next"
    ))
  else
    return expr.comfy_star(reverse, 1)
  end
end

---Open a help page in the current window.
function cmd.help_here(subject)
  local mods = ""
  if vim.bo.buftype ~= "help" then
    vim.cmd("e $VIMRUNTIME/doc/help.txt")
    vim.bo.buftype = "help"
    vim.bo.buflisted = false
    mods = "keepjumps keepalt"
  end

  local ok, err = pcall(vim.api.nvim_exec, string.format("%s help %s", mods, subject), true)
  if not ok then
    M.remove_buffer(true)
    utils.err(err)
  end
end

---Open a man page in the current window.
function cmd.man_here(a, b)
  local tag = a
  if b then
    tag = string.format("%s(%s)", b, a)
  end

  local mods = ""
  if api.nvim_buf_get_name(0) ~= "manhere://0" then
    vim.cmd("e manhere://0")
    vim.bo.buftype = "nofile"
    vim.bo.buflisted = false
    vim.bo.filetype = "man"
    vim.bo.tagfunc = "v:lua.require'man'.goto_tag"
    mods = "keepjumps keepalt"
  end

  local ok, err = pcall(vim.api.nvim_exec, string.format("%s tag %s", mods, tag), true)
  if not ok then
    M.remove_buffer(true)
    utils.err(err)
  end
end

---Execute the currently selected text as either vimscript or lua (derived from
---filetype, defaults to vimscript). If no selection range is provided, the last
---selection is used instead.
---@param range? integer[]
--- @param bin? string
function cmd.exec_selection(range, bin)
  local ft = vim.bo.ft == "lua" and "lua" or "vim"
  local lines
  ---@cast range integer[]
  if type(range) == "table" and range[1] > 0 then
    local r = utils.vec_join(range[2], range[3])
    table.sort(r)
    lines = api.nvim_buf_get_lines(0, r[1] - 1, r[2], false)
  else
    lines = M.get_visual_selection()
  end

  if bin and bin ~= "" then
    Config.state.term.term_split:open(true)
    Config.term.send(
      utils.vec_join(
        bin .. " <<<$(cat << ___EOF___",
        lines,
        "___EOF___",
        ")"
      )
    )
    return
  end

  local ok, out
  if ft == "vim" then
    ok, out = pcall(api.nvim_exec, table.concat(lines, "\n"), true)
    if ok and out then
      print(out)
    end
  else
    ok, out = pcall(utils.exec_lua, table.concat(lines, "\n"))
  end

  if not ok and out then
    utils.err(out)
  end
end

---Open a new tabpage for editing markdown.
---@param new boolean
---@param name? string
function cmd.md_view(new, name)
  vim.cmd([[tab sp]])
  local tabid = api.nvim_get_current_tabpage()
  local winid = api.nvim_get_current_win()
  vim.t.mdview = 1
  vim.cmd([[belowright vnew]])
  local margin_winid = api.nvim_get_current_win()

  utils.set_local(0, {
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

  api.nvim_set_current_win(winid)
  api.nvim_win_set_width(winid, 100)

  if not new and name then
    vim.cmd(("e %s"):format(vim.fn.fnameescape(vim.fn.expand(name))))
  elseif not (not new and not name and vim.bo[0].filetype == "markdown") then
    vim.cmd("enew")
  end

  utils.set_local(0, {
    colorcolumn = "",
    winfixwidth = true,
    spell = true,
  })

  if vim.bo[0].filetype == "" then
    vim.opt_local.filetype = "markdown"
  end

  -- Auto close the tabpage id the margin is the last window
  api.nvim_create_autocmd("WinClosed", {
    pattern = "*",
    callback = function(state)
      if not api.nvim_tabpage_is_valid(tabid) then
        api.nvim_del_autocmd(state.id)
        return
      end

      local wins = vim.tbl_filter(function(v)
        return api.nvim_win_get_config(v).relative == ""
      end, api.nvim_tabpage_list_wins(tabid)) --[[@as vector ]]

      if #wins == 1 and wins[1] == margin_winid then
        api.nvim_win_close(margin_winid, true)
        api.nvim_del_autocmd(state.id)
      end
    end,
  })
end

---There's `:buffers`, there's `:tabs`. Now - finally - there's `:Windows`.
---@param all boolean List windows from all tabpages.
function cmd.windows(all)
  local tabs = all and api.nvim_list_tabpages() or { api.nvim_get_current_tabpage() }
  local curwin = api.nvim_get_current_win()
  local alt_tabid, alt_winid

  if all then
    local alt_tabnr = vim.fn.tabpagenr("#")
    if alt_tabnr > 0 then
      alt_tabid = utils.tabnr_to_id(alt_tabnr)
      alt_winid = api.nvim_tabpage_get_win(alt_tabid)
    end
  end

  local res = {}
  local sigil_map = {
    [curwin] = ">",
    [alt_winid or -1] = "#",
  }

  for i, tabid in ipairs(tabs) do
    res[#res + 1] = "Tab page " .. i
    local wins = api.nvim_tabpage_list_wins(tabid)

    utils.vec_push(res, unpack(vim.tbl_map(function(v)
      local bufnr = api.nvim_win_get_buf(v)
      local name = api.nvim_buf_get_name(bufnr)

      return ("  %s %d  % 4d  %s%s"):format(
        sigil_map[v] or " ",
        v,
        bufnr,
        ("%s%s"):format(
          (api.nvim_win_get_config(v).relative ~= "") and "[float] " or "",
          (vim.bo[bufnr].buftype == "quickfix") and "[quickfix] " or ""
        ),
        utils.str_quote(name)
      )
    end, wins) --[[@as vector ]]))
  end

  print(table.concat(res, "\n"))
end

function M.nav_display_line(delta)
  local old_cursor = vim.fn.getcurpos()
  vim.cmd("norm! g0")
  local old_dsp_first = vim.fn.getcurpos()
  vim.cmd("norm! g$")
  local old_dsp_last = vim.fn.getcurpos()

  local old_full_line = api.nvim_buf_get_lines(0, old_cursor[2] - 1, old_cursor[2], false)[1]
  local old_dsp_line = old_full_line:sub(old_dsp_first[3], old_dsp_last[3])
  local old_dsp_lead = old_dsp_line:sub(1, old_cursor[3] - old_dsp_first[3])

  local motion = delta < 0 and "gk" or "gj"
  vim.cmd(fmt("norm! %d%s", math.abs(delta), motion))

  vim.cmd("norm! g0")
  local dsp_first = vim.fn.getcurpos()
  vim.cmd("norm! g$")
  local dsp_last = vim.fn.getcurpos()

  -- local full_line = api.nvim_buf_get_lines(0, new_cursor[2] - 1, new_cursor[2], false)[1]
  -- local dsp_line = full_line:sub(dsp_first[3], dsp_last[3])

  vim.fn.winrestview({
    col = utils.clamp(
      dsp_first[3] + vim.api.nvim_strwidth(old_dsp_lead) - 1,
      dsp_first[3],
      dsp_last[3]
    ),
    curswant = old_cursor[5],
  })
end

M.BufToggleEntry = BufToggleEntry
M.expr = expr
M.cmd = cmd

return M
