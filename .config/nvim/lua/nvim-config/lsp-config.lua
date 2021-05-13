USER = vim.fn.expand("$USER")
HOME = vim.fn.expand("$HOME")
PID = vim.fn.getpid()
local utils = require("nvim-config.utils")
local lspconfig = require("lspconfig")
local jdtls = require("jdtls")
-- local lspsaga_codeaction = require("lspsaga.codeaction")
-- local root_pattern = lspconfig.util.root_pattern

local M = {}

local diagnostic_signs = {
  error = "",
  warn = "",
  hint = "",
  info = ""
}

local local_settings = {}
if utils.file_readable(".vim/lsp-settings.lua") then
  local code_chunk = loadfile(".vim/lsp-settings.lua")
  if code_chunk then
    local_settings = code_chunk()
  end
end

vim.lsp.util.apply_text_document_edit = function(text_document_edit, index)
  local text_document = text_document_edit.textDocument
  local bufnr = vim.uri_to_bufnr(text_document.uri)

  vim.lsp.util.apply_text_edits(text_document_edit.edits, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;
capabilities.workspace.configuration = true

-- Java

function M.start_jdtls()
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local function jdtls_on_attch(client, bufnr)
    require'jdtls.setup'.add_commands()
    -- local opts = { noremap = true, silent = true; }
  end

  local function make_code_action_params(from_selection, kind)
    local params
    if from_selection then
      params = vim.lsp.util.make_given_range_params()
    else
      params = vim.lsp.util.make_range_params()
    end
    local bufnr = vim.api.nvim_get_current_buf()
    params.context = {
      diagnostics = utils.get_diagnostics_for_range(bufnr, params.range),
      only = kind,
    }
    return params
  end

  -- function(err, method, result, client_id, bufnr, config)
  local function on_execute_command(_, _, params, _, _)
    print("executeCommand:", vim.inspect(params))
    local code_action_params = make_code_action_params(false)
    if not params then
      return
    end
    if params.edit then
      vim.lsp.util.apply_workspace_edit(params.edit)
    end
    local command
    if type(params.command) == "table" then
      command = params.command
    else
      command = params
    end
    local fn = jdtls.commands[command.command]
    if fn then
      fn(command, code_action_params)
    else
      require("jdtls.util").execute_command(command)
    end
  end

  local settings = vim.tbl_deep_extend("force", {
    ["java.project.referencedLibraries"] = {
      "lib/**/*.jar",
      "lib/*.jar"
    },
    java = {
      signatureHelp = { enabled = true };
      contentProvider = { preferred = 'fernflower' };
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*"
        }
      };
    }
  }, local_settings)

  jdtls.start_or_attach({
      capabilities = capabilities,
      init_options = {
        extendedClientCapabilities = extendedClientCapabilities
      },
      cmd = {
        "jdtls", "-data", HOME .. "/.cache/jdtls"
      },
      filetypes = { "java" }, -- Not used by jdtls, but used by lspsaga
      on_attach = jdtls_on_attch,
      root_dir = require("jdtls.setup").find_root({ ".git", "gradlew", "build.xml" }),
      -- root_dir = vim.fn.getcwd(),
      flags = {
        allow_incremental_sync = true,
        server_side_fuzzy_completion = true,
      },
      handlers = {
        ["workspace/executeCommand"] = on_execute_command,
      },
      settings = settings
    })

  -- if not lspsaga_codeaction.action_handlers["jdt.ls"] then
  --   lspsaga_codeaction.add_code_action_handler("jdt.ls", function(action)
  --     jdtls.do_code_action(action)
  --   end)
  -- end
end

vim.api.nvim_command([[au FileType java lua LspConfig.start_jdtls()]])

--[[
--BEGIN LSP CONFIG
--]]

-- Typescript
lspconfig.tsserver.setup{}

-- Python
lspconfig.pyright.setup{}

-- Lua
local lua_path = {
  "lua/?.lua",
  "lua/?/init.lua",
}

for _, v in ipairs(vim.split(package.path, ";")) do
  table.insert(lua_path, v)
end

local lua_lib = {}

local function lua_add_lib(lib)
  for _, p in pairs(vim.fn.expand(lib, false, true)) do
    p = vim.loop.fs_realpath(p)
    lua_lib[p] = true
  end
end

lua_add_lib("$VIMRUNTIME")
lua_add_lib("~/.config/nvim")
lua_add_lib("~/.vim/plug/*")

lspconfig.sumneko_lua.setup{
  cmd = {
    "lua-language-server"
  },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        path = lua_path,
        fileEncoding = "utf8",
        unicodeName = true
      },
      diagnostics = {
        globals = { "vim" }
      },
      workspace = {
        library = lua_lib,
        maxPreload = 2000,
        preloadFileSize = 50000
      },
      telemetry = {
        enable = false,
      },
    }
  }
}

-- C#
require'lspconfig'.omnisharp.setup{
  cmd = { "/usr/bin/omnisharp", "--languageserver" , "--hostPID", tostring(PID) },
  filetypes = { "cs", "vb" },
  init_options = {},
  -- root_dir = lspconfig.util.root_pattern(".csproj", ".sln"),
  -- root_dir = vim.fn.getcwd
}

-- C, C++
require'lspconfig'.clangd.setup{}

-- Vim
require'lspconfig'.vimls.setup{}

-- Go
require'lspconfig'.gopls.setup{}

--[[
--END LSP-CONFIG
--]]

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    underline = true,
    signs = true,
    update_in_insert = true
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    -- Use a sharp border with `FloatBorder` highlights
    border = "single"
  }
)

function M.define_diagnostic_signs(opts)
  local group = {
    err_group = {
      highlight = 'LspDiagnosticsSignError',
      sign = opts.error
    },
    warn_group = {
      highlight = 'LspDiagnosticsSignWarning',
      sign = opts.warn
    },
    hint_group = {
      highlight = 'LspDiagnosticsSignHint',
      sign = opts.hint
    },
    infor_group = {
      highlight = 'LspDiagnosticsSignInformation',
      sign = opts.info
    },
  }

  for _,g in pairs(group) do
    vim.fn.sign_define(
    g.highlight,
    {text=g.sign,texthl=g.highlight,linehl='',numhl=''}
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

-- Only show diagnostics if cur line is not the same as last call.
local last_diagnostics_line = nil
function M.show_line_diagnostics()
  local cur_line = vim.api.nvim_eval("line('.')")
  if last_diagnostics_line and last_diagnostics_line == cur_line then
    return
  end
  last_diagnostics_line = cur_line

  vim.lsp.diagnostic.show_line_diagnostics()
end

-- LSP auto commands
vim.api.nvim_exec([[
  augroup init_lsp
    au!
    au ColorScheme * :hi def link LspReferenceText CursorLine
    au ColorScheme * :hi def link LspReferenceRead CursorLine
    au ColorScheme * :hi def link LspReferenceWrite CursorLine
    au CursorHold   * silent! lua LspConfig.highlight_cursor_symbol()
    au CursorHoldI  * silent! lua LspConfig.highlight_cursor_symbol()
    au CursorMoved  * silent! lua LspConfig.highlight_cursor_clear()
    au CursorMovedI * silent! lua LspConfig.highlight_cursor_clear()

    au CursorHold * silent! lua LspConfig.show_line_diagnostics()
    au CursorHoldI * silent! lua vim.lsp.buf.signature_help()
  augroup END
  ]], false)

_G.LspConfig = M
return M
