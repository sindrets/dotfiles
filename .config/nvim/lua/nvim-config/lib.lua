local utils = require'nvim-config.utils'
local api = vim.api
local M = {}
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
--- * Open if
---   - The buffer is not found
---   - No window with the buffer is found
--- * Close if:
---   - The buffer is active in the current window.
--- * Focus if (only if the `focus` option is enabled):
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

function M.read_new(expr)
  vim.cmd("enew | set ft=log")
  vim.fn.execute("r! " .. expr)
end

function M.get_visual_selection()
  local pos
  pos = vim.fn.getpos("'<")
  local line_start = pos[2]
  local column_start = pos[3]

  pos = vim.fn.getpos("'>")
  local line_end = pos[2]
  local column_end = pos[3]

  local lines = vim.fn.getline(line_start, line_end)
  if #lines == 0 then
    return ""
  end

  local selection = vim.api.nvim_get_option("selection")
  lines[#lines] = lines[#lines]:sub(1, column_end - (selection == "inclusive" and 0 or 1))
  lines[1] = lines[1]:sub(column_start, -1)

  return vim.fn.join(lines, "\n")
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
  elseif #vim.fn.glob("./.git") ~= 0 then
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
    vim.cmd("silent! bp")
  end

  api.nvim_buf_delete(bufid, { force = true })
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
  local lnum = vim.fn.line(".")
  if lnum == 0 then return 0 end

  local indent = vim.fn.cindent(lnum)
  return indent
end

function M.full_indent()
  local pos = vim.fn.getcurpos()
  local lnum, col = pos[2], pos[3]
  local cur_view = vim.fn.winsaveview()

  vim.cmd("normal! $")
  local last_col = vim.fn.getcurpos()[3]

  vim.cmd("normal! 0")
  local first_nonspace = vim.fn.searchpos("\\S", "nc", lnum)[2]

  vim.fn.winrestview(cur_view)

  local tab_char = "	"
  if first_nonspace > 0 or col < last_col then
    api.nvim_feedkeys(tab_char, "n", false)
    return
  end

  local indent = M.get_indent_level()
  local et = vim.bo[0].et
  local sw = vim.bo[0].sw
  local ts = vim.bo[0].ts

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
  local args = vim.tbl_map(function(arg)
    return vim.fn.shellescape(arg):gsub("[|]", { ["'"] = "''", ["|"] = "\\|" })
  end, {...})

  local ok, err = pcall(vim.api.nvim_exec, "grep! " .. table.concat(args, " "), true)
  if not ok then
    utils.err(err)
    return
  end

  vim.cmd("belowright cope")
end

---[EXPR] Search for the current word without jumping forward. Respects
---`v:count`.
---@param reverse boolean
---@param count integer
---@return string
function M.comfy_star(reverse, count)
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
function M.next_reference(reverse)
  if type(reverse) ~= "boolean" then
    reverse = false
  end
  if #vim.lsp.buf_get_clients(0) > 0 then
    return utils.t(string.format(
      '<Cmd>lua require("illuminate").next_reference({ reverse = %s, wrap = true })<CR>',
      tostring(reverse)
    ))
  else
    return M.comfy_star(reverse, 1)
  end
end

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

function M.update_custom_hl()
  -- FloatBorder
  vim.cmd(string.format(
    "hi! FloatBorder guifg=%s guibg=%s",
    utils.get_fg("FloatBorder") or "white",
    utils.get_bg("NormalFloat") or "NONE"
  ))

  -- Custom diff hl
  local bg = utils.get_bg("DiffDelete", false) or "red"
  local fg = utils.get_fg("DiffDelete", false) or "NONE"
  local gui = utils.get_gui("DiffDelete", false) or "NONE"
  vim.cmd(string.format("hi! DiffAddAsDelete guibg=%s guifg=%s gui=%s", bg, fg, gui))
  vim.cmd("hi! link DiffDelete Comment")
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
