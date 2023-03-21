local lua_path = {
  "lua/?.lua",
  "lua/?/init.lua",
  "?.lua",
  "?/init.lua",
}

for _, v in ipairs(vim.split(package.path, ";", {})) do
  table.insert(lua_path, v)
end

local lua_lib = {}

-- local function lua_add_lib(lib)
--   for _, p in pairs(vim.fn.expand(lib, false, true)) do
--     p = vim.loop.fs_realpath(p)
--     lua_lib[p] = true
--   end
-- end

local function get_lib()
  return vim.tbl_keys(lua_lib)
end

-- lua_add_lib("$VIMRUNTIME")
-- lua_add_lib(vim.fn.stdpath("data") .. "/site/pack/packer/start/diffview.nvim")

-- "$schema" = "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json"

require("lspconfig").lua_ls.setup(Config.lsp.create_config(
  require("lua-dev").setup({
    library = {
      vimruntime = false, -- runtime path
      types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
      -- plugins = false, -- installed opt or start plugins in packpath
      -- you can also specify the list of plugins to make available as a workspace library
      plugins = { "plenary.nvim" },
    },
    runtime_path = false, -- enable this to get completion in require strings. Slow!
  }),
  {
    cmd = {
      "lua-language-server"
    },
    filetypes = { "lua" },
    settings = {
      Lua = {
        completion = {
          callSnippet = "Disable",
        },
        runtime = {
          version = "LuaJIT",
          path = lua_path,
          fileEncoding = "utf8",
          unicodeName = true
        },
        diagnostics = {
          globals = { "vim", "jit", "bit", "Config" }
        },
        workspace = {
          library = get_lib(),
          checkThirdParty = false,
          maxPreload = 2000,
          preloadFileSize = 50000
        },
        telemetry = {
          enable = false,
        },
        format = {
          enable = true,
          -- NOTE: all the values need to be of type 'string'
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
          },
        },
      },
    },
  }
))
