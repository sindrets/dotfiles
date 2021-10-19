local jdtls = require("jdtls")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local pickers = require("telescope.pickers")
local cmp_lsp = require("cmp_nvim_lsp")
local diagnostic = vim.diagnostic or vim.lsp.diagnostic

local M = {}

function M.within_range(outer, inner)
  local o1y = outer.start.line
  local o1x = outer.start.character
  local o2y = outer['end'].line
  local o2x = outer['end'].character
  assert(o1y <= o2y, "Start must be before end: " .. vim.inspect(outer))

  local i1y = inner.start.line
  local i1x = inner.start.character
  local i2y = inner['end'].line
  local i2x = inner['end'].character
  assert(i1y <= i2y, "Start must be before end: " .. vim.inspect(inner))

  if o1y < i1y then
    if o2y > i2y then
      return true
    end
    return o2y == i2y and o2x >= i2x
  elseif o1y == i1y then
    if o2y > i2y then
      return true
    else
      return o2y == i2y and o1x <= i1x and o2x >= i2x
    end
  else
    return false
  end
end

function M.get_diagnostics_for_range(bufnr, range)
  local diagnostics = diagnostic.get(bufnr)
  if not diagnostics then return {} end
  local line_diagnostics = {}
  for _, item in ipairs(diagnostics) do
    if M.within_range(item.range, range) then
      table.insert(line_diagnostics, item)
    end
  end
  if #line_diagnostics == 0 then
    -- If there is no diagnostics at the cursor position,
    -- see if there is at least something on the same line
    for _, item in ipairs(diagnostics) do
      if item.range.start.line == range.start.line then
        table.insert(line_diagnostics, item)
      end
    end
  end
  return line_diagnostics
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;
capabilities.workspace.configuration = true
capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

function M.start_jdtls()
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local function jdtls_on_attch(client, bufnr)
    LspCommonOnAttach(client, bufnr)
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
      diagnostics = M.get_diagnostics_for_range(bufnr, params.range),
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
  }, require'nvim-config.lsp'.get_local_settings())

  jdtls.start_or_attach({
      capabilities = capabilities,
      init_options = {
        extendedClientCapabilities = extendedClientCapabilities
      },
      cmd = {
        "jdtls", "-data", vim.fn.expand("$HOME") .. "/.cache/jdtls"
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

require('jdtls.ui').pick_one_async = function(items, prompt, label_fn, cb)
  local opts = require'telescope.themes'.get_cursor()
  pickers.new(opts, {
    prompt_title = prompt,
    finder    = finders.new_table {
      results = items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = label_fn(entry),
          ordinal = label_fn(entry),
        }
      end,
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = actions.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)

        cb(selection.value)
      end)

      return true
    end,
  }):find()
end

function M.attach_mappings()
  local map = function (mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true },  opts or {})
    vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
  end

  map("n", "<leader>.", "<Cmd>lua require'jdtls'.code_action()<CR>")
  map("n", "<M-O>", "<Cmd>lua require'jdtls'.organize_imports()<CR>")
end

vim.api.nvim_exec([[
  augroup JdtlsConfig
    au!
    au FileType java lua require'nvim-config.lsp.java'.start_jdtls()
    au FileType java lua require'nvim-config.lsp.java'.attach_mappings()
  augroup END
  ]], false)

return M
