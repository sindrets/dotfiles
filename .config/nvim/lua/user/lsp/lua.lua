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

--- @param lib string|string[]
local function lua_add_lib(lib)
  --- @type string[]
  local libs = type(lib) == "table" and lib or { lib }

  for _, pattern in ipairs(libs) do
    for _, p in pairs(vim.fn.expand(pattern, false, true) --[[@as string[] ]]) do
      p = assert(vim.loop.fs_realpath(p))
      lua_lib[p] = true
    end
  end
end

local function get_lib()
  return vim.tbl_keys(lua_lib)
end

-- lua_add_lib("$VIMRUNTIME")
-- lua_add_lib(vim.fn.stdpath("data") .. "/site/pack/packer/start/diffview.nvim")
-- lua_add_lib(vim.fn.stdpath("data") .. "/lazy/plenary.nvim/lua")
lua_add_lib(require("neodev.config").types())

-- "$schema" = "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json"

require("lspconfig").lua_ls.setup(
  Config.lsp.create_config({
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
        hover = {
          enable = true,
          expandAlias = false,
        },
        hint = {
          enable = true,
          await = true,
          arrayIndex = "Disable",
          paramName = "Disable",
          paramType = false,
          semiColon = "Disable",
          setType = false,
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
