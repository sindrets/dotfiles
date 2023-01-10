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
      ["core.norg.qol.toc"] = {},
      ['core.integrations.telescope'] = {},
      ['core.norg.concealer'] = {},
      ["core.export"] = {},
      ["core.norg.dirman"] = {
        config = {
          workspaces = {
            uni = "~/Documents/uni/notes",
          },
        },
      },
      ["core.norg.completion"] = {
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
