return function ()
  vim.g.dashboard_default_executive = "telescope"

  vim.g.dashboard_custom_header = {
    '  ⣠⣾⣄⠀⠀⠀⢰⣄⠀                                  ',
    '⠀⣾⣿⣿⣿⣆⠀⠀⢸⣿⣷ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡿⠀⠀⠀⠀⠀⠀⠀ ⠀⠀⠀',
    ' ⣿⣿⡟⢿⣿⣧⡀⢸⣿⣿ ⠀⣠⠴⠶⠦⡄⠀⢀⡤⠶⠶⣤⡀⣶⣦⠀⠀⢠⣶⡖⣶⣶⠀⣶⣦⣶⣶⣦⣠⣶⣶⣶⡄',
    ' ⣿⣿⡇⠈⢻⣿⣷⣼⣿⣿ ⢸⣇⣀⣀⣀⣹⢠⡟⠀⠀⠀⠈⣷⠘⣿⣇⠀⣾⡿⠀⣿⣿⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿',
    ' ⢿⣿⡇⠀⠀⠹⣿⣿⣿⡿ ⢸⡄⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀⣿⠀⠹⣿⣼⣿⠁⠀⣿⣿⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿',
    ' ⠀⠙⠇⠀⠀⠀⠘⠿⠋⠀ ⠀⠛⠦⠤⠴⠖⠀⠙⠦⠤⠤⠞⠁⠀⠀⠻⠿⠃⠀⠀⠿⠿⠀⠿⠿⠀⠀⠿⠿⠀⠀⠿⠿',
  }

  vim.g.dashboard_custom_section = {
    a = {description = {'  New File           '}, command = 'DashboardNewFile'},
    b = {description = {'  Find File          '}, command = 'Telescope find_files'},
    c = {description = {'  Recently Used Files'}, command = 'Telescope oldfiles'},
    d = {description = {'  Load Last Session  '}, command = 'SessionLoad'},
    e = {description = {'  Find Word          '}, command = 'Telescope live_grep'},
    f = {description = {'  Jump Marks         '}, command = 'Telescope marks'}
  }
end
