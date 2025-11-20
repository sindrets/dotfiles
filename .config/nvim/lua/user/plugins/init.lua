local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local api = vim.api

local function conf(config_name)
  return require(string.format("user.plugins.%s", config_name))
end

--- Use local development version if it exists.
--- @param spec table|string
local function use_local(spec)
  local name

  if type(spec) ~= "table" then
    spec = { spec }
  end

  ---@cast spec table
  if spec.name then
    name = spec.name
  else
    name = spec[1]:match(".*/(.*)")
    name = name:gsub("%.git$", "")
  end

  local local_path = spec.local_path
    or vim.env.NVIM_LOCAL_PLUGINS
    or (vim.env.HOME .. "/Documents/dev/nvim/plugins")
  local path = local_path .. "/" .. name

  if vim.fn.isdirectory(path) == 1 then
    spec.dir = path
  end

  return spec
end

-- vim.g.did_load_filetypes = 1
-- vim.g.loaded_netrwPlugin = 1
vim.g.netrw_liststyle = 1
vim.g.netrw_sort_by = "exten"
vim.g.netrw_bufsettings = "noma nomod nonu nowrap ro nornu"

vim.g.markdown_fenced_languages = {
  "html",
  "python",
  "sh",
  "bash",
  "console=bash",
  "dosini",
  "ini=dosini",
  "lua",
  "cpp",
  "c++=cpp",
  "javascript",
  "java",
  "vim",
  "log",
}

