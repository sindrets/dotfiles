return function ()
  require("indent_blankline").setup({
    char = "▏",
    context_char = "▏",
    -- space_char = " ",
    space_char_blankline = "⠀",
    use_treesitter = false,
    use_treesitter_scope = false,
    show_trailing_blankline_indent = false,
    show_current_context = true,
    max_indent_increase = 2,
    buftype_exclude = {
      "terminal",
      "nofile",
    },
    filetype_exclude = {
      "help",
      "startify",
      "dashboard",
      "alpha",
      "packer",
      "NeogitStatus",
      "NeogitCommitView",
      "NeogitPopup",
      "NeogitLogView",
      "NeogitCommitMessage",
      "man",
      "sagasignature",
      "sagahover",
      "lspsagafinder",
      "LspSagaCodeAction",
      "TelescopePrompt",
      "NvimTree",
      "Trouble",
      "DiffviewFiles",
      "DiffviewFileHistory",
      "Outline",
      "lspinfo",
      "fugitive",
      "norg",
    },
    context_patterns = {
      "class", "return", "function", "method", "^if", "^while", "jsx_element",
      "^for", "^object", "^table", "block", "arguments", "if_statement",
      "else_clause", "jsx_element", "jsx_self_closing_element",
      "try_statement", "catch_clause", "import_statement"
    },
  })

  -- vim.cmd([[hi! IndentBlanklineContextChar guifg=fg]])
end
