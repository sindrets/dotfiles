--- @namespace user.modules.llm_chat
--- @using user.modules.term
--- @using pebbles

local lz = require("user.lazy")

local TermSplit = lz.require("user.modules.term.TermSplit") ---@module "user.modules.term.TermSplit"
local Terminal = lz.require("user.modules.term.Terminal") ---@module "user.modules.term.Terminal"
local Path = lz.require("imminent.fs.Path") ---@module "imminent.fs.Path"

local CMD = { "pi" }

--- @class LLMChat.State
--- @field term_split TermSplit
--- @field terminal Terminal

--- @class LLMChat
--- @field state? LLMChat.State
local llmchat = {}

--- @private
function llmchat.get_state()
  if llmchat.state and llmchat.state.terminal:is_alive() then return llmchat.state end

  llmchat.state = {
    term_split = TermSplit.new({
      position = "right",
      initial_width = 88,
    }),
    terminal = Terminal.new({
      cmd = CMD,
      name = "llmchat",
    }),
  }

  local term_split, term = llmchat.state.term_split, llmchat.state.terminal
  term:spawn()
  term_split:set_buf(term.bufnr)

  return llmchat.state
end

--- @param focus? boolean
function llmchat.open(focus)
  local state = llmchat.get_state()
  local term_split = state.term_split

  if term_split:is_open(0) then return end

  term_split:open(focus)
end

function llmchat.close()
  local state = llmchat.get_state()
  local term_split = state.term_split

  if not term_split:is_open(0) then return end
  term_split:close()
end

--- @param opts? TerminalSplit.toggle.Opts
function llmchat.toggle(opts)
  local state = llmchat.get_state()
  state.term_split:toggle(opts)
end

function llmchat.setup()
  local function cur_path_pretty()
    local cur_path = Path.from(Path.vim_expand("%")):absolute()

    if cur_path:starts_with(Path.cwd()) then
      -- make the path relative if it's a descendant of the cwd
      return Path.join(".", cur_path:relative()):unwrap():fold_home()
    end

    return cur_path:fold_home()
  end

  vim.keymap.set(
    { "n", "t" },
    "<M-c>",
    function() llmchat.toggle({ focus = true }) end,
    { desc = "Toggle LLM chat" }
  )

  vim.keymap.set({ "n" }, "<leader>ap", function()
    llmchat.open(false)
    local term = llmchat.get_state().terminal
    local cur_path = cur_path_pretty()

    term:send({ cur_path:tostring() .. " " }, { auto_cr = false })
  end, { desc = "Send current file path to LLM chat" })

  vim.keymap.set("v", "<leader>ap", function()
    llmchat.open(false)
    local term = llmchat.get_state().terminal
    local cur_path = cur_path_pretty()

    local region = vim.fn.getregionpos(
      vim.fn.getpos("v"),
      vim.fn.getpos("."),
      { type = "v", exclusive = false, eol = false }
    )
    local start_line = region[1][1][2]
    local end_line = region[#region][1][2]
    local range_str = start_line == end_line and
      tostring(start_line) or
      string.format("%d-%d", start_line, end_line)

    term:send(
      { string.format("%s:%s ", cur_path:tostring(), range_str) },
      { auto_cr = false }
    )

    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
  end, { desc = "Send selected lines to LLM chat" })
end

return llmchat
