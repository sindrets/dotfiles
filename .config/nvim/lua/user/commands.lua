--[[
-- All commands documented in `:h sindrets-commands`.
--]]

local utils = Config.common.utils
local api = vim.api
local command = api.nvim_create_user_command

local function get_range(e)
  return { e.range, e.line1, e.line2 }
end

command("Spectre", require("spectre").open, { bar = true })
command("SpectreFile", require("spectre").open_file_search, { bar = true })

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
end, { nargs = "*", range = true })

command("Rnew", function(e)
  Config.lib.cmd.read_new(unpack(e.fargs))
end, { nargs = "+", complete = "shellcmd" })

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
