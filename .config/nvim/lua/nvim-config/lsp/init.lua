USER = vim.fn.expand("$USER")
HOME = vim.fn.expand("$HOME")
PID = vim.fn.getpid()
local cmp_lsp = require("cmp_nvim_lsp")
local lspconfig = require("lspconfig")
local utils = Config.common.utils

local M = {}

local diagnostic_signs = {
  error = "",
  warn = "",
  hint = "",
  info = ""
}

local local_settings

function M.get_local_settings()
  if local_settings then return local_settings end

  if utils.file_readable(".vim/lsp-settings.lua") then
    local code_chunk = loadfile(".vim/lsp-settings.lua")
    if code_chunk then
      local_settings = code_chunk()
    end
  else
    local_settings = {}
  end

  return local_settings
end

---@diagnostic disable-next-line: unused-local
_G.LspCommonOnAttach = function(client, bufnr)
  require("illuminate").on_attach(client)
  require("lsp_signature").on_attach({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
      border = "single",
    },
  }, bufnr)
end

_G.LspGetDefaultConfig = function()
  return vim.tbl_deep_extend("force", {
    on_attach = LspCommonOnAttach,
    capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  }, M.get_local_settings())
end

-- Java
require'nvim-config.lsp.java'

-- Typescript
lspconfig.tsserver.setup(LspGetDefaultConfig())

-- Python
lspconfig.pyright.setup(LspGetDefaultConfig())

-- Lua
require'nvim-config.lsp.lua'

-- Teal
-- require'nvim-config.lsp.teal'

-- Bash
lspconfig.bashls.setup(LspGetDefaultConfig())

-- C#
lspconfig.omnisharp.setup({
    cmd = { "/usr/bin/omnisharp", "--languageserver" , "--hostPID", tostring(PID) },
    filetypes = { "cs", "vb" },
    init_options = {},
    on_attach = LspCommonOnAttach,
    -- root_dir = lspconfig.util.root_pattern(".csproj", ".sln"),
    -- root_dir = vim.fn.getcwd
  })

-- C, C++
require('lspconfig').clangd.setup(LspGetDefaultConfig())

-- Vim
require('lspconfig').vimls.setup(LspGetDefaultConfig())

-- Go
require('lspconfig').gopls.setup(LspGetDefaultConfig())

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    underline = true,
    signs = true,
    update_in_insert = true
  }
)

local pop_opts = { border = "single", max_width = 80 }
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, pop_opts)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, pop_opts
)

function M.define_diagnostic_signs(opts)
  local group = {
    -- version 0.5
    {
      highlight = 'LspDiagnosticsSignError',
      sign = opts.error
    },
    {
      highlight = 'LspDiagnosticsSignWarning',
      sign = opts.warn
    },
    {
      highlight = 'LspDiagnosticsSignHint',
      sign = opts.hint
    },
    {
      highlight = 'LspDiagnosticsSignInformation',
      sign = opts.info
    },
    -- version >=0.6
    {
      highlight = 'DiagnosticSignError',
      sign = opts.error
    },
    {
      highlight = 'DiagnosticSignWarn',
      sign = opts.warn
    },
    {
      highlight = 'DiagnosticSignHint',
      sign = opts.hint
    },
    {
      highlight = 'DiagnosticSignInfo',
      sign = opts.info
    },
  }

  for _, g in ipairs(group) do
    vim.fn.sign_define(
    g.highlight,
    { text = g.sign, texthl = g.highlight, linehl = '', numhl = '' }
    )
  end
end

M.define_diagnostic_signs(diagnostic_signs)

-- Highlight references on cursor hold

function M.highlight_cursor_symbol()
  if vim.lsp.buf.server_ready() then
    if vim.fn.mode() ~= "i" then
      vim.lsp.buf.document_highlight()
    end
  end
end

function M.highlight_cursor_clear()
  if vim.lsp.buf.server_ready() then
    vim.lsp.buf.clear_references()
  end
end
---------------------------------

-- Only show diagnostics if current word + line is not the same as last call.
local last_diagnostics_word = nil
function M.show_position_diagnostics()
  local cword = vim.fn.expand("<cword>")
  local cline = vim.api.nvim_win_get_cursor(0)[1]
  local bufnr = vim.api.nvim_get_current_buf()

  if last_diagnostics_word
    and last_diagnostics_word[1] == cline
    and last_diagnostics_word[2] == cword
    and last_diagnostics_word[3] == bufnr then
    return
  end
  last_diagnostics_word = { cline, cword, bufnr }

  vim.diagnostic.open_float({ scope = "cursor", border = "single" })
end

-- LSP auto commands
vim.api.nvim_exec([[
  augroup init_lsp
    au!
    " au CursorHold   * silent! lua Config.lsp.highlight_cursor_symbol()
    " au CursorHoldI  * silent! lua Config.lsp.highlight_cursor_symbol()
    " au CursorMoved  * silent! lua Config.lsp.highlight_cursor_clear()
    " au CursorMovedI * silent! lua Config.lsp.highlight_cursor_clear()

    au CursorHold * silent! lua Config.lsp.show_position_diagnostics()
    " au ModeChanged *:[vVsSi]* IlluminationDisable!
    " au ModeChanged *:[n]* IlluminationEnable!
  augroup END
  ]], false)

_G.Config.lsp = M
return M
