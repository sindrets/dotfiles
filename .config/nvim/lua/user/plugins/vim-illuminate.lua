return function()
  require("illuminate").configure({
    -- providers: provider used to get references in the buffer, ordered by priority
    providers = {
      "lsp",
      "treesitter",
      "regex",
    },
    -- delay: delay in milliseconds
    delay = 250,
    -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
    filetypes_denylist = {
      "dirvish",
      "fugitive",
      "qf",
      "dashboard",
      "alpha",
      "packer",
      "NeogitStatus",
      "NeogitCommitView",
      "TelescopePrompt",
      "NvimTree",
      "Trouble",
      "DiffviewFiles",
      "DiffviewFileHistory",
      "Outline",
      "lir",
    },
    -- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
    filetypes_allowlist = {},
    -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
    modes_denylist = {
      "nt",  -- Normal in |terminal-emulator| (insert goes to Terminal mode)
      "v",   -- Visual by character
      "vs",  -- Visual by character using |v_CTRL-O| in Select mode
      "V",   -- Visual by line
      "Vs",  -- Visual by line using |v_CTRL-O| in Select mode
      "",  -- Visual blockwise
      "s", -- Visual blockwise using |v_CTRL-O| in Select mode
      "s",   -- Select by character
      "S",   -- Select by line
      "",  -- Select blockwise
      "i",   -- Insert
      "ic",  -- Insert mode completion |compl-generic|
      "ix",  -- Insert mode |i_CTRL-X| completion
      "R",   -- Replace |R|
      "Rc",  -- Replace mode completion |compl-generic|
      "Rx",  -- Replace mode |i_CTRL-X| completion
      "Rv",  -- Virtual Replace |gR|
      "Rvc", -- Virtual Replace mode completion |compl-generic|
      "Rvx", -- Virtual Replace mode |i_CTRL-X| completion
      "t",   -- Terminal mode: keys go to the job
    },
    -- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
    modes_allowlist = {},
    -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
    -- Only applies to the "regex" provider
    -- Use :echom synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name")
    providers_regex_syntax_denylist = {},
    -- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
    -- Only applies to the "regex" provider
    -- Use :echom synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name")
    providers_regex_syntax_allowlist = {},
    -- under_cursor: whether or not to illuminate under the cursor
    under_cursor = true,
  })
end
