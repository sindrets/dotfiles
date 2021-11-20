return function()
  local cmp = require('cmp')
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp_buffer = require("cmp_buffer")

  local lsp_kinds = {
    Method = "  ",
    Function = "  ",
    Variable = "[]",
    Field = "  ",
    TypeParameter = "<>",
    Constant = "  ",
    Class = "  ",
    Interface = " 蘒",
    Struct = "  ",
    Event = "  ",
    Operator = "  ",
    Module = "  ",
    Property = "  ",
    Enum = " 練 ",
    Reference = "  ",
    Keyword = "  ",
    File = "  ",
    Folder = " ﱮ ",
    Color = "  ",
    Unit = " 塞 ",
    Snippet = "  ",
    Text = "  ",
    Constructor = "  ",
    Value = "  ",
    EnumMember = "  "
  }

  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
    },
    formatting = {
      deprecated = true,
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, vim_item)
        vim_item.kind = lsp_kinds[vim_item.kind]
        vim_item.menu = ({
          nvim_lsp = '[LSP]',
          nvim_lua = '[Lua]',
          emoji = '[Emoji]',
          path = '[Path]',
          calc = '[Calc]',
          neorg = '[Neorg]',
          orgmode = '[Org]',
          luasnip = '[Luasnip]',
          buffer = '[Buffer]',
          spell = '[Spell]',
        })[entry.source.name]
        return vim_item
      end,
    },
    documentation = {
      border = 'single',
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
      { name = 'spell' },
      { name = 'path' },
      {
        name = 'buffer',
        get_bufnrs = function()
          local buf_map = {}
          for _, winid in ipairs(vim.api.nvim_list_wins()) do
            buf_map[vim.api.nvim_win_get_buf(winid)] = true
          end
          return vim.tbl_keys(buf_map)
        end
      },
    },
    -- sorting = {
    --   comparators = {
    --     function(...) return cmp_buffer:compare_locality(...) end,
    --   },
    -- },
  })

  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

  -- cmp.setup.cmdline(':', {
  --   completion = {
  --     autocomplete = false,
  --   },
  --   sources = {
  --     { name = 'cmdline' }
  --   }
  -- })
end