---@diagnostic disable-next-line: different-requires
require("lazy").setup({
  use_local { "sindrets/imminent.nvim", lazy = false },

  -- SYNTAX & FILETYPE PLUGINS
  { "MTDL9/vim-log-highlighting" },
  { "kevinoid/vim-jsonc" },
  { "teal-language/vim-teal" },
  { "mboughaba/i3config.vim" },
  { "chrisbra/csv.vim" },
  { "fladson/vim-kitty" },
  { "joelbeedle/pseudo-syntax" },
  { "alisdair/vim-armasm" },
  {
    url = "https://codeberg.org/ldesousa/vim-turtle-syntax.git",
    build = "mkdir -p syntax && cp turtle.vim syntax",
  },
  {
    "pld-linux/vim-syntax-vcl",
    build = "mkdir -p syntax ftdetect && mv vcl.vim syntax/vcl.vim && mv ftdetect.vim ftdetect/vcl.vim",
  },
  { "lifepillar/pgsql.vim" },
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_open_on_warning = 0
      -- vim.g.vimtex_compiler_method = "latexrun"

      vim.g.vimtex_compiler_latexmk = {
        build_dir = '.tex',
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        hooks = {},
        options = {
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          -- [[-pdflatex=pdflatex --shell-escape  %O  %S]],
        },
      }
    end,
  },

  -- BEHAVIOUR
  {
    "antoinemadec/FixCursorHold.nvim",
    init = function()
      vim.g.cursorhold_updatetime = 250
    end,
  },
  {
    "Darazaki/indent-o-matic",
    commit = "bf37c6e",
    config = function()
      require("indent-o-matic").setup({
        -- Number of lines without indentation before giving up (-1 for infinite)
        max_lines = 2048,
        -- Space indentations that should be detected
        standard_widths = { 2, 3, 4, 8 },
        -- Skip multi-line comments and strings (more accurate detection but less performant)
        skip_multiline = true,
      })
    end,
  },
  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "nvim-tree/nvim-web-devicons",
    name = "nvim-web-devicons",
    config = conf("nvim-web-devicons"),
    lazy = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = conf("treesitter"),
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        max_lines = 2,
        zindex = 1,
        trim_scope = "inner",
        multiline_threshold = 300,
      })
    end,
    event = "VeryLazy",
  },
  use_local { "folke/neodev.nvim" },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {
          ui = { border = "single" },
        }
      },
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_enable = {
        exclude = {
          "ts_ls",
          "stylua",
          "lua_ls",
          "haxe_language_server",
        },
      },
    },
  },
  { "neovim/nvim-lspconfig" },
  {
    "stevearc/conform.nvim",
    config = conf("conform"),
    event = "VeryLazy",
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
  },
  {
    "anuvyklack/pretty-fold.nvim",
    config = conf("pretty-fold"),
    cond = function()
      -- NOTE: seems like some FFI stuff has broken here
      return vim.fn.has("nvim-0.10") ~= 1
    end
  },
  { "mfussenegger/nvim-jdtls" },
  use_local {
    "sindrets/blink.cmp",
    dependencies = {
      {
        "saghen/blink.compat",
        lazy = true,
        opts = {
          impersonate_nvim_cmp = false,
        },
        version = "*",
      },
      "rafamadriz/friendly-snippets",
      "ribru17/blink-cmp-spell",
    },

    -- use a release tag to download pre-built binaries
    -- version = "v0.*",
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    build = "cargo build --release",

    config = conf("blink-cmp"),

    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { "sources.default", "sources.providers" }
  },
  {
    "stevearc/oil.nvim",
    config = conf("oil"),
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    url = "https://gitlab.com/yorickpeterse/nvim-pqf.git",
    config = function()
      require("pqf").setup({
        signs = {
          error = "",
          warning = "",
          info = "",
          hint = "",
        }
      })
    end,
  },
  { "kevinhwang91/nvim-bqf", config = conf("nvim-bqf") },
  { "windwp/nvim-autopairs", config = conf("nvim-autopairs") },
  { "sindrets/nvim-colorizer.lua", config = conf("nvim-colorizer") },
  {
    "hrsh7th/vim-vsnip",
    init = function()
      vim.g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets"
    end,
  },
  { "hrsh7th/vim-vsnip-integ" },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },
  { "folke/snacks.nvim", priority = 1000, config = conf("snacks") },
  {
    "akinsho/bufferline.nvim",
    config = conf("bufferline"),
    dependencies = "nvim-web-devicons",
    event = "VimEnter",
  },
  {
    "mattn/emmet-vim",
    init = function ()
      vim.g.user_emmet_leader_key = "<C-Z>"
    end,
  },
  { "tpope/vim-abolish" },
  {
    "alvan/vim-closetag", init = function ()
      vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.xml,*.md,*.hbs,*.tsx,*.astro"
      vim.g.closetag_filetypes = "html,xhtml,phtml,xml,markdown,handlebars,typescriptreact,astro"
    end
  },
  { "Rasukarusan/nvim-block-paste" },
  { "godlygeek/tabular" },
  { "tpope/vim-surround" },
  { "bkad/CamelCaseMotion" },
  { "tweekmonster/startuptime.vim", cmd = { "StartupTime" } },
  { "RRethy/vim-illuminate", config = conf("vim-illuminate"), event = "VeryLazy" },
  { "troydm/zoomwintab.vim", cmd = { "ZoomWinTabIn", "ZoomWinTabOut", "ZoomWinTabToggle" } },
  {
    "rcarriga/nvim-notify",
    config = function()
      ---@diagnostic disable-next-line: different-requires
      local notify = require("notify") --[[@as table ]]
      notify.setup({
        max_width = 80,
        max_height = 15,
        top_down = false,
      })

      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, level, opts)
        opts = opts or {}
        notify(msg, level, vim.tbl_extend("force", opts, {
          on_open = function(winid)
            local bufid = api.nvim_win_get_buf(winid)
            -- vim.bo[bufid].filetype = "markdown"
            vim.wo[winid].conceallevel = 3
            vim.wo[winid].concealcursor = "n"
            vim.wo[winid].spell = false
            vim.treesitter.start(bufid, "markdown")

            if opts.on_open then
              opts.on_open(winid)
            end
          end,
        }))
      end
    end,
  },

  -- MISC
  {
    "feline-nvim/feline.nvim",
    config = conf("feline"),
    event = "VeryLazy",
  },
  use_local { "lewis6991/gitsigns.nvim", config = conf("gitsigns") },
  { "lukas-reineke/indent-blankline.nvim", config = conf("indent-blankline"), event = "VimEnter" },
  {
    "folke/trouble.nvim",
    config = conf("trouble"),
    dependencies = "nvim-web-devicons",
    cmd = { "Trouble" },
  },
  use_local { "sindrets/diffview.nvim", config = conf("diffview") },
  -- { "~/Documents/misc/diffview-api-test" },
  use_local { "sindrets/winshift.nvim", config = conf("winshift"), cmd = "WinShift" },
  use_local {
    "sindrets/view-tween.nvim",
    config = conf("view-tween"),
    cond = not vim.g.neovide,
  },
  use_local { "sindrets/scratchpad.nvim" },
  { "will133/vim-dirdiff" },
  {
    "hedyhli/outline.nvim",
    config = conf("outline"),
    cmd = { "Outline", "OutlineClose", "OutlineOpen" },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = conf("nvim-ts-rainbow"),
  },
  use_local {
    "sindrets/vim-fugitive",
    config = conf("fugitive"),
    init = function()
      vim.g.github_enterprise_urls = {
        "https://github.schibsted.io",
        "https://schibsted.ghe.com",
      }
    end,
    dependencies = {
      "tpope/vim-rhubarb",
      {
        "rbong/vim-flog",
        init = function()
          vim.g.flog_default_opts = { max_count = 512 }
          vim.g.flog_override_default_mappings = {}
          vim.g.flog_jumplist_default_mappings = {}
          vim.g.flog_use_internal_lua = true
          vim.g.flog_enable_extended_chars = true
          vim.g.flog_enable_dynamic_commit_hl = true
        end,
      },
    },
  },
  { "goolord/alpha-nvim", config = conf("alpha"), event = "VimEnter" },
  { "ryanoasis/vim-devicons" },
  {
    "OXY2DEV/markview.nvim",
    branch = "main",
    ft = "markdown",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("markview").setup({
        markdown = {
          code_blocks = {
            pad_amount = 0,
          },
          list_items = {
            indent_size = 2,
            shift_width = 2,
          },
        },
        preview = {
          modes = { "n", "i", "no", "c" },
          hybrid_modes = { "i" },
          callbacks = {
            on_enable = function (_, win)
              vim.api.nvim_win_call(win, function ()
                vim.opt_local.conceallevel = 3
                vim.opt_local.concealcursor = "nc"
              end)
            end,
          },
        },
      })
      require("markview.highlights").setup()
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    ft = { "markdown" },
    init = function ()
      api.nvim_exec2([[
        function! MkdpOpenInNewWindow(url)
          if executable("firefox")
            call jobstart([ "firefox", "--new-window", a:url ])
          elseif executable("firefox-beta")
            call jobstart([ "firefox-beta", "--new-window", a:url ])
          elseif executable("qutebrowser")
            call jobstart([ "qutebrowser", "--target", "window", a:url ])
          elseif executable("chromium")
            call jobstart([ "chromium", "--app=" . a:url ])
          else
            echoerr '[MKDP] No suitable browser!'
          endif
        endfunction
      ]], {})
      vim.g.mkdp_browserfunc = "MkdpOpenInNewWindow"
    end,
  },
  {
    "glacambre/firenvim",
    build = function() vim.fn["firenvim#install"](0) end,
    init = conf("firenvim"),
  },
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    config = true,
  },
  {
    "zk-org/zk-nvim",
    cmd = { "ZkNotes", "ZkNew", "ZkIndex" },
    config = function()
      local Path = require("imminent.fs.Path")
      local async = require("imminent")
      local pb = require("imminent.pebbles")

      async.job({
        "tomlq",
        "-r",
        ".notebook.dir",
        vim.env.HOME .. "/.config/zk/config.toml"
      })
        :await()
        :inspect(function(stdout)
          vim.env.ZK_NOTEBOOK_DIR = Path.from_str(pb.line(stdout, 1) or "")
            :unwrap()
            :absolute()
            :tostring()
        end)
        :inspect_err(function(stderr)
          Config.common.notify.error(
            string.format("Failed to get notebook dir:\n\n%s", stderr),
            { title = "zk" }
          )
        end)

      require("zk").setup({
        picker = "snacks_picker",
      })
    end,
  },
  use_local {
    "nvim-neorg/neorg",
    lazy = true,
    version = "*",
    config = conf("neorg"),
    -- build = ":Neorg sync-parsers",
    ft = "norg",
    cmd = { "Neorg" },
    dependencies = {
      "nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "luarocks.nvim",
    },
    cond = vim.fn.has("nvim-0.8") == 1,
  },
  { "xorid/asciitree.nvim", cmd = { "AsciiTree", "AsciiTreeUndo" } },
  { "echasnovski/mini.splitjoin", version = false, config = {} },
  {
    "ellisonleao/dotenv.nvim",
    config = {
      enable_on_load = true, -- will load your .env file upon loading a buffer
      verbose = false, -- show error notification if .env file is not found and if .env is loaded
    },
  },
  { "lambdalisue/suda.vim" },
  { "rest-nvim/rest.nvim" },

  -- COLOR SCHEMES
  { "rktjmp/lush.nvim", lazy = true },
  { "arzg/vim-colors-xcode" },
  { "sainnhe/gruvbox-material" },
  { "gruvbox-community/gruvbox" },
  { "folke/tokyonight.nvim" },
  { "sindrets/material.nvim" },
  { "sindrets/rose-pine-neovim", name = "rose-pine" },
  { "mcchrish/zenbones.nvim", dependencies = "rktjmp/lush.nvim" },
  { "sainnhe/everforest" },
  { "Cybolic/palenight.vim" },
  { "olimorris/onedarkpro.nvim", branch = "main" },
  { "NTBBloodbath/doom-one.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  use_local { "sindrets/dracula-vim", name = "dracula" },
  { "projekt0n/github-nvim-theme" },
  { "rebelot/kanagawa.nvim" },
  use_local { "sindrets/oxocarbon-lua.nvim" },
  {
    "AlexvZyl/nordic.nvim",
    opts = { cursorline = { hide_unfocused = false } },
  },
  { "Mofiqul/vscode.nvim" },
  { "kvrohit/rasmus.nvim" },
  -- Repo removed
  -- { "ferdinandrau/lavish.nvim" },
  { "mellow-theme/mellow.nvim" },
  { "wtfox/jellybeans.nvim" },
  { "cpwrs/americano.nvim" },
  { "dgox16/oldworld.nvim" },
  { "xeind/nightingale.nvim" },
}, {
  ui = {
    border = "single",
  },
  diff = {
    cmd = "diffview.nvim",
  },
  install = {
    -- colorscheme = { "nordic", "habamax" },
  }
})
