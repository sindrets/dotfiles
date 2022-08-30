return function()
  require("neorg").setup({
    load = {
      ["core.defaults"] = {},
      ['core.integrations.telescope'] = {},
      ['core.norg.concealer'] = {},
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
    },
    ['core.gtd.base'] = {
      config = {
        workspace = 'uni',
      },
    },
  })
end
