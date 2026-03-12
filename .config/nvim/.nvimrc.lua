local async = require("imminent")

local M = {}

async.block_on(function()
  --- @async
  --- @param plugin_name string
  --- @return string
  local function local_plugin(plugin_name)
    local dev_abs_path = Path.concat("~/Documents/dev/nvim/plugins/", plugin_name, "lua")
      :unwrap()
      :absolute()


    return dev_abs_path:is_readable():await()
      and dev_abs_path:tostring()
      or Path.concat("~/.local/share/nvim/lazy/", plugin_name, "lua")
        :unwrap()
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
end)

return M
