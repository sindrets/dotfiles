local utils = Config.common.utils

local api = vim.api
local M = { expr = {} }
local expr = M.expr

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

---Create a function that toggles a window with an identifiable buffer of some
---kind. The toggle logic works as follows:
---
--- - Open if
---   - The buffer is not found
---   - No window with the buffer is found
--- - Close if:
---   - The buffer is active in the current window.
--- - Focus if (only if the `focus` option is enabled):
---   - The buffer exists, the window exists, but the window is not active.
---@param buf_finder function A function that should return the buffer id of
---       the wanted buffer if it exists, otherwise nil.
---@param cb_open function Callback when the window should open.
---@param cb_close function Callback when the window should close.
---@param opts BufTogglerOpts|nil
---@return function
function M.create_buf_toggler(buf_finder, cb_open, cb_close, opts)
  opts = opts or {}
  local toggler_entry = BufToggleEntry.new({ height = opts.height })

  local function open()
    toggler_entry.last_winid = api.nvim_get_current_win()
    local ok, err = pcall(cb_open)
    if ok then
      if toggler_entry.height then
        vim.cmd("res " .. toggler_entry.height)
      end
    else
      utils.err("[BufToggler] Open callback failed: " .. err)
    end
  end

  local function close()
    if opts.remember_height then
      toggler_entry.height = api.nvim_win_get_height(0)
    end
    local ok, err = pcall(cb_close)
    if not ok then
      utils.err("[BufToggler] Close callback failed: " .. err)
    end
    if api.nvim_win_is_valid(toggler_entry.last_winid or -1) then
      api.nvim_set_current_win(toggler_entry.last_winid)
    else
      vim.cmd("wincmd p")
    end
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
        toggler_entry.last_winid = api.nvim_get_current_win()
        api.nvim_set_current_win(win_ids[1])
      else
        close()
      end
    end
  end
end

function M.execute_macro_over_visual_range()
  print("@" .. vim.fn.getcmdline())
  vim.fn.execute(":'<,'>normal @" .. vim.fn.nr2char(vim.fn.getchar()))
end

function M.read_new(exprression)
  vim.cmd("enew | set ft=log")
  vim.fn.execute("r! " .. exprression)
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
    return ""
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
    require'telescope.builtin'.find_files({
      hidden = true,
      find_command = { "fd", "--type", "f", "-uu" }
    })
  elseif #vim.fn.glob("./.git") > 0 then
    vim.cmd("Telescope git_files")
  else
    require'telescope.builtin'.find_files({ hidden = true })
  end
end

---Delete a buffer while also preserving the window layout. Changes the current
---buffer to the alt buffer if available, and then deletes it.
---@param force boolean Ignore unsaved changes.
---@param bufid integer
function M.remove_buffer(force, bufid)
  bufid = bufid or api.nvim_get_current_buf()
  if not force then
    local modified = vim.bo[bufid].modified
    if modified then
      utils.err("No write since last change!")
      return
    end
  end

  local alt_bufid = vim.fn.bufnr("#")
  if alt_bufid ~= -1 then
    api.nvim_set_current_buf(alt_bufid)
  else
    local listed = utils.list_listed_bufs()
    if #listed > (vim.bo[0].buflisted and 1 or 0) then
      vim.cmd("silent! bp")
    else
      vim.cmd("enew")
    end
  end

  if api.nvim_buf_is_valid(bufid) then
    api.nvim_buf_delete(bufid, { force = true })
  end
end

function M.split_on_pattern(pattern)
  local epattern = pattern:gsub("/", "\\/")
  vim.cmd(string.format(
    "s/%s/%s\\r/g",
    epattern, epattern
  ))
  vim.cmd("noh")
end

function M.get_indent_level()
  local lnum = api.nvim_win_get_cursor(0)[1]
  if lnum == 0 then return 0 end

  local indent = vim.fn.cindent(lnum)
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

  local indent = M.get_indent_level()
  local et = vim.bo.et
  local sw = vim.bo.sw
  local ts = vim.bo.ts

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
    if indent <= col then
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
  stack = vim.tbl_map(function (v)
    return vim.fn.synIDattr(v, "name")
  end, stack)
  return stack
end

function M.print_syn_group()
  local id = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)
  print("synstack:", vim.inspect(M.name_syn_stack()))
  print(vim.fn.synIDattr(id, "name") .. " -> " .. vim.fn.synIDattr(vim.fn.synIDtrans(id), "name"))
end

function M.mkdp_open_in_new_window(url)
  vim.fn.system(string.format("$BROWSER --new-window %s", url))
end

function M.new_scratch_buf()
  local bufid = api.nvim_create_buf(true, true)
  local name = "Scratch " .. scratch_counter
  scratch_counter = scratch_counter + 1
  api.nvim_buf_set_name(bufid, name)
  api.nvim_win_set_buf(0, bufid)

  return bufid
end

---Close the current window and bring focus to the last used window.
function M.comfy_quit()
  local cur_win = api.nvim_get_current_win()
  local prev_win = vim.fn.win_getid(vim.fn.winnr("#"))
  local ok, err = pcall(vim.cmd, "silent q")

  if not ok then
    utils.err(err)
  elseif cur_win ~= prev_win then
    api.nvim_set_current_win(prev_win)
  end
end

function M.comfy_grep(...)
  local args = {...}
  local cargs = vim.tbl_map(function(arg)
    return vim.fn.shellescape(arg):gsub("[|]", { ["'"] = "''", ["|"] = "\\|" })
  end, args)

  local ok, err = pcall(vim.api.nvim_exec, "grep! " .. table.concat(cargs, " "), true)
  if not ok then
    utils.err(err)
    return
  end

  vim.fn.setreg("/", M.regex_to_pattern(args[1]))
  vim.opt.hlsearch = true
  vim.cmd("belowright cope")
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
  return  "\\v" .. exp
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
  if #vim.lsp.buf_get_clients(0) > 0 then
    return utils.t(string.format(
      '<Cmd>lua require("illuminate").next_reference({ reverse = %s, wrap = true })<CR>',
      tostring(reverse)
    ))
  else
    return expr.comfy_star(reverse, 1)
  end
end

---Open a help page in the current window.
function M.cmd_help_here(subject)
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
function M.cmd_man_here(a, b)
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
    vim.bo.tagfunc = "man#goto_tag"
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
function M.cmd_exec_selection(range)
  local ft = vim.bo.ft == "lua" and "lua" or "vim"
  local lines
  if type(range) == "table" and range[1] ~= range[2] then
    table.sort(range)
    lines = api.nvim_buf_get_lines(0, range[1] - 1, range[2], false)
  else
    lines = M.get_visual_selection()
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

--#region TYPES

---@class BufTogglerOpts
---@field focus boolean Focus the window if it exists and is unfocused.
---@field height integer
---@field remember_height boolean Remember the height of the window when it was
---       closed, and restore it the next time its opened.

--#endregion

M.BufToggleEntry = BufToggleEntry
return M
