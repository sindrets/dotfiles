return function ()
  require'nvim-treesitter.configs'.setup {
    rainbow = {
      enable = true,
      extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
      max_file_lines = 1500, -- Do not enable for files with more than 1000 lines, int
      colors = {
        "#bf616a",
        "#d08770",
        "#ebcb8b",
        "#a3be8c",
        "#88c0d0",
        "#5e81ac",
        "#b48ead"
      }
    }
  }
end
