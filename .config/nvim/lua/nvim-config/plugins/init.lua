vim.cmd("packadd packer.nvim")

local function conf(config_name)
  return require(string.format("nvim-config.plugins.%s", config_name))
end

local function wrap_local(spec)
  local name

  if type(spec) ~= "table" then
    spec = { spec }
  end

  ---@cast spec table
  if spec.as then
    name = spec.as
  else
    name = spec[1]:match(".*/(.*)")
    name = name:gsub("%.git$", "")
  end

  local local_path = spec.local_path
    or vim.env.PACKER_LOCAL_PATH
    or (vim.env.HOME .. "/Documents/dev/nvim/plugins")
  local path = local_path .. "/" .. name
  if vim.fn.isdirectory(path) == 0 then
    path = spec[1]
  end

  spec[1] = path

  return spec
end

---Use local development version if it exists.
---NOTE: Remember to run `:PackerClean :PackerInstall` to update symlinks.
---@param spec table|string
local function use_local(spec)
  local use = require("packer").use
  use(wrap_local(spec))
end

return require('packer').startup({
  ---@diagnostic disable-next-line: unused-local
  function (use, use_rocks)

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

    -- vim.cmd([[runtime! ftdetect/*.vim]])
    -- vim.cmd([[runtime! ftdetect/*.lua]])

    use 'wbthomason/packer.nvim'

    use 'lewis6991/impatient.nvim'

    -- SYNTAX
    use { 'MTDL9/vim-log-highlighting' }
    use { 'kevinoid/vim-jsonc' }
    use { 'teal-language/vim-teal' }
    use { 'mboughaba/i3config.vim' }
    use { "chrisbra/csv.vim" }

    -- BEHAVIOUR
    use {
      'antoinemadec/FixCursorHold.nvim',
      setup = function()
        vim.g.cursorhold_updatetime = 250
      end
    }
    -- use { 'nathom/filetype.nvim' }
    use {
      'Darazaki/indent-o-matic',
      config = function()
        require("indent-o-matic").setup({
          -- Number of lines without indentation before giving up (use -1 for infinite)
          max_lines = 2048,
          -- Space indentations that should be detected
          standard_widths = { 2, 3, 4, 8 },
        })
      end,
    }
    use { 'nvim-lua/popup.nvim' }
    use { 'nvim-lua/plenary.nvim' }
    use { 'kyazdani42/nvim-web-devicons', config = conf("nvim-web-devicons") }
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf("treesitter"),
    }
    use { 'nvim-treesitter/playground', requires = "nvim-treesitter/nvim-treesitter" }
    use {
      'lewis6991/spellsitter.nvim', config = function()
        require('spellsitter').setup {
          -- Whether enabled, can be a list of filetypes, e.g. {'python', 'lua'}
          enabled = true
        }
      end
    }
    use { 'folke/lua-dev.nvim' }
    use { 'neovim/nvim-lspconfig' }
    use {
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
      end
    }
    use { 'mfussenegger/nvim-jdtls' }
    use {
      'hrsh7th/nvim-cmp',
      requires = {
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'f3fora/cmp-spell' },
        { 'hrsh7th/cmp-path' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-vsnip' },
        { 'hrsh7th/cmp-cmdline' },
        { 'petertriho/cmp-git' },
      },
      after = 'nvim-autopairs',
      config = conf("nvim-cmp"),
    }
    use_local {
      'tamago324/lir.nvim',
      requires = { wrap_local('tamago324/lir-git-status.nvim') },
      config = conf("lir"),
      after = "nvim-web-devicons",
    }
    use {
      'https://gitlab.com/yorickpeterse/nvim-pqf.git',
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
    }
    use { 'kevinhwang91/nvim-bqf', config = conf("nvim-bqf") }
    use { 'windwp/nvim-autopairs', config = conf("nvim-autopairs") }
    use { 'sindrets/nvim-colorizer.lua', config = conf("nvim-colorizer") }
    use {
      'hrsh7th/vim-vsnip',
      setup = function()
        vim.g.vsnip_snippet_dir = vim.fn.stdpath("config") .. "/snippets"
      end,
    }
    use { 'hrsh7th/vim-vsnip-integ' }
    use {
      'scrooloose/nerdcommenter',
      setup = function ()
        vim.g.NERDSpaceDelims = 1
        vim.g.NERDDefaultAlign = "left"
      end
    }
    use { 'nvim-telescope/telescope.nvim', config = conf("telescope"), after = "nvim-web-devicons" }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use { 'nvim-telescope/telescope-media-files.nvim' }
    use { 'nvim-telescope/telescope-ui-select.nvim' }
    use { 'akinsho/nvim-bufferline.lua', config = conf("nvim-bufferline"), after = "nvim-web-devicons" }
    use {
      'karb94/neoscroll.nvim',
      config = conf("neoscroll"),
      cond = vim.g.neovide or vim.g.nvui
    }
    use { 'windwp/nvim-spectre', config = conf("spectre"), after = "nvim-web-devicons" }
    use { 'mileszs/ack.vim' }
    use { 'mattn/emmet-vim', setup = function ()
      vim.g.user_emmet_leader_key = "<C-Z>"
    end }
    use { 'tpope/vim-abolish' }
    use { 'alvan/vim-closetag', setup = function ()
      vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.xml,*.md"
      vim.g.closetag_filetypes = "html,xhtml,phtml,xml,markdown"
    end }
    use { 'Rasukarusan/nvim-block-paste' }
    use { 'godlygeek/tabular' }
    use { 'tpope/vim-surround' }
    use { "tweekmonster/startuptime.vim" }
    use {
      'RRethy/vim-illuminate',
      setup = function()
        vim.g.Illuminate_delay = 250
        vim.g.Illuminate_highlightUnderCursor = 1
        vim.g.Illuminate_ftblacklist = {
          "qf",
          "dashboard",
          "alpha",
          "packer",
          "NeogitStatus",
          "TelescopePrompt",
          "NvimTree",
          "Trouble",
          "DiffviewFiles",
          "DiffviewFileHistory",
          "Outline",
          "lir",
          "fugitive",
        }
      end
    }
    use { 'troydm/zoomwintab.vim' }
    use {
      'rcarriga/nvim-notify',
      config = function()
        require("notify").setup({})
        vim.notify = require("notify")
      end,
    }

    -- MISC
    use { 'feline-nvim/feline.nvim', config = conf("feline") }
    use { 'b0o/incline.nvim', config = conf("incline"), after = "nvim-web-devicons" }
    use { 'lewis6991/gitsigns.nvim', config = conf("gitsigns") }
    use_local { 'lukas-reineke/indent-blankline.nvim', setup = conf("indent-blankline") }
    use {
      'folke/lsp-trouble.nvim',
      config = conf("lsp-trouble"), after = "nvim-web-devicons",
    }
    use_local { 'sindrets/diffview.nvim', config = conf("diffview") }
    -- use { '~/Documents/misc/diffview-api-test' }
    use_local { 'sindrets/winshift.nvim', config = conf("winshift") }
    use_local {
      'TimUntersberger/neogit',
      config = conf("neogit"),
      requires = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    }
    use {
      'simrat39/symbols-outline.nvim',
      setup = conf("symbols-outline"),
      cmd = { "SymbolsOutline", "SymbolsOutlineClose", "SymbolsOutlineOpen" },
    }
    use {
      'p00f/nvim-ts-rainbow',
      requires = { 'nvim-treesitter/nvim-treesitter' },
      config = conf("nvim-ts-rainbow")
    }
    use {
      'tpope/vim-fugitive',
      requires = { 'tpope/vim-rhubarb', },
    }
    use {
      'akinsho/git-conflict.nvim',
      config = function()
        require("git-conflict").setup({
          default_mappings = true, -- disable buffer local mapping created by this plugin
          disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
          highlights = { -- They must have background color, otherwise the default color will be used
            incoming = 'DiffChange',
            current = 'DiffAdd',
          },
        })
      end
    }
    use { 'goolord/alpha-nvim', config = conf("alpha") }
    use { 'ryanoasis/vim-devicons' }
    use {
      'iamcco/markdown-preview.nvim',
      run = 'cd app && yarn install',
      setup = function ()
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
      end
    }
    use {
      'glacambre/firenvim',
      run = function() vim.fn['firenvim#install'](0) end,
      setup = conf("firenvim"),
    }
    use { 'honza/vim-snippets' }

    -- THEMES
    use { 'rktjmp/lush.nvim' }
    use { 'arzg/vim-colors-xcode' }
    use { 'sainnhe/gruvbox-material' }
    use { 'gruvbox-community/gruvbox' }
    use { 'folke/tokyonight.nvim' }
    use { 'sindrets/material.nvim' }
    use { 'sindrets/rose-pine-neovim', as = 'rose-pine' }
    use { 'mcchrish/zenbones.nvim', requires = 'rktjmp/lush.nvim' }
    use { 'sainnhe/everforest' }
    use { 'Cybolic/palenight.vim' }
    use { 'olimorris/onedarkpro.nvim', branch = 'main' }
    use { 'NTBBloodbath/doom-one.nvim' }
    use { 'catppuccin/nvim', as = "catppuccin" }
    use_local { 'sindrets/dracula-vim', as = "dracula" }
    use { 'projekt0n/github-nvim-theme' }
    use { 'rebelot/kanagawa.nvim' }
  end,

  config = {
    snapshot_path = vim.fn.stdpath("config"),
    display = {
      open_cmd = 'vnew \\[packer\\] | wincmd L | vert resize 65',
    },
  },
})
