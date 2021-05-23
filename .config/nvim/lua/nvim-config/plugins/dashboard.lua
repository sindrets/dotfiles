return function ()
  local utils = require "nvim-config.utils"

  vim.g.dashboard_default_executive = "telescope"

  local win_height = vim.api.nvim_win_get_height(0)

  if win_height < 25 then
    vim.g.dashboard_custom_header = {}
  else
    vim.g.dashboard_custom_header = {
      '  ⣠⣾⣄⠀⠀⠀⢰⣄⠀                                  ',
      '⠀⣾⣿⣿⣿⣆⠀⠀⢸⣿⣷ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡿⠀⠀⠀⠀⠀⠀⠀ ⠀⠀⠀',
      ' ⣿⣿⡟⢿⣿⣧⡀⢸⣿⣿ ⠀⣠⠴⠶⠦⡄⠀⢀⡤⠶⠶⣤⡀⣶⣦⠀⠀⢠⣶⡖⣶⣶⠀⣶⣦⣶⣶⣦⣠⣶⣶⣶⡄',
      ' ⣿⣿⡇⠈⢻⣿⣷⣼⣿⣿ ⢸⣇⣀⣀⣀⣹⢠⡟⠀⠀⠀⠈⣷⠘⣿⣇⠀⣾⡿⠀⣿⣿⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿',
      ' ⢿⣿⡇⠀⠀⠹⣿⣿⣿⡿ ⢸⡄⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀⣿⠀⠹⣿⣼⣿⠁⠀⣿⣿⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿',
      ' ⠀⠙⠇⠀⠀⠀⠘⠿⠋⠀ ⠀⠛⠦⠤⠴⠖⠀⠙⠦⠤⠤⠞⠁⠀⠀⠻⠿⠃⠀⠀⠿⠿⠀⠿⠿⠀⠀⠿⠿⠀⠀⠿⠿',
    }
  end

  local version_lines = utils.str_split(vim.api.nvim_exec("version", true), "\n")
  vim.g.dashboard_custom_footer = { version_lines[2] }

  vim.g.dashboard_custom_section = {
    a = {description = {'  New File           '}, command = 'DashboardNewFile'},
    b = {description = {'  Find File          '}, command = 'Telescope find_files'},
    c = {description = {'  Recently Used Files'}, command = 'Telescope oldfiles'},
    d = {description = {'  Load Last Session  '}, command = 'SessionLoad'},
    e = {description = {'  Find Word          '}, command = 'Telescope live_grep'},
    f = {description = {'  Jump Marks         '}, command = 'Telescope marks'}
  }

  vim.api.nvim_exec([[
    augroup DashboardConfig
      au!
      au FileType dashboard nnoremap <buffer> q :q<CR>
    augroup END
  ]], false)
end
