NvimConfigDir = vim.fn.stdpath("config")

require'nvim-config.settings'
vim.cmd("source " .. NvimConfigDir .. "/mappings.vim")
vim.cmd("source " .. NvimConfigDir .. "/autocommands.vim")
require'nvim-config.plugins'
require'nvim-config.plugins.lsp-config'

-- Colorscheme tweaks and settings
vim.cmd("source " .. NvimConfigDir .. "/color-config.vim")
