local mason = prequire("mason")
local mason_lspconfig = prequire("mason-lspconfig")

if mason then mason.setup() end
if mason_lspconfig then mason_lspconfig.setup() end

require("neodev").setup({
  library = {
    -- Runtime path
    vimruntime = false,
    -- Full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
    types = true,
    --- Installed opt or start plugins in packpath you can also specify the list
    --- of plugins to make available as a workspace library
    plugins = false,
  },
  runtime_path = false, -- enable this to get completion in require strings. Slow!
})

local cmp = prequire("cmp")
local cmp_lsp = prequire("cmp_nvim_lsp")
local blink = prequire("blink.cmp")
local lspconfig = prequire("lspconfig")

if not lspconfig then return end

local Path = Config.common.utils.Path
local utils = Config.common.utils
local notify = Config.common.notify
local config_store = {}

local M = {}
_G.Config.lsp = M

---@diagnostic disable-next-line: unused-local
function M.common_on_attach(client, bufnr)
  -- require("illuminate").on_attach(client)

  local lsp_signature = prequire("lsp_signature")
  if lsp_signature then
    lsp_signature.on_attach({
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      handler_opts = {
        border = "single",
      },
    }, bufnr)
  end
end

M.base_config = {
  on_attach = M.common_on_attach,
  capabilities = utils.tbl_union_extend(
    vim.lsp.protocol.make_client_capabilities(),
    blink and blink.get_lsp_capabilities({}) or {},
    cmp_lsp and cmp_lsp.default_capabilities() or {}
  ),
}

M.local_config_paths = {
  ".vim/lsp_init.lua",
  ".vim/lsp_settings.lua",
  ".vim/lsprc.lua",
  ".lsprc.lua",
}

function M.create_local_config(config)
  local cwd = assert(uv.cwd())
  local local_config = config_store[cwd]
  local project_config = Config.state.project_config
  config = config or {}

  if not local_config then
    if type(project_config) == "table" and project_config.lsp_config then
      local_config = project_config.lsp_config
      notify.config("Using LSP config from project config.")
    else
      for _, path in ipairs(M.local_config_paths) do
        if Path.from(path):is_readable():block_on() then
          local data = vim.secure.read(path)

          if data then
            notify.config("Using project-local LSP config: " .. utils.str_quote(path))
            utils.exec_lua(data)
            break
          end
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
require("user.lsp.java")

-- Typescript
-- lspconfig.tsserver.setup(M.create_config())
require("user.lsp.typescript")

-- Deno
-- lspconfig.denols.setup(M.create_config())

-- Lua
-- require("user.lsp.lua")
vim.lsp.config("emmylua_ls", M.create_config({
  settings = {
    Lua = {
      workspace = {
        library = {
          "$VIMRUNTIME",
          "~/.local/share/nvim/types/luv/",
        },
      },
    },
  },
}))
vim.lsp.enable("emmylua_ls")

-- C#
-- require("user.lsp.csharp")

-- Haxe
vim.lsp.config("haxe_language_server", M.create_config({
  -- NOTE: Doesn't work with xargs here. Something about the tty?
  cmd = {
    "sh",
    "-c",
    [=[haxe-language-server $(find . -maxdepth 6 -type f -name 'build.hxml')]=],
  },
  root_dir = lspconfig.util.root_pattern('build.hxml', 'Makefile', '.git'),
  init_options = {
    displayArguments = { 'build.hxml' },
  },
}))

vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = {
    priority = 100,
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = ""
    }
  },
  update_in_insert = false,
})

-- DIAGNOSTICS: Only show the sign with the highest priority per line
-- From: `:h diagnostic-handlers-example`

local ns = vim.api.nvim_create_namespace("user_lsp")
local orig_signs_handler = vim.diagnostic.handlers.signs

-- Override the built-in signs handler
vim.diagnostic.handlers.signs = {
  show = function(_, bufnr, _, opts)
    -- Get all diagnostics from the whole buffer rather than just the
    -- diagnostics passed to the handler
    local diagnostics = vim.diagnostic.get(bufnr)

    -- Find the "worst" diagnostic per line
    local max_severity_per_line = {}
    for _, d in pairs(diagnostics) do
      local m = max_severity_per_line[d.lnum]
      if not m or d.severity < m.severity then
        max_severity_per_line[d.lnum] = d
      end
    end

    -- Pass the filtered diagnostics (with our custom namespace) to
    -- the original handler
    assert(orig_signs_handler.show)(ns, bufnr, vim.tbl_values(max_severity_per_line), opts)
  end,
  hide = function(_, bufnr)
    assert(orig_signs_handler.hide)(ns, bufnr)
  end,
}

local preview_opts = { border = "single", max_width = 100 }
function M.buf_hover() vim.lsp.buf.hover(preview_opts) end
function M.buf_signature_help() vim.lsp.buf.signature_help(preview_opts) end

--- @param opts table<"error"|"warn"|"hint"|"info", string>
function M.define_diagnostic_signs(opts)
  local group = {
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
    vim.fn.sign_define(g.highlight, {
      text = g.sign,
      texthl = g.highlight,
      linehl = '',
      numhl = '',
    })
  end
end

-- Highlight references on cursor hold

-- function M.highlight_cursor_symbol()
--   if vim.lsp.buf.server_ready() then
--     if vim.api.nvim_get_mode().mode ~= "i" then
--       vim.lsp.buf.document_highlight()
--     end
--   end
-- end
--
-- function M.highlight_cursor_clear()
--   if vim.lsp.buf.server_ready() then
--     vim.lsp.buf.clear_references()
--   end
-- end

---------------------------------

-- Only show diagnostics if current word + line is not the same as last call.
local last_diagnostics_word = nil
function M.show_position_diagnostics()
  if not vim.diagnostic.is_enabled({ bufnr = 0 })
    -- NOTE: `cmp.visible()` is very slow (at least 10ms) ! Avoid.
    or (cmp and cmp.core.view:visible() or vim.fn.pumvisible() == 1)
  then
    return
  end

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
  hint = "",
  info = ""
})

do
  -- LSP auto commands
  Config.common.au.declare_group("lsp_init", {}, {
    { "CursorHold", callback = M.show_position_diagnostics },
    {
      "LspAttach",
      callback = function(state)
        local client = vim.lsp.get_client_by_id(state.data.client_id)

        if client and
          client.server_capabilities and
          client.server_capabilities.inlayHintProvider
        then
          -- Enable inlay hints:
          vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
        end
      end,
    },
    {
      "ModeChanged",
      pattern = "*:i*",
      callback = function(state)
        if vim.diagnostic.is_enabled({ bufnr = 0 }) then
          vim.b.diagnotic_was_toggled = true
          vim.diagnostic.enable(false, { bufnr = state.buf })
        end
      end,
    },
    {
      "ModeChanged",
      pattern = "i*:*",
      callback = function(state)
        if vim.b.diagnotic_was_toggled then
          vim.b.diagnotic_was_toggled = false
          vim.diagnostic.enable(true, { bufnr = state.buf })
        end
      end,
    },
  })
end

return M
