local M = {}

--- @param plugin_name string
--- @return string
local function local_plugin(plugin_name)
  local dev_abs_path = Path.from("~/Documents/dev/nvim/plugins/" .. plugin_name .. "/lua")
    :absolute()

  return dev_abs_path:is_readable():block_on()
    and dev_abs_path:tostring()
    or Path.from("~/.local/share/nvim/lazy/" .. plugin_name .. "/lua")
      :absolute()
      :tostring()
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
