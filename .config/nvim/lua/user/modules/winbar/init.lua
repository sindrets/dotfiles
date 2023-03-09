local Cache = require("user.modules.cache")
local StatusItem = require("user.modules.winbar.status_item")

local utils = Config.common.utils
local pl = Config.common.utils.pl
local au = Config.common.au
local api = vim.api
local fmt = string.format

local HOME_DIR = uv.os_homedir()
local WINBAR_STRING = "%{%v:lua.require'user.modules.winbar'.generate()%}"

local M = {}

M.config = {
  symbols = {
    path_separator = "",
    folder = "",
    repo = "",
    ellipsis = "…",
    readonly = "",
  },
  ---@param ctx WindowContext
  ignore = function(ctx)
    if ctx.bufname == "" then
      return true
    end

    local cur_bar = api.nvim_get_option_value("winbar", { scope = "local", win = ctx.winid })
    if cur_bar ~= "" and cur_bar ~= WINBAR_STRING then
      -- Something else has set the winbar here: don't attach
      return true
    end

    if ctx.float then
      if ctx.filetype == "lir" then return false end
      return true
    end

    if vim.tbl_contains({
      "quickfix",
    }, ctx.buftype) then
      return true
    end

    if vim.tbl_contains({
      "DiffviewFiles",
      "DiffviewFileHistory",
    }, ctx.filetype) then
      return true
    end
  end,
}

M.state = {
  attached = {},
  cache = Cache(),
}

local symbols = M.config.symbols

M.SEP_ITEM = StatusItem(fmt(" %s ", symbols.path_separator), "Comment")
M.ELLIPSIS_ITEM = StatusItem(symbols.ellipsis, "Comment")

---@return string?
local function no_empty(s)
  if s == "" then return nil end
  return s
end

local function condense_path(path, no_relative)
  local scheme, p = "", path

  if pl:is_uri(path) then
    scheme, p = path:match("^(%w+://)(.*)")
  end

  if not no_relative then
    p = pl:relative(p, ".")
  end

  if p == "" then
    if scheme ~= "" then p = "." end
  elseif vim.startswith(p, HOME_DIR) then
    p = pl:join("~", pl:relative(p, HOME_DIR))
  end

  return scheme .. p
end

