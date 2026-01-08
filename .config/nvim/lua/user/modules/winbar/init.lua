local Cache = require("user.modules.cache")
local StatusItem = require("user.modules.winbar.status_item")
local lz = require("user.lazy")

local Path = lz.require("imminent.fs.Path") ---@module "imminent.fs.Path"

local utils = Config.common.utils
local pb = Config.common.pb
local au = Config.common.au
local api = vim.api
local fmt = string.format
local strwidth = vim.api.nvim_strwidth

local HOME_DIR = assert(uv.os_homedir())
local WINBAR_STRING = "%{%v:lua.require'user.modules.winbar'.generate()%}"

local M = {}

M.config = {
  symbols = {
    path_separator = "",
    folder = "",
    repo = "",
    ellipsis = "…",
    readonly = "",
    link = "",
    compare = "",
  },
  ---@param ctx WindowContext
  ignore = function(ctx)
    -- ignore floating Snacks windows
    if ctx.float and vim.w[ctx.winid].snacks_win then return true end

    if ctx.bufname == "" then
      if vim.wo[ctx.winid].diff then return false end
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
  cache = Cache.new(),
}

local symbols = M.config.symbols

M.SEP_ITEM = StatusItem(fmt(" %s ", symbols.path_separator), "Comment")
M.ELLIPSIS_ITEM = StatusItem(symbols.ellipsis, "Comment")

---@return string?
local function no_empty(s)
  if s == "" then return nil end
  return s
end

--- @param pathlike string|imminent.fs.Path
--- @param cwd? imminent.fs.Path
--- @param no_relative? boolean
--- @return imminent.fs.Path?
local function condense_path(pathlike, cwd, no_relative)
  local scheme = nil
  local path

  if type(pathlike) == "string" then
    local r_path = Path.from_str(pathlike)
    if r_path:is_err() then return nil end
    path = r_path:unwrap()
  else
    path = pathlike:clone()
  end

  local uri_is_pathlike = false

  if path:is_uri() then
    scheme = assert(path.uri_scheme)
    path:set_uri_scheme(nil):unwrap()
    uri_is_pathlike = path:is_absolute()
  end

  if not no_relative then
    if not scheme or uri_is_pathlike then
      path = path:relative(cwd)
      local abs = path:absolute(cwd)

      if #path:explode() >= #abs:explode() then
        path = abs
      end
    end
  end

  if pb.startswith(path:tostring(), HOME_DIR) then
    path = Path.concat("~", path:diff(Path.from(HOME_DIR))):unwrap():normalize()
  end

  path:set_uri_scheme(scheme):unwrap()

  return path
end

local SEP_ITEM_WIDTH = strwidth(M.SEP_ITEM:get_content())
local ELLIPSIS_ITEM_WIDTH = strwidth(M.ELLIPSIS_ITEM:get_content())

---@param segments user.winbar.StatusItem[]
---@param max_width integer
---@param show_repo boolean
local function truncate_path(segments, max_width, show_repo)
  local total_width = 0
  max_width = max_width - SEP_ITEM_WIDTH

  local widths = vim.tbl_map(function(v)
    local w = strwidth(v:get_content()) + SEP_ITEM_WIDTH
    total_width = total_width + w
    return w
  end, segments)

  if total_width <= max_width then
    -- No truncation needed
    return segments
  end

  local ret = {}
  total_width = ELLIPSIS_ITEM_WIDTH

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

