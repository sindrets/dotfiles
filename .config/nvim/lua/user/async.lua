---@diagnostic disable: duplicate-doc-alias, duplicate-doc-field, duplicate-set-field
local ffi = require("user.ffi")
local oop = require("user.oop")

local fmt = string.format
local uv = vim.loop

local DEFAULT_ERROR = "Unkown error."

local M = {}

---@package
---@type table<Future, boolean>
M._watching = setmetatable({}, { __mode = "k" })

---@package
---@type table<thread, Future>
M._handles = {}

---@alias AsyncFunc (fun(...): Future)
---@alias AsyncKind "normal"|"callback"

---@param ... any
---@return table
local function tbl_pack(...)
  return { n = select("#", ...), ... }
end

---@param t table
---@param i? integer
---@param j? integer
---@return any ...
local function tbl_unpack(t, i, j)
  return unpack(t, i or 1, j or t.n or table.maxn(t))
end

local function dstring(object)
  local tp = type(object)

  if tp == "thread"
    or tp == "function"
    or tp == "userdata"
  then
    return fmt("<%s %p>", tp, object)
  elseif tp == "table" then
    local mt = getmetatable(object)

    if mt and mt.__tostring then
      return tostring(object)
    elseif vim.islist(object) then
      if #object == 0 then return "[]" end
      local s = ""

      for i = 1, table.maxn(object) do
        if i > 1 then s = s .. ", " end
        s = s .. dstring(object[i])
      end

      return "[ " .. s .. " ]"
    end

    return vim.inspect(object)
  end

  return tostring(object)
end

local function dprint(...)
  if not Config.state.DEBUG then return end

  local args = { ... }
  local s = ""

  for i = 1, select("#", ...) do
    if i > 1 then s = s .. " " end
    s = s .. dstring(args[i])
  end

  print(s)
end

---Returns the current thread or `nil` if it's the main thread.
---
---NOTE: coroutine.running() was changed between Lua 5.1 and 5.2:
---  • 5.1: Returns the running coroutine, or `nil` when called by the main
---  thread.
---  • 5.2: Returns the running coroutine plus a boolean, true when the running
---  coroutine is the main one.
---
---For LuaJIT, 5.2 behaviour is enabled with `LUAJIT_ENABLE_LUA52COMPAT`
---
---We need to handle both.
---
---Source: https://github.com/lewis6991/async.nvim/blob/bad4edbb2917324cd11662dc0209ce53f6c8bc23/lua/async.lua#L10
---@return thread?
function M.current_thread()
  local current, ismain = coroutine.running()

  if type(ismain) == "boolean" then
    return not ismain and current or nil
  else
    return current
  end
end

M.WAIT_TIMED_OUT = oop.Symbol("async.WAIT_TIMED_OUT")

---@class Waitable : user.Object
local Waitable = oop.create_class("Waitable")
M.Waitable = Waitable

---@abstract
---@return Future
function Waitable:await()
  ---@diagnostic disable-next-line: missing-return
  oop.abstract_stub()
end

---Schedule a callback to be invoked when this waitable has settled.
---@param callback function
function Waitable:finally(callback)
  (M.new(function()
    callback(M.await(self))
  end))()
end

---@class Future.CancelState
---@field reason Symbol

---@class Future : user.Object
---@operator call : Future
---@field package thread thread
---@field package listeners Future[]
---@field package parent? Future
---@field package func? function
---@field package return_values? any[]
---@field package err? string
---@field package kind AsyncKind
---@field package cancelled? Future.CancelState
---@field package started boolean
---@field package waiting boolean
---@field package awaiting_cb boolean
---@field package done boolean
---@field package has_raised boolean # `true` if this future has raised an error.
local Future = oop.create_class("Future")

function Future:init(opt)
  opt = opt or {}

  if opt.thread then
    self.thread = opt.thread
  elseif opt.func then
    self.thread = coroutine.create(opt.func)
  else
    error("Either 'thread' or 'func' must be specified!")
  end

  M._handles[self.thread] = self
  self.listeners = {}
  self.kind = opt.kind
  self.started = false
  self.waiting = false
  self.awaiting_cb = false
  self.done = false
  self.has_raised = false
end

---@package
---@return string
function Future:__tostring()
  return dstring(self.thread)
end

---@package
function Future:destroy()
  M._handles[self.thread] = nil
end

---@package
---@param value boolean
function Future:set_done(value)
  self.done = value
  if self:is_watching() then
    self:dprint("done was set:", self.done)
  end
end

---@return boolean
function Future:is_done()
  return not not self.done
end

---@return boolean
function Future:is_cancelled()
  return not not self.cancelled
end

---@return boolean
function Future:is_waiting()
  return not not self.waiting
end

