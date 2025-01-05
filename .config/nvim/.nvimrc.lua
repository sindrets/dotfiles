local M = {}

--- @param plugin_name string
--- @return string
local function local_plugin(plugin_name)
  local dev_abs_path = pl:absolute("~/Documents/dev/nvim/plugins/" .. plugin_name .. "/lua")
  return pl:readable(dev_abs_path)
    and dev_abs_path
    or pl:absolute("~/.local/share/nvim/lazy/" .. plugin_name .. "/lua")
end

M.lsp_config = {
  settings = {
    Lua = {
      workspace = {
        library = {
          local_plugin("diffview.nvim"),
          local_plugin("imminent.nvim"),
        },
      },
    },
  },
}

return M
