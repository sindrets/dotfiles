local Cache = require("user.modules.cache")
local StatusItem = require("user.modules.winbar.status_item")

local utils = Config.common.utils
local pl = Config.common.utils.pl
local au = Config.common.au
local api = vim.api

local HOME_DIR = uv.os_homedir()

local M = {}

M.config = {
  symbols = {
    path_separator = "",
    folder = "",
    repo = "",
    ellipsis = "…",
  },
  ignore = function(ctx)
    if vim.tbl_contains({
      "DiffviewFiles",
      "DiffviewFileHistory",
    }, ctx.filetype) then
      return true
    end
  end,
}

M.cache = Cache()
M.SEP_ITEM = StatusItem(" " .. M.config.symbols.path_separator .. " ", "Comment")
M.ELLIPSIS_ITEM = StatusItem(M.config.symbols.ellipsis, "Comment")

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

---@class StatusLineItem
---@field [1] string # Content
---@field [2] string? # Highlight group name

function M.generate()
  local winid = api.nvim_get_current_win()
  local bufnr = api.nvim_win_get_buf(winid)
  local bufname = vim.fn.bufname(bufnr)

  local cached = M.cache:get(winid)

  if cached then
    -- Cache hit: no need to regenerate
    return cached
  end

  if M.config.ignore({
    winid = winid,
    bufnr = bufnr,
    filetype = vim.bo[bufnr].filetype,
    buftype = vim.bo[bufnr].buftype,
    bufname = bufname,
  }) then
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

  local win_width = api.nvim_win_get_width(winid)
  local cwd = vim.fn.getcwd(winid)
  local abs_path = pl:absolute(api.nvim_buf_get_name(bufnr), cwd)
  local path = no_empty(condense_path(abs_path))
  local path_exists = not (path and pl:is_uri(path))
      and pl:readable((path and pl:parent(abs_path)) or ".")

  local basename, parent_path

  if not path_exists then
    local condese_bufname = condense_path(bufname)
    basename = no_empty(pl:basename(condese_bufname))
    parent_path = pl:parent(condese_bufname)
  elseif path then
    basename = no_empty(pl:basename(path))
    parent_path = pl:parent(path)
  end

  ---@type user.winbar.StatusItem[]
  local path_segments = {}
  local show_repo

  if path_exists and (not path or vim.startswith(abs_path, cwd)) then
    show_repo = true
    winbar:add_child(StatusItem({
      StatusItem(M.config.symbols.repo .. " ", "Directory"),
      StatusItem(pl:basename(condense_path(cwd, true)), "WinBar"),
    }))
  end

  if parent_path then
    for _, part in ipairs(pl:explode(parent_path)) do
      table.insert(path_segments, StatusItem(part, "Comment"))
    end
  end

  if basename then
    local comp = StatusItem({})

    if vim.bo[bufnr].modified then
      comp:add_child(StatusItem("[+] ", "String"))
    end

    comp:add_child(StatusItem(basename, "WinBar"))
    table.insert(path_segments, comp)
  end

  path_segments = truncate_path_segments(path_segments, win_width, show_repo)
  append(unpack(path_segments))

  local ret = winbar:render()
  M.cache:put(winid, ret)

  return ret
end

local update_queued = false
local queued = {}

function M.request_update(winid)
  table.insert(queued, winid)

  if update_queued then return end

  vim.schedule(function()
    for _, id in ipairs(queued) do
      M.cache:invalidate(id)
    end

    vim.cmd.redrawstatus()

    queued = {}
    update_queued = false
  end)
end

au.declare_group("user.winbar", {}, {
  {
    { "WinEnter", "WinLeave", "BufWinEnter", "BufModifiedSet" },
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

return M
