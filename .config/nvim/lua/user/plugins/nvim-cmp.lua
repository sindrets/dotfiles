return function()
  local cmp = require("cmp")
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  local utils = Config.common.utils

  local lsp_kinds = {
    Method = "  ",
    Function = " ƒ ",
    Variable = "  ",
    Field = "  ",
    TypeParameter = "  ",
    Constant = "  ",
    Class = "  ",
    Interface = "  ",
    Struct = "  ",
    Event = "  ",
    Operator = " 󰆕 ",
    Module = " 󰅩 ",
    Property = "  ",
    Enum = "  ",
    Reference = "  ",
    Keyword = "  ",
    File = "  ",
    Folder = " 󰝰 ",
    Color = "  ",
    Unit = " 󰑭 ",
    Snippet = "  ",
    Text = "  ",
    Constructor = "  ",
    Value = " 󰎠 ",
    EnumMember = "  "
  }

  -- Prevent event listeners from stacking whenever packer reloads the config.
  cmp.event:clear()

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
      ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
    }),
    formatting = {
      deprecated = true,
      fields = { "kind", "abbr", "menu" },
      format = function(entry, vim_item)
        vim_item.kind = lsp_kinds[vim_item.kind]
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          emoji = "[Emoji]",
          path = "[Path]",
          calc = "[Calc]",
          neorg = "[Neorg]",
          orgmode = "[Org]",
          luasnip = "[Luasnip]",
          buffer = "[Buffer]",
          spell = "[Spell]",
          git = "[VCS]",
        })[entry.source.name]
        return vim_item
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      documentation = {
        border = "single",
        winhighlight = "Normal:Normal,CursorLine:Visual,Search:None",
        zindex = 1001
      },
    },
    sources = {
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "vsnip" },
      { name = "neorg" },
      { name = "git" },
      { name = "spell" },
      { name = "path" },
      {
        name = "buffer",
        max_item_count = 20,
        option = {
          get_bufnrs = function()
            return vim.tbl_filter(
              function(bufnr) return utils.buf_get_size(bufnr) < 1024 end,
              pb.iter(utils.list_bufs({ no_unlisted = true }))
                :chain(utils.list_bufs({ no_hidden = true }))
                :unique()
                :totable()
            )
          end,
        },
      },
    },
    -- sorting = {
    --   comparators = {
    --     function(...) return cmp_buffer:compare_locality(...) end,
    --   },
    -- },
  })

  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

  -- cmp.setup.cmdline(":", {
  --   mapping = cmp.mapping.preset.cmdline({}),
  --   sources = cmp.config.sources(
  --     {
  --       { name = "path" },
  --     }, {
  --       { name = "cmdline" },
  --     }
  --   ),
  -- })

  require("cmp_git").setup({
    filetypes = { "gitcommit", "NeogitCommitMessage", "markdown", "octo" },
  })
end
