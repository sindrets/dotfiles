return function()
  -- require("nvim-treesitter.configs").setup({
  --   rainbow = {
  --     enable = true,
  --     extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
  --     max_file_lines = 3000, -- Do not enable for files with more than 1000 lines, int
  --   },
  -- })

  local rainbow_delimiters = require 'rainbow-delimiters'

  require('rainbow-delimiters.setup')({
    strategy = {
      [''] = rainbow_delimiters.strategy['global'],
    },
    query = {
      [''] = 'rainbow-delimiters',
    },
    highlight = {
      'TSRainbowRed',
      'TSRainbowYellow',
      'TSRainbowBlue',
      'TSRainbowOrange',
      'TSRainbowGreen',
      'TSRainbowViolet',
      'TSRainbowCyan',
    },
  })
end
