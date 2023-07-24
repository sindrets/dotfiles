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
      ["core.ui.calendar"] = (vim.fn.has("nvim-0.10") == 1) and {} or nil,
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
      ["core.journal"] = {
        config = {
          workspace = "default",
          -- toc_format = function(entry)
          --   print(vim.inspect(entry))
          -- end,
        },
      },
      ["core.neorgcmd"] = {
        config = {
          load = { "core.journal" },
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