---If the future has completed, this returns any returned values. If it was
---cancelled, it'll return the cancel reason.
---@return any ...
function Future:get_returned()
  if not self.return_values then
    if self.cancelled then return self.cancelled.reason end
    return
  end

  return unpack(self.return_values, 2, table.maxn(self.return_values))
end

---@package
---@param ... any
function Future:dprint(...)
  if not (Config.state.DEBUG or M._watching[self]) then return end

  local args = { fmt("%.2f", uv.hrtime() / 1000000), self, "::", ... }
  local t = {}

  for i = 1, table.maxn(args) do
    t[i] = dstring(args[i])
  end

  dprint(table.concat(t, " "))
end

---@package
---@param ... any
function Future:dprintf(...)
  self:dprint(fmt(...))
end

---Start logging debug info about this future.
function Future:watch()
  M._watching[self] = true
end

---Stop logging debug info about this future.
function Future:unwatch()
  M._watching[self] = nil
end

---@package
---@return boolean
function Future:is_watching()
  return not not M._watching[self]
end

---Raise the error caught from the Future's thread.
---@package
---@param force? boolean # Re-raise the error even if it's been raised before.
function Future:raise(force)
  if self.has_raised and not force then return end
  self.has_raised = true
  error(self.err)
end

---Yield the Future's thread. Can only be called from said thread. If the
---yielding is cancelled, the method will return the cancel reason.
---@package
---@return Symbol? status
function Future:yield_self()
  assert(M.current_thread() == self.thread, "Attempted to yield an unrelated thread!")

  local cancel_reason = coroutine.yield()

  -- Ensure that we're only returning values that we recognize
  if cancel_reason == M.WAIT_TIMED_OUT then
    if self.awaiting_cb then
      -- Disregard, keep yielding. The thread is not doing anything until the
      -- callback is called regardless.
      return self:yield_self()
    end

    return cancel_reason
  end
end

---Yield the parent thread. Can only be called from said thread. If the
---yielding is cancelled, the method will return the cancel reason.
---@package
---@return Symbol? status
function Future:yield_parent()
  assert(self.parent, "Attempted to yield an orphan Future!")
  assert(M.current_thread() == self.parent.thread, "Attempted to yield an unknown thread!")

  local cancel_reason = coroutine.yield()

  -- Ensure that we're only returning values that we recognize
  if cancel_reason == M.WAIT_TIMED_OUT then
    return cancel_reason
  end
end

---Cancel the wait for this future. This will *not* cancel the execution of the
---thread.
---@package
---@param reason Symbol
function Future:cancel(reason)
  if not self.started or self:is_done() then return end

  self.cancelled = { reason = reason }

  if not self:is_waiting()
    or not self.parent
    or coroutine.status(self.parent.thread) ~= "suspended"
  then
    -- Nothing to do
    return
  end

  self.parent:step(reason)
end

---Progress the execution of the thread. Each step ends when one of the
---following things happen:
---   • The thread yields.
---   • The thread dies.
---   • An error is raised.
---@package
function Future:step(...)
  self:dprint("step")
  local ret = { coroutine.resume(self.thread, ...) }
  local ok = ret[1]

  if not ok then
    local err = ret[2] or DEFAULT_ERROR
    local func_info

    if self.func then
      func_info = debug.getinfo(self.func, "uS")
    end

    local msg = fmt(
      "The coroutine failed with this message: \n"
        .. "\tcontext: cur_thread=%s co_thread=%s %s\n%s",
      dstring(M.current_thread() or "main"),
      dstring(self.thread),
      func_info and fmt("co_func=%s:%d", func_info.short_src, func_info.linedefined) or "",
      debug.traceback(self.thread, err)
    )
    self:set_done(true)
    self:notify_all(false, msg)
    self:destroy()
    self:raise()
    return
  end

  if coroutine.status(self.thread) == "dead" then
    self:dprint("handle dead")
    self:set_done(true)
    self:notify_all(true, unpack(ret, 2, table.maxn(ret)))
    self:destroy()
    return
  end
end

