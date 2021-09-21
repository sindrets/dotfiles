return function()
  vim.g.material_style = "palenight"

  require('material').setup({
    contrast = true, -- Enable contrast for sidebars, floating windows and popup menus like Nvim-Tree
    borders = true, -- Enable borders between verticaly split windows

    italics = {
      comments = true, -- Enable italic comments
      keywords = false, -- Enable italic keywords
      functions = true, -- Enable italic functions
      strings = false, -- Enable italic strings
      variables = false -- Enable italic variables
    },

    contrast_windows = { -- Specify which windows get the contrasted (darker) background
      "NvimTree",
      "packer", -- Darker packer background
    },

    text_contrast = {
      lighter = false, -- Enable higher contrast text for lighter style
      darker = false -- Enable higher contrast text for darker style
    },

    disable = {
      background = false, -- Prevent the theme from setting the background (NeoVim then uses your teminal background)
      term_colors = false, -- Prevent the theme from setting terminal colors
      eob_lines = true -- Hide the end-of-buffer lines
    },

    custom_highlights = {} -- Overwrite highlights with your own
  })
end
