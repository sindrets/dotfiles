local async = require("imminent")

local M = {}

async.block_on(function()
  --- @param plugin_name string
  --- @return imminent.Future<[string]>
  local function local_plugin(plugin_name)
    return async.Future.from(function()
      local dev_abs_path = Path.concat("~/Documents/dev/nvim/plugins/", plugin_name, "lua")
        :unwrap()
        :absolute()

      return dev_abs_path:is_readable():await()
        and dev_abs_path:tostring()
        or Path.concat("~/.local/share/nvim/lazy/", plugin_name, "lua")
          :unwrap()
          :absolute()
          :tostring()
    end)
  end

  M.lsp_config = {
    settings = {
      Lua = {
        workspace = {
          library = async.all({
            local_plugin("diffview.nvim"),
            local_plugin("imminent.nvim"),
          })
            :await()
            :iter()
            :flat()
            :totable(),
        },
      },
    },
  }
end)

return M
