local utils = require'nvim-config.utils'
local api = vim.api

local M = {}

local last_sourced_config = nil
local last_sourced_session = nil

---@class BufToggleEntry
---@field last_winid integer
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
  local toggler_entry = BufToggleEntry:new({ height = opts.height })

  local function open()
    toggler_entry.last_winid = api.nvim_get_current_win()
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
    if toggler_entry.last_winid then
      api.nvim_set_current_win(toggler_entry.last_winid)
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
  vim.cmd("diffthis")
  vim.cmd("vnew | r # | normal! 1Gdd")
  vim.cmd("diffthis")
  vim.cmd("setlocal bt=nofile bh=wipe nobl noswf ro ft=" .. filetype)
end

function M.workspace_files(opt)
  if opt == "-a" then
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

function M.close_buffer_and_go_to_alt(bufid)
  local modified = api.nvim_buf_get_option(bufid or 0, "modified")
  if modified then
    utils.err("No write since last change!")
    return
  end

  local cur_bufid = bufid or vim.api.nvim_get_current_buf()
  local alt_bufid = vim.fn.bufnr("#")
  if alt_bufid ~= -1 then
    api.nvim_set_current_buf(alt_bufid)
  else
    vim.cmd("silent! bp")
  end

  api.nvim_buf_delete(cur_bufid, {})
end

function M.source_project_config()
  if utils.file_readable(".vim/init.vim") then
    local project_config_path = vim.loop.fs_realpath(".vim/init.vim")
    if last_sourced_config ~= project_config_path then
      vim.cmd("source .vim/init.vim")
      last_sourced_config = project_config_path
      utils.info("Sourced project config: " .. project_config_path)
    end
  end
end

function M.source_project_session()
  if #vim.v.argv == 1 and utils.file_readable(".vim/Session.vim") then
    local project_config_path = vim.loop.fs_realpath(".vim/Session.vim")
    if last_sourced_session ~= project_config_path then
      vim.cmd("source .vim/Session.vim")
      last_sourced_session = project_config_path
      utils.info("Sourced project config: " .. project_config_path)
    end
  end
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
  local et = api.nvim_buf_get_option(0, "et")
  local sw = api.nvim_buf_get_option(0, "sw")
  local ts = api.nvim_buf_get_option(0, "ts")

  if et then
    if indent == 0 then
      indent = sw > 0 and sw or 4
    end
    if indent <= col then
      api.nvim_feedkeys(tab_char, "n", false)
      return
    end

    vim.cmd("normal! d0x")
    api.nvim_feedkeys(utils.str_repeat(" ", indent), "n", false)
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
      utils.str_repeat(tab_char, ntabs) .. utils.str_repeat(" ", nspaces),
      "n", false
    )
  end
end

function M.mkdp_open_in_new_window(url)
  vim.cmd("call system('$BROWSER --new-window " .. url .. "')")
end

--[[
TYPES
--]]

---@class BufTogglerOpts
---@field focus boolean Focus the window if it exists and is unfocused.
---@field height integer
---@field remember_height boolean Remember the height of the window when it was
---       closed, and restore it the next time its opened.

--[[
TYPES END
--]]

M.BufToggleEntry = BufToggleEntry
return M
