return function()
  require("neorg").setup({
    load = {
      ["core.defaults"] = {
        config = {
          disable = {
            "core.norg.esupports.indent",
          },
        },
      },
      ["core.qol.toc"] = {},
      ['core.integrations.telescope'] = {},
      ['core.concealer'] = {},
      ["core.export"] = {},
      ["core.dirman"] = {
        config = {
          workspaces = {
            uni = "~/Documents/uni/notes",
            default = "~/Documents/notes",
          },
        },
      },
      ["core.completion"] = {
        config = {
          engine = "nvim-cmp",
        },
      },
      -- GTD has been removed
      -- ['core.gtd.base'] = {
      --   config = {
      --     workspace = 'uni',
      --   },
      -- },
    },
  })
end
