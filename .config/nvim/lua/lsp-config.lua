USER = vim.fn.expand("$USER")
HOME = vim.fn.expand("$HOME")
PID = vim.fn.getpid()
local utils = require("nvim-utils")
local ts_utils = require("nvim-treesitter.ts_utils")
local lspconfig = require("lspconfig")
local jdtls = require("jdtls")
-- local lspsaga_codeaction = require("lspsaga.codeaction")
-- local root_pattern = lspconfig.util.root_pattern

vim.lsp.util.apply_text_document_edit = function(text_document_edit, index)
    local text_document = text_document_edit.textDocument
    local bufnr = vim.uri_to_bufnr(text_document.uri)

    vim.lsp.util.apply_text_edits(text_document_edit.edits, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;
capabilities.workspace.configuration = true

-- Java

function Start_jdtls()
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
                ["workspace/executeCommand"] = on_execute_command
            },
            settings = {
                ["java.project.referencedLibraries"] = {
                    "lib/**/*.jar",
                    "lib/*.jar"
                },
                -- ["java.format.settings.url"] = "eclipse-formatter.xml"
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
            }
        })

    -- if not lspsaga_codeaction.action_handlers["jdt.ls"] then
        --     lspsaga_codeaction.add_code_action_handler("jdt.ls", function(action)
                --         jdtls.do_code_action(action)
            --     end)
    -- end
end

vim.api.nvim_command([[au FileType java lua Start_jdtls()]])

-- Typescript
lspconfig.tsserver.setup{}

-- Python
lspconfig.pyright.setup{}

-- Lua
local lua_path = {
    "?.lua",
    "?/init.lua",
    "?/?.lua"
}
for _, v in ipairs(vim.split(package.path, ";")) do
    table.insert(lua_path, v)
end

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
                -- Make the server aware of Neovim runtime files
                library = {
                    [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                    [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                },
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

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        underline = true,
        signs = true,
        update_in_insert = true
    }
)

-- Highlight references on cursor hold

local lastTsNodeId = nil

function Highlight_cursor_symbol()
    if vim.lsp.buf.server_ready() then
        local node = ts_utils.get_node_at_cursor()
        local curTsNodeId
        if node then
            curTsNodeId = node.id(node)
        end

        if lastTsNodeId and curTsNodeId then
            if lastTsNodeId == curTsNodeId then
                return
            end
        end

        vim.lsp.buf.document_highlight()
        lastTsNodeId = curTsNodeId
    end
end

function Highlight_cursor_clear()
    if vim.lsp.buf.server_ready() then
        local node = ts_utils.get_node_at_cursor()
        local curTsNodeId
        if node then
            curTsNodeId = node.id(node)
        end

        if lastTsNodeId and curTsNodeId then
            if lastTsNodeId == curTsNodeId then
                return
            end
        end

        vim.lsp.buf.clear_references()
        lastTsNodeId = nil
    end
end
---------------------------------

-- Only show diagnostics if cur line is not the same as last call.
local last_diagnostics_line = nil
function Show_line_diagnostics()
    local cur_line = vim.api.nvim_eval("line('.')")
    if last_diagnostics_line and last_diagnostics_line == cur_line then
        return
    end
    last_diagnostics_line = cur_line

    require("lspsaga.diagnostic").show_line_diagnostics()
end

-- LSP auto commands
vim.api.nvim_exec([[
    augroup init_lsp
        au!
        au ColorScheme * :hi def link LspReferenceText CursorLine
        au ColorScheme * :hi def link LspReferenceRead CursorLine
        au ColorScheme * :hi def link LspReferenceWrite CursorLine
        au CursorHold   * silent! lua Highlight_cursor_symbol()
        au CursorHoldI  * silent! lua Highlight_cursor_symbol()
        au CursorMoved  * silent! lua Highlight_cursor_clear()
        au CursorMovedI * silent! lua Highlight_cursor_clear()

        au CursorHold * silent! lua Show_line_diagnostics()
        au CursorHoldI * silent! lua require('lspsaga.signaturehelp').signature_help()
    augroup END
]], false)
