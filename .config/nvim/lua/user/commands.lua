--[[
-- All commands documented in `:h sindrets-commands`.
--]]

local lazy = require("diffview.lazy")

---@module "diffview.arg_parser"
local arg_parser = lazy.require("diffview.arg_parser")

local utils = Config.common.utils
local api = vim.api
local command = api.nvim_create_user_command

local function get_range(e)
  return { e.range, e.line1, e.line2 }
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

command("Grep", function(e)
  Config.lib.comfy_grep(false, unpack(e.fargs))
end, { nargs = "+" })

command("Lgrep", function(e)
  Config.lib.comfy_grep(true, unpack(e.fargs))
end, { nargs = "+" })

command("Terminal", "exe '<mods>' sp | exe 'term <args>'", { nargs = "*" })

command("TermTab", "tab sp | exe 'term' | startinsert", { bar = true })

command("HelpHere", function(e)
  Config.lib.cmd.help_here(e.args)
end, { bar = true, nargs = 1, complete = "help" })

command("ManHere", function(e)
  Config.lib.cmd.man_here(unpack(e.fargs))
end, { bar = true, nargs = 1, complete = "customlist,man#complete" })

command("Scratch", function(e)
  Config.lib.new_scratch_buf(e.fargs[1])
end, { bar = true, nargs = "?", complete = "filetype" })

command("SplitOn", function(e)
  Config.lib.split_on_pattern(e.args, get_range(e), e.bang)
end, { bar = true, range = true, bang = true, nargs = "?" })

command("BRemove", function(e)
  Config.lib.remove_buffer(e.bang, tonumber(e.fargs[1]))
end, { bar = true, bang = true })

command("ReadEx", function(e)
  Config.lib.read_ex(get_range(e), unpack(e.fargs))
end, { nargs = "*", range = true, complete = "command" })

command("Rnew", function(e)
  Config.lib.cmd.read_new(unpack(e.fargs))
end, {
  nargs = "+",
  complete = function(arg_lead, cmd_line, cur_pos)
    local args, arg_idx = arg_parser.scan_ex_args(cmd_line, cur_pos)

    if #args > 1 then
      local prefix = args[2]:sub(1, 1)

      if arg_idx == 2 then
        arg_lead = args[2]:sub(2)
      end

      if prefix == ":" then
        return vim.tbl_map(function(v)
          return arg_idx == 2 and prefix .. v or v
        end, vim.fn.getcompletion(arg_lead, "command"))
      elseif prefix == "!" then
        return utils.vec_join(
          expand_shell_arg(arg_lead),
          vim.tbl_map(function(v)
            return arg_idx == 2 and prefix .. v or v
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

command("ExecuteSelection", function(e)
  Config.lib.cmd.exec_selection(get_range(e))
end, { bar = true, range = true })

command("CompareDir", function(e)
  vim.cmd("tabnew")
  vim.t.paths = e.fargs
  vim.t.compare_mode = true

  vim.t.compare_a = api.nvim_get_current_win()
  vim.cmd("belowright vsp")
  vim.t.compare_b = api.nvim_get_current_win()

  vim.cmd("silent 1windo lcd " .. vim.fn.fnameescape(e.fargs[1]))
  vim.cmd("silent 2windo lcd " .. vim.fn.fnameescape(e.fargs[2]))

  for _, winid in ipairs({ vim.t.compare_a, vim.t.compare_b }) do
    api.nvim_win_call(winid, function()
      vim.cmd("edit" .. uv.getcwd())
    end)
  end
end, { bar = true, nargs = "+", complete = "dir" })

command("MdViewEdit", function(e)
  Config.lib.cmd.md_view(false, e.fargs[1])
end, { bar = true, nargs = "?", complete = "file" })

command("MdViewNew", function()
  Config.lib.cmd.md_view(true)
end, { bar = true })

command("Windows", function(e)
  Config.lib.cmd.windows(e.bang)
end, { bar = true, bang = true })
