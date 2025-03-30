-- Automatically delete listed buffers that have been untouched for 10 minutes.

local async = require("imminent")
local time = require("imminent.time")

local Future = async.Future
local api = vim.api
local fmt = string.format
local notify = Config.common.notify

local M = {}

M.CLEANUP_INTERVAL = 1000 * 60
M.EXPIRATION_TIME = 1000 * 60 * 15 -- 15 min

---@private
---@type Closeable?
M._interval_handle = nil

---@private
---@type { [integer]: buf_cleaner.BufState }
M.state_map = {}

local function get_timestamp()
  return uv.hrtime() / 1000000
end

---@class buf_cleaner.BufState
---@field changetick integer
---@field timestamp number

local function new_buf_state(bufnr, opt)
  opt = opt or {}

  return {
    changetick = opt.changetick or api.nvim_buf_get_changedtick(bufnr),
    timestamp = opt.timestamp or get_timestamp(),
  }
end

---@param bufnr integer
---@param now number
---@param buf_state buf_cleaner.BufState
---@param win_buf_map table<integer, integer>
local function should_delete(bufnr, now, buf_state, win_buf_map)
  -- Check if expired
  if now - buf_state.timestamp < M.EXPIRATION_TIME then return false end

  -- Don't delete buffers that are displayed in a window
  if win_buf_map[bufnr] then return false end

  -- Don't delete buffers if they're modified
  if vim.bo[bufnr].modified then return false end

  -- Don't delete non-standard buffers if they're modifiable.
  if vim.bo[bufnr].bt ~= "" and vim.bo[bufnr].modifiable then return false end

  return true
end

function M.is_running()
  return not not M._interval_handle
end

--- @return Fut<nil>
--- @nodiscard
function M.run()
  return Future.from(function()
    async.nvim_locks():await()

    local bufs = vim.tbl_filter(function(bufnr)
      return vim.bo[bufnr].buflisted
    end, api.nvim_list_bufs()) --[[@as integer[] ]]

    ---@type table<integer, integer>
    local win_buf_map = {}

    for _, winid in ipairs(api.nvim_list_wins()) do
      win_buf_map[api.nvim_win_get_buf(winid)] = winid
    end

    local now = uv.hrtime() / 1000000

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
            api.nvim_err_writeln(err)
          else
            M.state_map[bufnr] = nil
          end
        end
      end
    end
  end)
end

---@param silent? boolean
function M.enable(silent)
  if M.is_running() then
    notify.warn("Already running.", { title = "buf_cleaner" })
    return
  end

  api.nvim_create_augroup("buf_cleaner", { clear = true })
  api.nvim_create_autocmd("BufLeave", {
    group = "buf_cleaner",
    callback = function(e)
      local buf_state = M.state_map[e.buf]
      if buf_state then
        -- Update timestamp on buffers we track
        buf_state.timestamp = math.max(
          buf_state.timestamp,
          get_timestamp() - M.EXPIRATION_TIME / 2
        )
      end
    end,
  })

  M._interval_handle = time.set_interval(
    function() async.spawn(M.run()) end,
    M.CLEANUP_INTERVAL
  )

  if not silent then
    notify.info("The buffer cleaner is running.", { title = "buf_cleaner" })
  end
end

---@param silent? boolean
function M.disable(silent)
  api.nvim_create_augroup("buf_cleaner", { clear = true })

  if M._interval_handle then
    M._interval_handle.close()
    M._interval_handle = nil
  end

  if not silent then
    notify.info("The buffer cleaner has been disabled.", { title = "buf_cleaner" })
  end
end

api.nvim_create_user_command(
  "BufCleaner",
  function(ctx)
    local arg_parser = require("diffview.arg_parser")
    local argo = arg_parser.scan(ctx.args, {})
    local subcmd = argo.args[1]

    if subcmd then
      if subcmd == "enable" or subcmd == "on" then
        M.enable()
      elseif subcmd == "disable" or subcmd == "off" then
        M.disable()
      elseif subcmd == "toggle" then
        if M.is_running() then M.disable() else M.enable() end
      elseif subcmd == "status" then
        notify.info(fmt("The buffer cleaner is %srunning.", M.is_running() and "" or "not "))
      end
    end
  end,
  {
    nargs = 1,
    complete = function(_, cmd_line, cur_pos)
      local arg_parser = require("diffview.arg_parser")
      local ctx = arg_parser.scan(cmd_line, { allow_quoted = false, cur_pos = cur_pos })

      local candidates = {}

      if ctx.argidx == 2 then
        candidates = { "on", "off", "enable", "disable", "toggle", "status" }
      end

      return arg_parser.process_candidates(candidates, ctx)
    end,
  }
)

return M