---Wake all the threads that are waiting for this thread.
---@package
---@param ok boolean
---@param ... any
function Future:notify_all(ok, ...)
  local ret_values = tbl_pack(ok, ...)

  if not ok then
    self.err = ret_values[2] or DEFAULT_ERROR
  end

  local seen = {}

  while next(self.listeners) do
    local handle = table.remove(self.listeners, #self.listeners) --[[@as Future ]]

    -- We don't want to trigger multiple steps for a single thread
    if handle and not seen[handle.thread] then
      self:dprint("notifying:", handle)
      seen[handle.thread] = true
      handle:step(ret_values)
    end
  end
end

---Block the parent thread until this Future has settled.
---@return any ... # Return values
function Future:sync()
  if self.err then
    self:raise(true)
    return
  end

  if self:is_done() or self:is_cancelled() then
    return self:get_returned()
  end

  local current = M.current_thread()

  if not current then
    -- Await called from main thread
    return self:toplevel_sync()
  end

  local parent_handle = M._handles[current]

  if not parent_handle then
    -- We're on a thread not managed by us: create a Future wrap around the
    -- thread
    self:dprint("creating a wrapper around unmanaged thread")
    self.parent = Future({
      thread = current,
      kind = "normal",
    })
  else
    self.parent = parent_handle
  end

  if current ~= self.thread then
    -- We want the current thread to be notified when this future is done /
    -- terminated
    table.insert(self.listeners, self.parent)
  end

  self:dprintf("awaiting: yielding=%s listeners=%s", dstring(current), dstring(self.listeners))
  self.waiting = true
  local cancel_reason = self:yield_parent()

  local ok

  if not self.return_values then
    ok = self.err == nil
  else
    ok = self.return_values[1]

    if not ok then
      self.err = self.return_values[2] or DEFAULT_ERROR
    end
  end

  self.waiting = false

  if cancel_reason then
    return cancel_reason
  end

  if not ok then
    self:raise(true)
    return
  end

  return self:get_returned()
end

---Block the main thread until this Future has settled.
---@package
---@return any ...
function Future:toplevel_sync()
  local ok, status
  self.waiting = true

  while true do
    ok, status = vim.wait(1000 * 60, function()
      return coroutine.status(self.thread) == "dead" or self:is_cancelled()
    end, 1)

    -- Respect interrupts
    if status ~= -1 then break end
    if self:is_cancelled() then break end
  end

  if not ok then
    if status == -1 then
      error("Async task timed out!")
    elseif status == -2 then
      error("Async task got interrupted!")
    end
  end

  self.waiting = false

  if self.err then
    self:raise(true)
    return
  end

  return self:get_returned()
end

---Schedule a callback to be invoked when this Future has settled.
---@param callback function
function Future:finally(callback)
  (M.new(function()
    callback(M.await(self))
  end))()
end

---@class async._run.Opt
---@field kind AsyncKind
---@field nparams? integer
---@field args any[]

---Prepare and begin the execution of an async function.
---@package
---@param func function
---@param opt async._run.Opt
function M._run(func, opt)
  opt = opt or {}

  local handle ---@type Future
  local use_err_handler = not not M.current_thread()

  local function wrapped_func(...)
    local ret

    if use_err_handler then
      -- We are not on the main thread: use custom err handler
      ret = {
        xpcall(func, function(err)
          handle.err = debug.traceback(err, 2)
        end, ...)
      }

      local ok = ret[1]

      if not ok then
        handle:dprint("an error was raised: terminating")
        handle:set_done(true)
        handle:destroy()
        error(handle.err, 0)
        return
      end
    else
      ret = { true, func(...) }
    end

    -- Check if we need to yield until cb. We might not need to if the cb was
    -- called in a synchronous way.
    if opt.kind == "callback" and not handle:is_done() then
      handle.awaiting_cb = true
      handle:dprintf("yielding for cb: current=%s", dstring(M.current_thread()))
      handle:yield_self()
      handle:dprintf("resuming after cb: current=%s", dstring(M.current_thread()))
    elseif opt.kind == "normal" then
      handle.return_values = ret
    end

    handle:set_done(true)
  end

  if opt.kind == "callback" then
    local cur_cb = opt.args[opt.nparams]

    local function wrapped_cb(...)
      handle:set_done(true)
      handle.return_values = { true, ... }
      if cur_cb then cur_cb(...) end

      if handle.awaiting_cb then
        -- The thread was yielding for the callback: resume
        handle.awaiting_cb = false
        handle:step()
      end

      handle:notify_all(true, ...)
    end

    opt.args[opt.nparams] = wrapped_cb
  end

  handle = Future({ func = wrapped_func, kind = opt.kind })
  handle:dprint("created thread")
  handle.func = func
  handle.started = true
  handle:step(tbl_unpack(opt.args))

  return handle
end

---Create a new async function.
---
---@param func function
---@return AsyncFunc
function M.new(func)
  return function(...)
    return M._run(func, {
      kind = "normal",
      args = { ... },
    })
  end
end

---Create a new async function for a callback style function. Calling the
---resulting function will create a Future that is only settled after the
---callback is invoked. Any arguments applied to the callback are used as
---return values for the Future.
---
---@param func function
---@param nparams? integer # The number of parameters.
---The last parameter in `func` must be the callback. For Lua functions this
---can be derived through reflection. However, if `func` is an FFI procedure
---then `nparams` is required.
---@return AsyncFunc
function M.wrap(func, nparams)
  if not nparams then
    local info = debug.getinfo(func, "uS")
    assert(info.what == "Lua", "Parameter count can only be derived for Lua functions!")
    nparams = info.nparams
  end

  return function(...)
    return M._run(func, {
      nparams = nparams,
      kind = "callback",
      args = { ... },
    })
  end
end

---Block the current thread until either the given async task completes, or the
---given `timeout` ms has passed.
---
---@param x Future|Waitable
---@param timeout? integer # Wait a maximum of `timeout` ms. If no timeout is given: wait indefinitely.
---@return any? result # Either the first returned value from `x`, or `async.WAIT_TIMED_OUT` if the wait timed out.
---@return any ... # Any subsequent values returned from `x`.
function M.await(x, timeout)
  if timeout and timeout <= 0 then
    return M.WAIT_TIMED_OUT
  end

  ---@type Future
  local future

  if x.class:name() ~= "Future" then
    ---@cast x Waitable
    future = x:await()
  else
    ---@cast x Future
    future = x
  end

  if timeout then
    local timer = assert(uv.new_timer())

    timer:start(timeout, 0, function()
      if not timer:is_closing() then timer:close() end
      future:cancel(M.WAIT_TIMED_OUT)
    end)
  end

  return future:sync()
end

---Await the async function `x` with the given arguments in protected mode. `x`
---may also be a Waitable, in which case the subsequent parameters are ignored.
---
---@param timeout? integer # Wait a maximum of `timeout` ms. If no timeout is given: wait indefinitely.
---@param x AsyncFunc|Future|Waitable # The async function or Waitable.
---@param ... any # Arguments to be applied to `x` if it's a function.
---@return boolean ok # `false` if the execution of `x` failed.
---@return any result # Either the first returned value from `x`, an error message, or `async.WAIT_TIMED_OUT` if the wait timed out.
---@return any ... # Any subsequent values returned from `x`.
function M.pawait(timeout, x, ...)
  local args = tbl_pack(...)
  return pcall(function()
    if type(x) == "function" then
      return M.await(x(tbl_unpack(args)), timeout)
    else
      return M.await(x, timeout)
    end
  end)
end

-- ###############################
-- ### VARIOUS ASYNC UTILITIES ###
-- ###############################

local await = M.await

---Create a synchronous version of an async task. Calling the resulting
---function will block the current thread until the async task is done.
---
---@param func function
function M.sync_new(func)
  local afunc = M.new(func)

  return function(...)
    return await(afunc(...))
  end
end

---Create a synchronous version of an async `wrap` task. Calling the resulting
---function will block the current thread until the async task is done. Any
---values that were passed to the callback will be returned.
---
---@param func function
---@param nparams? integer
---@return (fun(...): ...)
function M.sync_wrap(func, nparams)
  local afunc = M.wrap(func, nparams)

  return function(...)
    return await(afunc(...))
  end
end

---Run the given async tasks concurrently, and then wait for them all to
---terminate.
---
---@param tasks (AsyncFunc|Future|Waitable)[]
M.join = M.new(function(tasks)
  ---@type (Future|Waitable)[]
  local futures = {}

  -- Ensure all async tasks are started
  for _, cur in ipairs(tasks) do
    if cur then
      if type(cur) == "function" then
        futures[#futures+1] = cur()
      else
        ---@cast cur Waitable
        futures[#futures+1] = cur
      end
    end
  end

  -- Await all futures
  for _, future in ipairs(futures) do
    await(future)
  end
end)

---Run, and await the given async tasks in sequence.
---
---@param tasks (AsyncFunc|Future|Waitable)[]
M.chain = M.new(function(tasks)
  for _, task in ipairs(tasks) do
    if type(task) == "function" then
      ---@cast task AsyncFunc
      await(task())
    else
      await(task)
    end
  end
end)

---Async task that resolves after the given `timeout` ms passes.
---
---@param timeout integer # Duration of the timeout (ms)
M.timeout = M.wrap(function(timeout, callback)
  local timer = assert(uv.new_timer())

  timer:start(
    timeout,
    0,
    function()
      if not timer:is_closing() then timer:close() end
      callback()
    end
  )
end)

---Yield until the Neovim API is available.
---
---@param fast_only? boolean # Only schedule if in an |api-fast| event.
---   When this is `true`, the scheduler will resume immediately unless the
---   editor is in an |api-fast| event. This means that the API might still be
---   limited by other mechanisms (i.e. |textlock|).
M.scheduler = M.wrap(function(fast_only, callback)
  if (fast_only and not vim.in_fast_event()) or not ffi.nvim_is_locked() then
    callback()
    return
  end

  vim.schedule(callback)
end)

M.schedule_now = M.wrap(vim.schedule, 1)

return M
