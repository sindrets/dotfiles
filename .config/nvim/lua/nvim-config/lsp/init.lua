local cmp_lsp = require("cmp_nvim_lsp")
local lspconfig = require("lspconfig")

local utils = Config.common.utils
local pl = utils.pl
local config_store = {}

local M = {}
_G.Config.lsp = M

function M.common_on_attach(client, bufnr)
  require("illuminate").on_attach(client)
  require("lsp_signature").on_attach({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
      border = "single",
    },
  }, bufnr)
end

M.base_config = {
  on_attach = M.common_on_attach,
  capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

local local_config_paths = {
  ".vim/lsp_init.lua",
  ".vim/lsp_settings.lua",
  ".vim/lsp-settings.lua",
}

function M.create_local_config(config)
  local cwd = uv.cwd()
  local local_config = config_store[cwd]
  config = config or {}

  if not local_config then
    for _, path in ipairs(local_config_paths) do
      if pl:readable(path) then
        utils.info("Using project-local LSP config: " .. utils.str_quote(path), true)
        local code_chunk = loadfile(path)
        if code_chunk then
          local_config = code_chunk()
          break
        end
      end
    end

    if not local_config then
      local_config = {}
    end

    config_store[cwd] = local_config
  end

  if vim.is_callable(local_config) then
    local_config = local_config(config)
  else
    local_config = utils.tbl_union_extend(config, local_config)
  end

  return local_config
end

---Create lsp config from base + server defaults + local config.
---@param ... table Set of LSP configs sorted by order of precedence: later
---configs will overwrite earlier configs.
---@return table
function M.create_config(...)
  local config = utils.tbl_union_extend(M.base_config, {}, ...)

  return M.create_local_config(config)
end

-- Java
require("nvim-config.lsp.java")

-- Typescript
lspconfig.tsserver.setup(M.create_config())

-- Python
lspconfig.pyright.setup(M.create_config())

-- Lua
require("nvim-config.lsp.lua")

-- Teal
-- require("nvim-config.lsp.teal")

-- Bash
lspconfig.bashls.setup(M.create_config())

-- C#
lspconfig.omnisharp.setup(M.create_config({
  cmd = { "/usr/bin/omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) },
  filetypes = { "cs", "vb" },
  init_options = {},
  -- root_dir = lspconfig.util.root_pattern(".csproj", ".sln"),
  -- root_dir = vim.fn.getcwd
}))

-- C, C++
lspconfig.clangd.setup(M.create_config())

-- Vim
lspconfig.vimls.setup(M.create_config())

-- Go
lspconfig.gopls.setup(M.create_config())

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

M.define_diagnostic_signs({
  error = "",
  warn = "",
  hint = "",
  info = ""
})

-- LSP auto commands
Config.common.au.declare_group("lsp_init", {}, {
  { "CursorHold", callback = M.show_position_diagnostics, },

  -- { "ModeChanged", pattern = "*:[vVsSi]*", command = "IlluminationDisable!" },
  -- { "ModeChanged", pattern = "*:[n]*", command = "IlluminationEnable!" },

  -- { "CursorHold",  callback = M.highlight_cursor_symbol() },
  -- { "CursorMoved", callback = M.highlight_cursor_clear(), },
})

return M
