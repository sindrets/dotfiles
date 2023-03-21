local config_dir = vim.fn.stdpath("config")

-- Set up these auto commands early to ensure priority over plugins
local group = vim.api.nvim_create_augroup("colorscheme_config", {})
vim.api.nvim_create_autocmd("ColorSchemePre", {
  group = group,
  callback = function(ctx)
    require("user.colorscheme").setup_colorscheme(ctx.match)
  end,
})
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function() require("user.colorscheme").apply_tweaks() end,
})

require("user.settings")
require("user.plugins")

vim.cmd("source " .. config_dir .. "/mappings.vim")
require("user.commands")
vim.cmd("source " .. config_dir .. "/autocommands.vim")

-- Colorscheme tweaks and settings
require("user.colorscheme").apply()

vim.schedule(function()
  require("user.lsp")
  vim.cmd("LspStart")
end)
