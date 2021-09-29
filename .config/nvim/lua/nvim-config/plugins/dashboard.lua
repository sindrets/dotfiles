return function ()
  local utils = require "nvim-config.utils"

  local function process_sections(sections)
    local result = {}

    local longest = -1
    for _, section in ipairs(sections) do
      section.display_len = vim.fn.strdisplaywidth(section.description[1])
      longest = math.max(longest, section.display_len)
    end

    for i, section in ipairs(sections) do
      section.description[1] = section.description[1]
        .. string.rep(" ", longest - section.display_len)
      result["k" .. i] = section
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

  local version_lines = utils.str_split(vim.api.nvim_exec("version", true), "\n")
  vim.g.dashboard_custom_footer = { version_lines[2] }

  local sections = {
    { description = { '  New File' }, command = 'DashboardNewFile' },
    { description = { '  Find File' }, command = 'lua require"nvim-config.lib".workspace_files()' },
    { description = { '  Modified Files' }, command = 'Telescope git_status' },
    { description = { '  Recently Used Files' }, command = 'Telescope oldfiles' },
    { description = { '  Load Last Session' }, command = 'SessionLoad' },
    { description = { '  Find Word' }, command = 'Telescope live_grep' },
    { description = { '  Jump to Mark' }, command = 'Telescope marks' }
  }

  vim.g.dashboard_custom_section = process_sections(sections)

  vim.api.nvim_exec([[
    augroup DashboardConfig
      au!
      au FileType dashboard nnoremap <buffer> q :q<CR>
    augroup END
  ]], false)
end
