return function()
  local lz = require("user.lazy")
  local blink = require("blink.cmp")

  local utils = Config.common.utils
  local pb = Config.common.pb

  local fzy_sort = lz.require("blink.cmp.fuzzy.sort") --- @module "blink.cmp.fuzzy.sort"

  blink.setup({
    keymap = {
      preset = "default",

      ["<Cr>"] = { "accept", "fallback" },

      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<C-p>"] = { pb.bind(blink.select_prev, { auto_insert = true }), "show", "fallback" },
      ["<C-n>"] = { pb.bind(blink.select_next, { auto_insert = true }), "show", "fallback" },

      ["<C-b>"] = { "snippet_backward", "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "snippet_forward", "scroll_documentation_down", "fallback" },

      ["<Tab>"] = {},
      ["<S-Tab>"] = {},
      ["<C-k>"] = {},
    },
    completion = {
      -- "prefix" will fuzzy match on the text before the cursor
      -- "full" will fuzzy match on the text before *and* after the cursor
      -- example: "foo_|_bar" will match "foo_" for "prefix" and "foo__bar" for "full"
      keyword = { range = "full" },

      -- Disable auto brackets
      -- NOTE: some LSPs may add auto brackets themselves anyway
      accept = {
        auto_brackets = { enabled = true },
      },

      -- Insert completion item on selection, don"t select by default
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },

      menu = {
        enabled = true,
        min_width = 15,
        max_height = 10,
        border = "none",
        winblend = 0,
        winhighlight = "Normal:BlinkCmpMenu,CursorLine:BlinkCmpMenuSelection,Search:None",
        -- Keep the cursor X lines away from the top/bottom of the window
        scrolloff = 2,
        -- Note that the gutter will be disabled when border ~= "none"
        scrollbar = true,
        -- Which directions to show the window,
        -- falling back to the next direction when there"s not enough space
        direction_priority = { "s", "n" },

        -- Whether to automatically show the window when new completion items are available
        auto_show = true,

        -- nvim-cmp style menu
        draw = {
          columns = {
            { "space", "kind_icon", "space" },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
          components = {
            space = {
              text = function() return " " end,
            },
            source_name = {
              width = { max = 30 },
              text = function(ctx) return string.format("[%s]", ctx.source_name) end,
              highlight = "BlinkCmpSource",
            },
          },
        },
      },

      -- Show documentation when selecting a completion item
      documentation = {
        auto_show = true,
        -- Delay before showing the documentation window
        auto_show_delay_ms = 250,
        -- Delay before updating the documentation window when selecting a new item,
        -- while an existing item is still visible
        update_delay_ms = 50,

        window = {
          min_width = 10,
          max_width = 80,
          max_height = 20,
          border = "single",
          winblend = 0,
          winhighlight = "Normal:BlinkCmpDoc,CursorLine:BlinkCmpDocCursorLine,Search:None",
          -- Note that the gutter will be disabled when border ~= 'none'
          scrollbar = true,
          -- Which directions to show the documentation window,
          -- for each of the possible menu window directions,
          -- falling back to the next direction when there's not enough space
          direction_priority = {
            menu_north = { "e", "w", "n", "s" },
            menu_south = { "e", "w", "s", "n" },
          },
        },
      },

      -- Display a preview of the selected item on the current line
      ghost_text = { enabled = false },
    },

    sources = {
      -- Remove "buffer" if you don"t want text completions, by default it"s only enabled when LSP returns no items
      default = {
        "lsp",
        "path",
        "snippets",
        "spell",
        "buffer",
      },

      providers = {
        lsp = {
          name = "LSP",
          score_offset = 500,
          module = "blink.cmp.sources.lsp",
          fallbacks = {},
        },
        path = {
          score_offset = 400,
        },
        snippets = {
          score_offset = 300,
        },
        spell = {
          name = "Spell",
          score_offset = 200,
          module = "blink-cmp-spell",
          opts = {
            max_entries = 20,
          },
        },
        buffer = {
          name = "Buffer",
          module = "blink.cmp.sources.buffer",
          score_offset = 100,
          opts = {
            max_items = 20,
            get_bufnrs = function()
              return pb
                .iter(utils.list_bufs({ no_unlisted = true }))
                :chain(utils.list_bufs({ no_hidden = true }))
                :unique()
                :filter(function(bufnr) return utils.buf_get_size(bufnr) < 1024 end)
                :totable()
            end,
          },
        },
      },
    },

    cmdline = {
      -- Disable cmdline completions
      sources = {},
    },

    fuzzy = {
      sorts = {
        function(a, b)
          if a.source_id == "spell" and b.source_id == "spell" then
            -- use the label sorter as the primary sorter for the "spell" source
            return fzy_sort.label(a, b)
          end
        end,
        "score",
        "sort_text",
      },
    },

    -- Experimental signature help support
    signature = {
      enabled = true,

      window = {
        min_width = 1,
        max_width = 100,
        max_height = 10,
        border = "single",
        winblend = 0,
        winhighlight = "Normal:BlinkCmpSignatureHelp",
        scrollbar = false, -- Note that the gutter will be disabled when border ~= 'none'
        -- Which directions to show the window,
        -- falling back to the next direction when there's not enough space,
        -- or another window is in the way
        direction_priority = { "n", "s" },
        -- Disable if you run into performance issues
        treesitter_highlighting = true,
      },
    },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'normal',
      kind_icons = {
        Method = "",
        Function = "ƒ",
        Variable = "",
        Field = "",
        TypeParameter = "",
        Constant = "",
        Class = "",
        Interface = "",
        Struct = "",
        Event = "",
        Operator = "󰆕",
        Module = "󰅩",
        Property = "",
        Enum = "",
        Reference = "",
        Keyword = "",
        File = "",
        Folder = "󰝰",
        Color = "",
        Unit = "󰑭",
        Snippet = "",
        Text = "",
        Constructor = "",
        Value = "󰎠",
        EnumMember = "",
      },
    },
  })
end
