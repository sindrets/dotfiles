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

local function conf(config_name)
  return require(string.format("user.plugins.%s", config_name))
end

---Use local development version if it exists.
---NOTE: Remember to run `:PackerClean :PackerInstall` to update symlinks.
---@param spec table|string
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
  "bash=sh",
  "dosini",
  "ini=dosini",
  "lua",
  "cpp",
  "c++=cpp",
  "javascript",
  "java",
  "vim",
}

---@diagnostic disable-next-line: different-requires
require("lazy").setup({
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
    "kyazdani42/nvim-web-devicons",
    name = "nvim-web-devicons",
    config = conf("nvim-web-devicons"),
    lazy = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = conf("treesitter"),
  },
  { "nvim-treesitter/playground", dependencies = "nvim-treesitter/nvim-treesitter" },
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
  use_local { "sindrets/lua-dev.nvim" },
  { "neovim/nvim-lspconfig" },
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = conf("null-ls"),
    lazy = true,
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require("lsp_signature").setup({
        hint_enable = false,
        hint_prefix = "● ",
        max_width = 80,
        max_height = 12,
        handler_opts = {
          border = "single"
        }
      })
    end,
  },
  {
    "anuvyklack/pretty-fold.nvim",
    config = conf("pretty-fold"),
  },
  { "mfussenegger/nvim-jdtls" },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/cmp-cmdline" },
      { "f3fora/cmp-spell" },
      { "petertriho/cmp-git" },
      "nvim-autopairs",
    },
    config = conf("nvim-cmp"),
  },
  use_local {
    "tamago324/lir.nvim",
    dependencies = { use_local("tamago324/lir-git-status.nvim"), "nvim-web-devicons" },
    config = conf("lir"),
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
    "scrooloose/nerdcommenter",
    init = function ()
      vim.g.NERDSpaceDelims = 1
      vim.g.NERDDefaultAlign = "left"
    end,
  },
  { "nvim-telescope/telescope.nvim", config = conf("telescope"), dependencies = "nvim-web-devicons" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { "nvim-telescope/telescope-media-files.nvim" },
  { "nvim-telescope/telescope-ui-select.nvim" },
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
      vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.xml,*.md"
      vim.g.closetag_filetypes = "html,xhtml,phtml,xml,markdown"
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
      vim.notify = require("notify")
      vim.notify.setup({
        max_width = 80,
        max_height = 15,
        top_down = false,
      })
    end,
  },

  -- MISC
  { "feline-nvim/feline.nvim", config = conf("feline"), event = "VeryLazy" },
  use_local { "lewis6991/gitsigns.nvim", config = conf("gitsigns") },
  { "lukas-reineke/indent-blankline.nvim", config = conf("indent-blankline"), event = "VimEnter" },
  {
    "folke/lsp-trouble.nvim",
    config = conf("lsp-trouble"),
    dependencies = "nvim-web-devicons",
    lazy = true,
  },
  use_local { "sindrets/diffview.nvim", config = conf("diffview") },
  -- { "~/Documents/misc/diffview-api-test" },
  use_local { "sindrets/winshift.nvim", config = conf("winshift"), cmd = "WinShift" },
  use_local { "sindrets/view-tween.nvim", config = conf("view-tween") },
  use_local { "sindrets/scratchpad.nvim" },
  {
    "simrat39/symbols-outline.nvim",
    config = conf("symbols-outline"),
    cmd = { "SymbolsOutline", "SymbolsOutlineClose", "SymbolsOutlineOpen" },
  },
  {
    "p00f/nvim-ts-rainbow",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = conf("nvim-ts-rainbow"),
  },
  use_local {
    "sindrets/vim-fugitive",
    dependencies = {
      "tpope/vim-rhubarb",
      {
        "rbong/vim-flog",
        init = function()
          vim.g.flog_default_opts = { max_count = 512 }
          vim.g.flog_override_default_mappings = {}
          vim.g.flog_jumplist_default_mappings = {}
          vim.g.flog_use_internal_lua = true
        end,
      },
    },
    config = conf("fugitive"),
  },
  { "goolord/alpha-nvim", config = conf("alpha"), event = "VimEnter" },
  { "ryanoasis/vim-devicons" },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    ft = { "markdown" },
    init = function ()
      vim.api.nvim_exec([[
        function! MkdpOpenInNewWindow(url)
          if executable("qutebrowser")
            call jobstart([ "qutebrowser", "--target", "window", a:url ])
          elseif executable("chromium")
            call jobstart([ "chromium", "--app=" . a:url ])
          elseif executable("firefox")
            call jobstart([ "firefox", "--new-window", a:url ])
          else
            echoerr '[MKDP] No suitable browser!'
          endif
        endfunction
        ]], false)
      vim.g.mkdp_browserfunc = "MkdpOpenInNewWindow"
    end,
  },
  {
    "glacambre/firenvim",
    build = function() vim.fn["firenvim#install"](0) end,
    init = conf("firenvim"),
  },
  { "honza/vim-snippets" },
  {
    "nvim-neorg/neorg",
    config = conf("neorg"),
    dependencies = {
      "nvim-treesitter",
      "telescope.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neorg/neorg-telescope"
    },
    cond = vim.fn.has("nvim-0.8") ~= 1,
  },
  { "xorid/asciitree.nvim", cmd = { "AsciiTree", "AsciiTreeUndo" } },

  -- COLOR SCHEMES
  { "rktjmp/lush.nvim", lazy = true },
  { "arzg/vim-colors-xcode", lazy = true },
  { "sainnhe/gruvbox-material", lazy = true },
  { "gruvbox-community/gruvbox", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
  { "sindrets/material.nvim", lazy = true },
  { "sindrets/rose-pine-neovim", name = "rose-pine", lazy = true },
  { "mcchrish/zenbones.nvim", dependencies = "rktjmp/lush.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  { "Cybolic/palenight.vim", lazy = true },
  { "olimorris/onedarkpro.nvim", branch = "main", lazy = true },
  { "NTBBloodbath/doom-one.nvim", lazy = true },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  use_local { "sindrets/dracula-vim", name = "dracula", lazy = true },
  { "projekt0n/github-nvim-theme", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  use_local { "sindrets/oxocarbon-lua.nvim", lazy = true },
  {
    "AlexvZyl/nordic.nvim",
    opts = { cursorline = { hide_unfocused = false } },
    lazy = true,
  },
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
