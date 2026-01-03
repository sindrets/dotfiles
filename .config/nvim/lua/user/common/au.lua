local api = vim.api

local M = {}

--- @class AutocmdCallbackContext
--- @field id integer Aucmd ID.
--- @field event string
--- @field group integer?
--- @field match string Expanded value of `<amatch>`
--- @field buf integer Expanded value of `<abuf>`.
--- @field file string Expand value of `<afile>`.
--- @field data table

--- @class AucmdSpec
--- @field [1] (Config.common.au.VimEvent|string)|(Config.common.au.VimEvent|string)[]
--- @field group? string|integer
--- @field pattern? string|string[]
--- @field buffer? integer
--- @field desc? string
--- @field callback fun(ctx: AutocmdCallbackContext)
--- @field command? string
--- @field once? boolean
--- @field nested? boolean

--- Declare an autocommand group.
--- @param name string
--- @param opts? { clear?: boolean } Augroup options.
--- @param aucmds AucmdSpec[]
--- @return integer group_id
function M.declare_group(name, opts, aucmds)
  local id = api.nvim_create_augroup(name, opts or { clear = true })

  for _, aucmd in ipairs(aucmds) do
    local auopts = vim.tbl_extend("force", aucmd, { group = id }) --[[@as table ]]
    auopts[1] = nil
    api.nvim_create_autocmd(aucmd[1], auopts)
  end

  return id
end

return M

--- @alias Config.common.au.VimEvent
---   | "BufAdd"
---   | "BufDelete"
---   | "BufEnter"
---   | "BufFilePost"
---   | "BufFilePre"
---   | "BufHidden"
---   | "BufLeave"
---   | "BufModifiedSet"
---   | "BufNew"
---   | "BufNewFile"
---   | "BufRead"
---   | "BufReadCmd"
---   | "BufReadPre"
---   | "BufUnload"
---   | "BufWinEnter"
---   | "BufWinLeave"
---   | "BufWipeout"
---   | "BufWrite"
---   | "BufWriteCmd"
---   | "BufWritePost"
---   | "ChanInfo"
---   | "ChanOpen"
---   | "CmdUndefined"
---   | "CmdlineChanged"
---   | "CmdlineEnter"
---   | "CmdlineLeave"
---   | "CmdwinEnter"
---   | "CmdwinLeave"
---   | "ColorScheme"
---   | "ColorSchemePre"
---   | "CompleteChanged"
---   | "CompleteDonePre"
---   | "CompleteDone"
---   | "CursorHold"
---   | "CursorHoldI"
---   | "CursorMoved"
---   | "CursorMovedI"
---   | "DiffUpdated"
---   | "DirChanged"
---   | "DirChangedPre"
---   | "ExitPre"
---   | "FileAppendCmd"
---   | "FileAppendPost"
---   | "FileAppendPre"
---   | "FileChangedRO"
---   | "FileChangedShell"
---   | "FileChangedShellPost"
---   | "FileReadCmd"
---   | "FileReadPost"
---   | "FileReadPre"
---   | "FileType"
---   | "FileWriteCmd"
---   | "FileWritePost"
---   | "FileWritePre"
---   | "FilterReadPost"
---   | "FilterReadPre"
---   | "FilterWritePost"
---   | "FilterWritePre"
---   | "FocusGained"
---   | "FocusLost"
---   | "FuncUndefined"
---   | "UIEnter"
---   | "UILeave"
---   | "InsertChange"
---   | "InsertCharPre"
---   | "InsertEnter"
---   | "InsertLeavePre"
---   | "InsertLeave"
---   | "MenuPopup"
---   | "ModeChanged"
---   | "OptionSet"
---   | "QuickFixCmdPre"
---   | "QuickFixCmdPost"
---   | "QuitPre"
---   | "RemoteReply"
---   | "SearchWrapped"
---   | "RecordingEnter"
---   | "RecordingLeave"
---   | "SafeState"
---   | "SessionLoadPost"
---   | "SessionWritePost"
---   | "ShellCmdPost"
---   | "Signal"
---   | "ShellFilterPost"
---   | "SourcePre"
---   | "SourcePost"
---   | "SourceCmd"
---   | "SpellFileMissing"
---   | "StdinReadPost"
---   | "StdinReadPre"
---   | "SwapExists"
---   | "Syntax"
---   | "TabEnter"
---   | "TabLeave"
---   | "TabNew"
---   | "TabNewEntered"
---   | "TabClosed"
---   | "TermOpen"
---   | "TermEnter"
---   | "TermLeave"
---   | "TermClose"
---   | "TermRequest"
---   | "TermResponse"
---   | "TextChanged"
---   | "TextChangedI"
---   | "TextChangedP"
---   | "TextChangedT"
---   | "TextYankPost"
---   | "User"
---   | "UserGettingBored"
---   | "VimEnter"
---   | "VimLeave"
---   | "VimLeavePre"
---   | "VimResized"
---   | "VimResume"
---   | "VimSuspend"
---   | "WinClosed"
---   | "WinEnter"
---   | "WinLeave"
---   | "WinNew"
---   | "WinScrolled"
---   | "WinResized"
