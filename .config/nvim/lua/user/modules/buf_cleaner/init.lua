-- Automatically delete listed buffers that have been untouched for X minutes.

--- @namespace user.modules.buf_cleaner
--- @using imminent
--- @using pebbles

local time = require("imminent.time")

local api = vim.api
local fmt = string.format
local notify = Config.common.notify

local M = {}

M.CLEANUP_INTERVAL = time.Duration.from_mins(1)
M.TTL = time.Duration.from_mins(15)

--- @private
M._interval_handle = nil --[[@as time.Closeable? ]]
--- @private
M._setup_done = false

--- @private
--- @type { [int]: BufState? }
M.state_map = {}

--- @class BufState
--- @field changetick int
--- @field timestamp time.Instant

--- @param bufnr int
--- @param opt? Partial<BufState>
--- @return BufState
local function new_buf_state(bufnr, opt)
  opt = opt or {}

  return {
    changetick = opt.changetick or api.nvim_buf_get_changedtick(bufnr),
    timestamp = opt.timestamp or time.now()
  }
end

---@param bufnr int
---@param now time.Instant
---@param buf_state BufState
---@param win_buf_map table<int, int?>
local function should_delete(bufnr, now, buf_state, win_buf_map)
  -- Check if expired
  if now:duration_since(buf_state.timestamp) < M.TTL then return false end

  -- Don't delete buffers that are displayed in a window
  if win_buf_map[bufnr] then return false end

  -- Don't delete buffers if they're modified
  if vim.bo[bufnr].modified then return false end

  -- Don't delete non-standard buffers if they're modifiable.
  if vim.bo[bufnr].bt ~= "" and vim.bo[bufnr].modifiable then return false end

  return true
end

function M.is_running() return not not M._interval_handle end

function M.run()
  local bufs = vim.tbl_filter(
    function(bufnr) return vim.bo[bufnr].buflisted end,
    api.nvim_list_bufs()
  )

  --- @type table<int, int?>
  local win_buf_map = {}

  for _, winid in ipairs(api.nvim_list_wins()) do
    win_buf_map[api.nvim_win_get_buf(winid)] = winid
  end

  local now = time.now()

  for _, bufnr in ipairs(bufs) do
    local buf_state = M.state_map[bufnr]

    if not buf_state then
      -- This is a new buffer: save its state and continue
      M.state_map[bufnr] = new_buf_state(bufnr, { timestamp = now })
    else
      local changetick = api.nvim_buf_get_changedtick(bufnr)

      if changetick > buf_state.changetick then
        -- changetick has been incremented: update state
        M.state_map[bufnr] = new_buf_state(bufnr, { changetick = changetick, timestamp = now })
      elseif should_delete(bufnr, now, buf_state, win_buf_map) then
        -- Buffer has expired: delete
        local ok, err = pcall(function()
          api.nvim_buf_delete(bufnr, { unload = true })
          vim.bo[bufnr].buflisted = false
        end)

        if not ok and err then
          api.nvim_echo({ { err } }, true, { err = true })
        else
          M.state_map[bufnr] = nil
        end
      end
    end
  end
end

function M.setup()
  if M._setup_done then return end
  M._setup_done = true

  api.nvim_create_augroup("buf_cleaner", { clear = true })
  api.nvim_create_autocmd("BufLeave", {
    group = "buf_cleaner",
    callback = function(e)
      local buf_state = M.state_map[e.buf]
      if buf_state then
        -- Update timestamp on buffers we track
        buf_state.timestamp = buf_state.timestamp:max(time.now() - M.TTL / 2)
      end
    end,
  })
end

---@param silent? boolean
function M.enable(silent)
  if M.is_running() then
    notify.warn("Already running.", { title = "buf_cleaner" })
    return
  end

  M.setup()
  M._interval_handle = time.set_interval(vim.schedule_wrap(M.run), M.CLEANUP_INTERVAL)

  if not silent then notify.info("The buffer cleaner is running.", { title = "buf_cleaner" }) end
end

---@param silent? boolean
function M.disable(silent)
  if M._interval_handle then
    M._interval_handle.close()
    M._interval_handle = nil
  end

  if not silent then
    notify.info("The buffer cleaner has been disabled.", { title = "buf_cleaner" })
  end
end

api.nvim_create_user_command("BufCleaner", function(ctx)
  local arg_parser = require("diffview.arg_parser")
  --- @diagnostic disable-next-line: missing-fields, param-type-mismatch
  local argo = arg_parser.scan(ctx.args, {})
  local subcmd = argo.args[1]

  if subcmd then
    if subcmd == "enable" or subcmd == "on" then
      M.enable()
    elseif subcmd == "disable" or subcmd == "off" then
      M.disable()
    elseif subcmd == "toggle" then
      if M.is_running() then
        M.disable()
      else
        M.enable()
      end
    elseif subcmd == "status" then
      notify.info(fmt("The buffer cleaner is %srunning.", M.is_running() and "" or "not "))
    elseif subcmd == "run" then
      M.run()
    end
  end
end, {
  nargs = 1,
  complete = function(_, cmd_line, cur_pos)
    local arg_parser = require("diffview.arg_parser")
    --- @diagnostic disable-next-line: missing-fields, param-type-mismatch
    local ctx = arg_parser.scan(cmd_line, { allow_quoted = false, cur_pos = cur_pos })

    local candidates = {}

    if ctx.argidx == 2 then
      candidates = { "on", "off", "enable", "disable", "toggle", "run", "status" }
    end

    return arg_parser.process_candidates(candidates, ctx)
  end,
})

return M
