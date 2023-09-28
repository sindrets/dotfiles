return function ()
  local hooks = require("ibl.hooks")
  local hi = Config.common.hl.hi

  hooks.register(hooks.type.HIGHLIGHT_SETUP, vim.schedule_wrap(function()
    -- Remove `nocombine`
    hi(
      {
        "@ibl.indent.char.1",
        "@ibl.whitespace.char.1",
        "@ibl.scope.char.1",
        "@ibl.scope.underline.1",
      },
      { style = "NONE" }
    )
  end))

  require("ibl").setup({
    enabled = true,
    debounce = 200,
    indent = {
      char = "▏",
      tab_char = "▏",
      smart_indent_cap = true,
      highlight = "Whitespace",
    },
    scope = {
      enabled = true,
      char = "▏",
      show_start = false,
    },
    exclude = {
      bufttypes = {
        "terminal",
        "nofile",
      },
      filetypes = {
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
    },
  })
end