local function truncate_path_segment(name)
  if strwidth(name) <= 47 then return name end
  -- Get the correct byte indices such that we don't accidentally end up
  -- dismembering a multi-byte glyph.
  local end_head = vim.str_byteindex(name, 23)
  local start_tail = vim.str_byteindex(name, #name - 22)
  return name:sub(1, end_head) .. symbols.ellipsis .. name:sub(start_tail)
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
  local winbar = StatusItem({ StatusItem(" ") })

  local function append(...)
    local children = winbar:get_children()

    for _, item in ipairs({ ... }) do
      if #children > 1 then
        winbar:add_child(M.SEP_ITEM)
      end

      winbar:add_child(item)
    end
  end

  local win_cwd = Path.from(win_ctx.cwd)
  local abs_path = Path
    .from_str(vim.fn.bufname(win_ctx.bufnr))
    :map(function(p) return p:absolute(win_cwd) end)
    :unwrap_or(win_cwd)
  local path = condense_path(abs_path, win_cwd)
  local is_uri = path and path:is_uri()
  local path_exists = win_ctx.bufname ~= "" and not is_uri and abs_path:is_readable():block_on()

  local basename, parent_path

  if not path_exists then
    local dense_bufname = condense_path(win_ctx.bufname, win_cwd)
    if dense_bufname then
      basename = no_empty(dense_bufname:basename())
      parent_path = dense_bufname:parent():unwrap_or(nil)
    end
  elseif path then
    basename = no_empty(path:basename())
    parent_path = path:parent():unwrap_or(nil)
  end

  ---@type user.winbar.StatusItem[]
  local path_segments = {}
  local show_repo = false

  -- Repo / cwd

  if (not path or pb.startswith(abs_path:tostring(), win_ctx.cwd)) then
    show_repo = true
    local dense_cwd = assert(condense_path(win_cwd, win_cwd, true))

    winbar:add_child(StatusItem({
      StatusItem(M.config.symbols.repo .. " ", "Directory"),
      StatusItem(truncate_path_segment(dense_cwd:basename()), "WinBar"),
    }))
  end

  -- Parent path

  if parent_path then
    for _, part in ipairs(parent_path:explode()) do
      table.insert(path_segments, StatusItem(truncate_path_segment(part), "Comment"))
    end
  end

  -- Basename

  if not basename and not win_ctx.filetype == "lir" then
    basename = "[No Name]"
  end

  if basename then
    local comp = StatusItem({})

    if vim.bo[win_ctx.bufnr].modified then
      -- Modified
      comp:add_child(StatusItem("[+] ", "String"))
    end

    if not vim.bo[win_ctx.bufnr].modifiable or vim.bo[win_ctx.bufnr].readonly then
      -- Read only
      comp:add_child(StatusItem(fmt("%s ", symbols.readonly), "DiagnosticInfo"))
    end

    if vim.wo[win_ctx.winid].diff then
      -- Diff mode
      comp:add_child(StatusItem(fmt("%s ", symbols.compare), "DiagnosticInfo"))
    end

    comp:add_child(StatusItem(truncate_path_segment(basename), "WinBar"))
    table.insert(path_segments, comp)
  end

  path_segments = truncate_path(
    path_segments,
    win_ctx.width - strwidth(winbar:get_content()),
    show_repo
  )
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

--- Debounce multiple updates to the same windows until the next time the
--- editor is ready to redraw.
---
--- @param winid integer
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

--- Request an update for all windows.
---
function M.request_update_all()
  for _, winid in ipairs(api.nvim_list_wins()) do
    M.request_update(winid)
  end
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
    api.nvim_set_option_value("winbar", WINBAR_STRING, { scope = "local", win = winid })
  end
end

function M.detach(winid)
  local state = M.state.attached[winid]
  if not state then return end

  if vim.wo[winid].winbar == WINBAR_STRING then
    api.nvim_set_option_value("winbar", state.prev_bar or nil, { scope = "local", win = winid })
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

function M.check_all()
  for _, winid in ipairs(api.nvim_list_wins()) do
    M.check_attach(winid)
  end
end

function M.is_attached(winid)
  return M.state.attached[winid] ~= nil
end

function M.init()
  local events = {
    "WinEnter",
    "WinLeave",
    "BufWinEnter",
    "BufModifiedSet",
    "BufWritePost",
    "DirChanged",
    "FocusGained",
  }

  if vim.fn.has("nvim-0.9") == 1 then
    table.insert(events, "WinResized")
  end

  au.declare_group("user.winbar", {}, {
    {
      events,
      callback = function(ctx)
        local win_match, buf_match

        if ctx.event:match("^Win") then
          if vim.tbl_contains({ "WinLeave", "WinEnter" }, ctx.event) then
            buf_match = ctx.buf
            win_match = api.nvim_get_current_win()
          else
            win_match = tonumber(ctx.match)
          end
        elseif ctx.event:match("^Buf") then
          buf_match = ctx.buf
        end

        if win_match then
          M.request_update(win_match)
        elseif buf_match then
          for _, winid in ipairs(api.nvim_list_wins()) do
            if api.nvim_win_get_buf(winid) == buf_match then
              M.request_update(winid)
            end
          end
        else
          M.request_update_all()
        end
      end,
    },
  })

  M.check_all()
end

return M