---@param segments user.winbar.StatusItem[]
---@param max_width integer
---@param show_repo boolean
local function truncate_path_segments(segments, max_width, show_repo)
  local sep_width = #M.SEP_ITEM:get_content()
  local ellipsis_width = #M.ELLIPSIS_ITEM:get_content()
  local total_width = 0

  local widths = vim.tbl_map(function(v)
    local w = #v:get_content() + sep_width
    total_width = total_width + w
    return w
  end, segments)

  if total_width <= max_width then
    -- No truncation needed
    return segments
  end

  local ret = {}
  total_width = ellipsis_width

  if not show_repo then
    table.insert(ret, segments[1])
    total_width = total_width + widths[1]
  end

  table.insert(ret, M.ELLIPSIS_ITEM)
  local slice_start = not show_repo and 2 or 1

  for i = #widths, slice_start, -1 do
    total_width = total_width + widths[i]

    if total_width >= max_width then
      slice_start = math.min(i + 1, #segments)
      break
    end
  end

  return utils.vec_join(ret, utils.vec_slice(segments, slice_start))
end

---@class WindowContext
---@field winid integer
---@field bufnr integer
---@field tabid integer
---@field bufname string
---@field filetype string
---@field buftype string
---@field cwd string
---@field win_config table
---@field float boolean
---@field width integer
---@field height integer

---@param winid integer
---@return WindowContext
function M.win_context(winid)
  if winid == 0 then winid = api.nvim_get_current_win() end
  local bufnr = api.nvim_win_get_buf(winid)
  local tabid = api.nvim_win_get_tabpage(winid)
  local tabnr = api.nvim_tabpage_get_number(tabid)
  local win_config = api.nvim_win_get_config(winid)

  return {
    winid = winid,
    bufnr = bufnr,
    tabid = tabid,
    bufname = vim.fn.bufname(bufnr),
    filetype = vim.bo[bufnr].filetype,
    buftype = vim.bo[bufnr].buftype,
    cwd = vim.fn.getcwd(winid, tabnr),
    win_config = win_config,
    float = win_config.relative ~= "",
    width = api.nvim_win_get_width(winid),
    height = api.nvim_win_get_height(winid),
  }
end

function M.generate()
  local winid = api.nvim_get_current_win()
  local cached = M.state.cache:get(winid)

  if cached then
    -- Cache hit: no need to regenerate
    return cached
  end

  local win_ctx = M.win_context(winid)

  if M.config.ignore(win_ctx) then
    return ""
  end

  local winbar = StatusItem({})

  winbar:add_child(StatusItem(" "))

  local function append(...)
    local children = winbar:get_children()

    for _, item in ipairs({ ... }) do
      if #children > 1 then
        winbar:add_child(M.SEP_ITEM)
      end

      winbar:add_child(item)
    end
  end

  local abs_path = pl:absolute(api.nvim_buf_get_name(win_ctx.bufnr), win_ctx.cwd)
  local path = no_empty(condense_path(abs_path))
  local path_exists = win_ctx.bufname ~= ""
      and not (path and pl:is_uri(path))
      and pl:readable(abs_path)

  local basename, parent_path

  if not path_exists then
    local condese_bufname = condense_path(win_ctx.bufname)
    basename = no_empty(pl:basename(condese_bufname))
    parent_path = pl:parent(condese_bufname)
  elseif path then
    basename = no_empty(pl:basename(path))
    parent_path = pl:parent(path)
  end

  ---@type user.winbar.StatusItem[]
  local path_segments = {}
  local show_repo

  if path_exists and win_ctx.bufname ~= ""
    and (not path or vim.startswith(abs_path, win_ctx.cwd))
  then
    show_repo = true
    winbar:add_child(StatusItem({
      StatusItem(M.config.symbols.repo .. " ", "Directory"),
      StatusItem(pl:basename(condense_path(win_ctx.cwd, true)), "WinBar"),
    }))
  end

  if parent_path then
    for _, part in ipairs(pl:explode(parent_path)) do
      table.insert(path_segments, StatusItem(part, "Comment"))
    end
  end

  if basename then
    local comp = StatusItem({})

    if vim.bo[win_ctx.bufnr].modified then
      comp:add_child(StatusItem("[+] ", "String"))
    end

    if not vim.bo[win_ctx.bufnr].modifiable or vim.bo[win_ctx.bufnr].readonly then
      comp:add_child(StatusItem(fmt("%s ", symbols.readonly), "DiagnosticInfo"))
    end

    comp:add_child(StatusItem(basename, "WinBar"))
    table.insert(path_segments, comp)
  end

  path_segments = truncate_path_segments(path_segments, win_ctx.width, show_repo)
  append(unpack(path_segments))

  local ret = winbar:render()
  M.state.cache:put(winid, ret)

  return ret
end

local update_queued = false
local queued = {}

function M.update(winid)
  M.state.cache:invalidate(winid)

  if vim.api.nvim_win_is_valid(winid) then
    M.check_attach(winid)
  end
end

---Debounce multiple updates to the same windows until the next time the editor
---is ready to redraw.
---@param winid integer
function M.request_update(winid)
  if queued[winid] == nil then
    -- This window has not been queued before: update immediately
    M.update(winid)
    queued[winid] = false
  else
    queued[winid] = true
  end

  if update_queued then return end
  update_queued = true

  vim.schedule(function()
    if next(queued) then
      for id, do_update in pairs(queued) do
        if do_update then M.update(id) end
      end

      queued = {}
    end

    -- vim.cmd.redrawstatus()
    update_queued = false
  end)
end

function M.attach(winid)
  local state = M.state.attached[winid]

  if not state then
    state = {
      prev_bar = no_empty(api.nvim_get_option_value("winbar", {
        scope = "local",
        win = winid,
      })),
    }
    M.state.attached[winid] = state
  end

  if vim.wo[winid].winbar ~= WINBAR_STRING then
    api.nvim_win_set_option(winid, "winbar", WINBAR_STRING)
  end
end

function M.detach(winid)
  local state = M.state.attached[winid]
  if not state then return end

  if vim.wo[winid].winbar == WINBAR_STRING then
    api.nvim_win_set_option(winid, "winbar", state.prev_bar or nil)
  end

  M.state.attached[winid] = nil
end

function M.check_attach(winid)
  local win_ctx = M.win_context(winid)

  if M.config.ignore(win_ctx) then
    M.detach(winid)
  else
    M.attach(winid)
  end
end

function M.is_attached(winid)
  return M.state.attached[winid] ~= nil
end

function M.init()
  au.declare_group("user.winbar", {}, {
    {
      { "WinEnter", "WinLeave", "BufWinEnter", "BufModifiedSet", "BufWritePost" },
      callback = function(ctx)
        local win_match, buf_match

        if ctx.event:match("^Win") then
          if vim.tbl_contains({ "WinLeave", "WinEnter" }, ctx.event) then
            buf_match = ctx.buf
          else
            win_match = tonumber(ctx.match)
          end
        elseif ctx.event:match("^Buf") then
          buf_match = ctx.buf
        end

        if win_match then
          M.request_update(win_match)
        end

        if buf_match then
          for _, winid in ipairs(api.nvim_list_wins()) do
            if api.nvim_win_get_buf(winid) == buf_match then
              M.request_update(winid)
            end
          end
        end
      end,
    },
  })
end

return M
