local lua_path = {
  "lua/?.lua",
  "lua/?/init.lua",
}

for _, v in ipairs(vim.split(package.path, ";", {})) do
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
lua_add_lib(vim.fn.stdpath("data") .. "/site/pack/packer/start/plenary.nvim")
lua_add_lib(vim.fn.stdpath("data") .. "/site/pack/packer/start/diffview.nvim")

local config = vim.tbl_deep_extend("force", LspGetDefaultConfig(), {
  cmd = {
    "lua-language-server"
  },
  filetypes = { "lua" },
  settings = {
    Lua = {
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
        library = lua_lib,
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
})

require'lspconfig'.sumneko_lua.setup(config)
