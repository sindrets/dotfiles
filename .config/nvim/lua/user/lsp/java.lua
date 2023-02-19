local jdtls = require("jdtls")
local cmp_lsp = require("cmp_nvim_lsp")

local utils = Config.common.utils

local M = {}

local capabilities = utils.tbl_union_extend(
  vim.lsp.protocol.make_client_capabilities(),
  cmp_lsp.default_capabilities()
)
capabilities.textDocument.completion.completionItem.snippetSupport = true;
capabilities.workspace.configuration = true

function M.start_jdtls()
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local function jdtls_on_attch(client, bufnr)
    Config.lsp.common_on_attach(client, bufnr)
    require("jdtls.setup").add_commands()
    -- local opts = { noremap = true, silent = true; }
  end

  local settings = require("user.lsp").create_local_config({
    ["java.project.referencedLibraries"] = {
      "lib/**/*.jar",
      "lib/*.jar"
    },
    java = {
      signatureHelp = { enabled = true };
      contentProvider = { preferred = "fernflower" };
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
    },
  })

  jdtls.start_or_attach({
    capabilities = capabilities,
    init_options = {
      extendedClientCapabilities = extendedClientCapabilities
    },
    cmd = {
      "jdtls",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xms1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED",
      "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-data",
      vim.env.HOME .. "/.cache/jdtls",
    },
    filetypes = { "java" }, -- Not used by jdtls, but used by lspsaga
    on_attach = jdtls_on_attch,
    root_dir = require("jdtls.setup").find_root({ ".git", "gradlew", "build.xml", "mvnw" }),
    -- root_dir = vim.fn.getcwd(),
    flags = {
      allow_incremental_sync = true,
      server_side_fuzzy_completion = true,
    },
    settings = settings
  })
end

function M.attach_mappings()
  local map = function (mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { buffer = 0 },  opts or {}) --[[@as table ]]
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  map("n", "<M-O>", jdtls.organize_imports)
end

Config.common.au.declare_group("jdtls_config", {}, {
  {
    "FileType", pattern = "java", callback = function()
      M.start_jdtls()
      M.attach_mappings()
    end,
  },
})

return M
