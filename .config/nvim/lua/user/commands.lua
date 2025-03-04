--[[
-- All commands documented in `:h sindrets-commands`.
--]]

local async = require("user.async")
local lazy = require("diffview.lazy")

local Job = lazy.access("diffview.job", "Job") ---@type diffview.Job|LazyModule
local arg_parser = lazy.require("diffview.arg_parser") ---@module "diffview.arg_parser"

local await = async.await
local fmt = string.format
local utils = Config.common.utils
local notify = Config.common.notify
local api = vim.api
local command = api.nvim_create_user_command
local inspect = vim.inspect

local function get_range(c)
  return { c.range, c.line1, c.line2 }
end

local function expand_shell_arg(arg)
  local exp = vim.fn.expand(arg) --[[@as string ]]

  if exp ~= "" and exp ~= arg then
    return utils.str_quote(exp, { only_if_whitespace = true, prefer_single = true })
  end
end

command("Messages", function()
  Config.fn.update_messages_win()
end, { bar = true })

command("Grep", function(c)
  Config.lib.comfy_grep(false, unpack(c.fargs))
end, { nargs = "+", complete = "file" })

command("Lgrep", function(c)
  Config.lib.comfy_grep(true, unpack(c.fargs))
end, { nargs = "+", complete = "file" })

command("Terminal", "exe '<mods> sp' | exe 'term <args>'", { nargs = "*", complete = "shellcmd" })

command("TermTab", "tab sp | exe 'term' | startinsert", { bar = true })

