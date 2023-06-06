-- Automatically delete listed buffers that have been untouched for 10 minutes.

local async = require("user.async")

local await = async.await
local api = vim.api
local loop = Config.common.loop

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

function M.enable()
  if M._interval_handle then
    Config.common.notify.warn("Already running.", { title = "buf_cleaner" })
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

  M._interval_handle = loop.set_interval(
    async.void(function()
      await(async.scheduler())

      local bufs = vim.tbl_filter(function(bufnr)
        return vim.bo[bufnr].buflisted
      end, api.nvim_list_bufs()) --[[@as integer[] ]]

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
          else
            -- Check timestamp
            if
              now - buf_state.timestamp > M.EXPIRATION_TIME -- Check if expired
              and not win_buf_map[bufnr] -- Don't delete buffers that are displayed in a window
              and not vim.bo[bufnr].modified -- Don't delete buffers if they're modified
            then
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
      end
    end),
    M.CLEANUP_INTERVAL
  )
end

function M.disable()
  api.nvim_create_augroup("buf_cleaner", { clear = true })

  if M._interval_handle then
    M._interval_handle.close()
    M._interval_handle = nil
  end
end

return M