local jdtls = require("jdtls")
local cmp_lsp = require("cmp_nvim_lsp")

local M = {}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;
capabilities.workspace.configuration = true
capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

function M.start_jdtls()
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local function jdtls_on_attch(client, bufnr)
    Config.lsp.common_on_attach(client, bufnr)
    require'jdtls.setup'.add_commands()
    -- local opts = { noremap = true, silent = true; }
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
  }, require'nvim-config.lsp'.create_local_config())

  jdtls.start_or_attach({
    capabilities = capabilities,
    init_options = {
      extendedClientCapabilities = extendedClientCapabilities
    },
    cmd = {
      "jdtls", "-data", vim.env.HOME .. "/.cache/jdtls"
    },
    filetypes = { "java" }, -- Not used by jdtls, but used by lspsaga
    on_attach = jdtls_on_attch,
    root_dir = require("jdtls.setup").find_root({ ".git", "gradlew", "build.xml" }),
    -- root_dir = vim.fn.getcwd(),
    flags = {
      allow_incremental_sync = true,
      server_side_fuzzy_completion = true,
    },
    settings = settings
  })

  -- if not lspsaga_codeaction.action_handlers["jdt.ls"] then
  --   lspsaga_codeaction.add_code_action_handler("jdt.ls", function(action)
  --     jdtls.do_code_action(action)
  --   end)
  -- end
end

function M.attach_mappings()
  local map = function (mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true },  opts or {})
    vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
  end

  map("n", "<M-O>", "<Cmd>lua require'jdtls'.organize_imports()<CR>")
end

Config.common.au.declare_group("jdtls_config", {}, {
  { "FileType", pattern = "java", callback = M.start_jdtls },
  { "FileType", pattern = "java", callback = M.attach_mappings },
})

return M