command("Job", function(c)
  local stdout, stderr, code
  local raw_cmd = c.args
  local cmd = raw_cmd:gsub("'", "''")
  local silent = (c.smods.silent and 1 or 0) + (c.smods.emsg_silent and 1 or 0)

  ---@diagnostic disable-next-line: unused-local
  local function cb(job_id, data, event_name)
    if event_name == "stdout" then stdout = data
    elseif event_name == "stderr" then stderr = data
    elseif event_name == "exit" then
      code = data
      local notify_fn, msg, notify_opt

      if code ~= 0 then
        if silent < 2 then
          notify_fn = notify.shell.error
          notify_opt = { title = "Job exited with a non-zero status!" }
          msg = table.concat({
            "cmd: ${cmd}",
            "code: ${code}",
            "stderr: ${stderr}",
          }, "\n")
        end
      else
        if silent < 1 then
          notify_fn = notify.shell.info
          notify_opt = { title = "Job exited normally" }
          msg = table.concat({
            "cmd: ${cmd}",
            "stdout: ${stdout}",
          }, "\n")
        end
      end

      if notify_fn and msg then
        notify_fn(utils.str_template(msg, {
          cmd = raw_cmd,
          code = code,
          stderr = vim.trim(table.concat(stderr, "\n")),
          stdout = vim.trim(table.concat(stdout, "\n"))
        }), notify_opt)
      end
    end
  end

  vim.fn.jobstart(cmd, {
    on_exit = cb,
    on_stdout = cb,
    on_stderr = cb,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end, { nargs = "*", complete = "shellcmd" })

command("HelpHere", function(c)
  Config.lib.cmd.help_here(c.args)
end, { bar = true, nargs = 1, complete = "help" })

command("ManHere", function(c)
  Config.lib.cmd.man_here(unpack(c.fargs))
end, { bar = true, nargs = 1, complete = require("man").man_complete })

command("Scratch", function(c)
  Config.lib.new_scratch_buf(c.fargs[1])
end, { bar = true, nargs = "?", complete = "filetype" })

command("SplitOn", function(c)
  Config.lib.split_on_pattern(c.args, get_range(c), c.bang)
end, { bar = true, range = true, bang = true, nargs = "?" })

command("BufRemove", function(c)
  Config.lib.remove_buffer(c.bang, tonumber(c.fargs[1]))
end, { bar = true, bang = true })

command("ReadEx", function(c)
  Config.lib.read_ex(get_range(c), unpack(c.fargs))
end, { nargs = "*", range = true, complete = "command" })

command("Rnew", function(c)
  Config.lib.cmd.read_new(unpack(c.fargs))
end, {
  nargs = "+",
  complete = function(arg_lead, cmd_line, cur_pos)
    local ctx = arg_parser.scan(cmd_line, { allow_quoted = false, cur_pos = cur_pos })

    if #ctx.args > 1 then
      local prefix = ctx.args[2]:sub(1, 1)

      if ctx.argidx == 2 then
        arg_lead = ctx.args[2]:sub(2)
      end

      if prefix == ":" then
        return vim.tbl_map(function(v)
          return ctx.argidx == 2 and prefix .. v or v
        end, vim.fn.getcompletion(arg_lead, "command"))
      elseif prefix == "!" then
        return utils.vec_join(
          expand_shell_arg(arg_lead),
          vim.tbl_map(function(v)
            return ctx.argidx == 2 and prefix .. v or v
          end, vim.fn.getcompletion(arg_lead, "shellcmd"))
        )
      end
    end
  end,
})

command("DiffSaved", Config.lib.diff_saved, { bar = true })

command("HiShow", function()
  Config.lib.cmd.read_new(":hi")
  local bufnr = api.nvim_get_current_buf()
  api.nvim_buf_set_name(bufnr, vim.fn.tempname() .. "/Highlights")
  vim.opt_local.bt = "nofile"
  utils.set_cursor(0, 1, 0)
  vim.cmd("ColorizerAttachToBuffer")
end, { bar = true })

command("ExecuteSelection", function(c)
  Config.lib.cmd.exec_selection(get_range(c), c.fargs[1])
end, { bar = true, range = true, nargs = "?", complete = "shellcmd" })

command("CompareDir", function(c)
  vim.cmd("tabnew")
  vim.t.paths = c.fargs
  vim.t.compare_mode = true

  vim.t.compare_a = api.nvim_get_current_win()
  vim.cmd("belowright vsp")
  vim.t.compare_b = api.nvim_get_current_win()

  vim.cmd("silent 1windo lcd " .. vim.fn.fnameescape(c.fargs[1]))
  vim.cmd("silent 2windo lcd " .. vim.fn.fnameescape(c.fargs[2]))

  for _, winid in ipairs({ vim.t.compare_a, vim.t.compare_b }) do
    api.nvim_win_call(winid, function()
      vim.cmd("edit " .. uv.cwd())
    end)
  end
end, { bar = true, nargs = "+", complete = "dir" })

command("MdViewEdit", function(c)
  Config.lib.cmd.md_view(false, c.fargs[1])
end, { bar = true, nargs = "?", complete = "file" })

command("MdViewNew", function()
  Config.lib.cmd.md_view(true)
end, { bar = true })

command("Windows", function(c)
  Config.lib.cmd.windows(c.bang)
end, { bar = true, bang = true })

command("NeorgExport", async.new(function(c)
  for _, dep in ipairs({ "neorg-pandoc-linux86", "pandoc", "neorg-export" }) do
    if vim.fn.executable(dep) ~= 1 then
      notify.error(("'%s' is not executable!"):format(dep))
      return
    end
  end

  local in_name, out_name

  if #c.fargs > 1 then
    in_name = vim.fn.expand(c.fargs[1])
    out_name = vim.fn.expand(c.fargs[2])
  elseif #c.fargs == 1 then
    in_name = vim.fn.expand("%:p")
    out_name = vim.fn.expand(c.fargs[1])
  else
    in_name = vim.fn.expand("%:p")
    out_name = in_name:sub(1, -math.max(#pl:extension(in_name), 1) - 2) .. ".pdf"
  end

  local job = Job({
    command = "neorg-export",
    args = { in_name, out_name },
  })

  local ok = await(job)

  if not ok then
    notify.error(job.stderr, {
      title = "Document export failed with exit code " .. job.code
    })
  else
    notify.info(
      fmt("Document exported to %s", utils.str_quote(pl:relative(out_name, ".")))
    )
  end
end), { nargs = "*", complete = "file" })

command("Profile", function(c)
  local profile = require("plenary.profile")
  local ctx = arg_parser.scan(c.args, { allow_quoted = false })
  local subcmd = ctx.args[1]

  if not subcmd then
    utils.err("No sub command given!")
    return
  end

  if subcmd == "start" then
    local out_file = c.args[2] or "/tmp/nvim-profile"
    ---@diagnostic disable-next-line: param-type-mismatch
    profile.start(out_file, { flame = true })
  elseif subcmd == "stop" then
    profile.stop()
  end
end, {
  nargs = "+",
  complete = function(arg_lead, cmd_line, cur_pos)
    local ctx = arg_parser.scan(cmd_line, { allow_quoted = false, cur_pos = cur_pos })

    local candidates = {}

    if ctx.argidx == 2 then
      candidates = { "start", "stop" }
    elseif ctx.argidx == 3 then
      candidates = vim.fn.getcompletion(arg_lead, "file")
    end

    return arg_parser.process_candidates(candidates, ctx)
  end,
})

command("UnloadMod", function(c)
  print(c.fargs[1])
  for mod, _ in pairs(package.loaded) do
    if mod:match("^" .. c.fargs[1] .. ".*") then
      print(mod)
      package.loaded[mod] = nil
    end
  end
end, { nargs = "+", bar = true })

command("CloseFloats", function (c)
  local force = c.bang
  local pattern = c.fargs[1] or ".*"

  for _, id in ipairs(api.nvim_list_wins()) do
    if not utils.win_is_float(id) then goto continue end

    local bufnr = api.nvim_win_get_buf(id)
    if api.nvim_buf_get_name(bufnr):match(pattern) then
      api.nvim_win_close(id, force)
    end

    ::continue::
  end
end, { nargs = "?", bar = true, bang = true })

command("ReadMode", function ()
  if not vim.b.read_mode then
    vim.b.read_mode = true
    vim.opt_local.list = false
    vim.opt_local.nu = false
    vim.opt_local.rnu = false
    vim.opt_local.colorcolumn = ""
  else
    vim.b.read_mode = nil
    vim.opt_local.list = nil
    vim.opt_local.nu = nil
    vim.opt_local.rnu = nil
    vim.opt_local.colorcolumn = nil
  end
end, { bang = true })

command("SetIndent", function(c)
  local new_size = assert(
    tonumber(c.fargs[1]),
    fmt("IllegalArgument :: Expected number, got %s!", inspect(c.fargs[1]))
  )

  vim.opt_local.sw = new_size
  vim.opt_local.ts = new_size
  vim.opt_local.sts = new_size
end, { bar = true, nargs = 1 })

command("Reindent", function(c)
  local new_size = assert(
    tonumber(c.fargs[1]),
    fmt("IllegalArgument :: Expected number, got %s!", inspect(c.fargs[1]))
  )
  ---@diagnostic disable-next-line: param-type-mismatch
  local cur_size = vim.opt_local.sw:get()

  local range = utils.vec_sort({ c.line1, c.line2 })
  local save_et = vim.opt_local.et:get()

  vim.opt_local.ts = cur_size
  vim.opt_local.sts = cur_size

  vim.opt_local.et = false
  vim.cmd(fmt("%d,%d retab!", range[1], range[2]))

  vim.opt_local.et = save_et
  vim.opt_local.sw = new_size
  vim.opt_local.ts = new_size
  vim.opt_local.sts = new_size
  vim.cmd(fmt("%d,%d retab!", range[1], range[2]))
end, { bar = true, nargs = 1, range = "%" })

command("Browse", function(c)
  vim.ui.open(c.fargs[1])
end, { nargs = 1, bar = true })

command("Nodiff", "windo set nodiff noscrollbind nocursorbind", { bar = true })

command("Pager", function()
  local cur_buf = api.nvim_get_current_buf()
  local term_buf = api.nvim_create_buf(false, true)
  api.nvim_win_set_buf(0, term_buf)
  local chan = api.nvim_open_term(term_buf, {})
  api.nvim_chan_send(chan, table.concat(api.nvim_buf_get_lines(cur_buf, 0, -1, false), "\n"))
  api.nvim_buf_delete(cur_buf, { force = true })
end, {})

command("FilterQf", function(c)
  Config.lib.filter_qf(c.bang, c.fargs[1])
end, { nargs = "?", bang = true })

command("ThemeToggle", function()
  Config.colorscheme.toggle_theme()
end, { bar = true })
