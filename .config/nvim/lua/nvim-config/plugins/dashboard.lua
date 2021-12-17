return function ()
  local function process_section(section)
    local result = {}

    local longest = -1
    for _, entry in ipairs(section) do
      entry.display_len = vim.api.nvim_strwidth(entry.description[1])
      longest = math.max(longest, entry.display_len)
    end

    for i, entry in ipairs(section) do
      entry.description[1] = entry.description[1]
        .. string.rep(" ", longest - entry.display_len)
      result["k" .. i] = entry
    end

    return result
  end

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

  local version_lines = vim.split(vim.api.nvim_exec("version", true), "\n")
  vim.g.dashboard_custom_footer = { version_lines[2] }

  local section = {
    { description = { '  New File' }, command = 'DashboardNewFile' },
    { description = { '  Find File' }, command = 'lua require"nvim-config.lib".workspace_files()' },
    { description = { '  Git Status' }, command = 'Telescope git_status' },
    { description = { '  Recently Used Files' }, command = 'Telescope oldfiles' },
    { description = { '  Load Last Session' }, command = 'SessionLoad' },
    { description = { '  Find Word' }, command = 'Telescope live_grep' },
    { description = { '  Jump to Mark' }, command = 'Telescope marks' }
  }

  vim.g.dashboard_custom_section = process_section(section)

  vim.api.nvim_exec([[
    augroup DashboardConfig
      au!
      au FileType dashboard nnoremap <buffer> q :q<CR>
    augroup END
  ]], false)
end
