local M = {}

local function conf(config_name)
  return require(string.format("user.custom.plugins.%s", config_name))
end

function M.init(use)
end

return M
