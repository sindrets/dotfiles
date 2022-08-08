NvimConfigDir = vim.fn.stdpath("config")

require("user.settings")
vim.cmd("source " .. NvimConfigDir .. "/mappings.vim")
vim.cmd("source " .. NvimConfigDir .. "/autocommands.vim")
require("user.plugins")

-- Colorscheme tweaks and settings
require("user.colorscheme")

vim.schedule(function()
  require("user.lsp")
  vim.cmd("LspStart")
end)
