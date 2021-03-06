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
-- lua_add_lib("~/.vim/plug/*")

require'lspconfig'.sumneko_lua.setup {
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
