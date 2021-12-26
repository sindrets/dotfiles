vim.cmd("packadd packer.nvim")

local function conf(config_name)
  return require(string.format("nvim-config.plugins.%s", config_name))
end

return require'packer'.startup {
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

    -- SYNTAX
    use { 'MTDL9/vim-log-highlighting' }
    use { 'kevinoid/vim-jsonc' }
    use { 'teal-language/vim-teal' }
    use { 'mboughaba/i3config.vim' }

    -- BEHAVIOUR
    use {
      'antoinemadec/FixCursorHold.nvim',
      setup = function()
        vim.g.cursorhold_updatetime = 250
      end
    }
    -- use { 'nathom/filetype.nvim' }
    use { 'Darazaki/indent-o-matic' }
    use { 'nvim-lua/popup.nvim' }
    use { 'nvim-lua/plenary.nvim' }
    use { 'kyazdani42/nvim-web-devicons', config = conf("nvim-web-devicons") }
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf("treesitter"),
    }
    use { 'nvim-treesitter/playground', requires = "nvim-treesitter/nvim-treesitter" }
    -- use {
    --   'lewis6991/spellsitter.nvim', config = function()
    --     require('spellsitter').setup {
    --       hl = 'SpellBad',
    --       captures = {'comment'},  -- set to {} to spellcheck everything
    --     }
    --   end
    -- }
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
      },
      after = 'nvim-autopairs',
      config = conf("nvim-cmp"),
    }
    use {
      'tamago324/lir.nvim',
      requires = { 'tamago324/lir-git-status.nvim' },
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
    use { 'windwp/nvim-autopairs', config = conf("nvim-autopairs") }
    use { 'norcalli/nvim-colorizer.lua', config = conf("nvim-colorizer") }
    use { 'hrsh7th/vim-vsnip' }
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
      vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.xml"
      vim.g.closetag_filetypes = "html,xhtml,phtml,xml"
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
          "packer",
          "NeogitStatus",
          "TelescopePrompt",
          "NvimTree",
          "Trouble",
          "DiffviewFiles",
          "DiffviewFileHistory",
          "Outline",
          "lir",
        }
      end
    }

    -- MISC
    use { 'feline-nvim/feline.nvim', config = conf("feline") }
    use { 'lewis6991/gitsigns.nvim', config = conf("gitsigns") }
    use { 'lukas-reineke/indent-blankline.nvim', setup = conf("indent-blankline") }
    use { 'folke/lsp-trouble.nvim', config = conf("lsp-trouble"), after = "nvim-web-devicons" }
    use { 'sindrets/diffview.nvim', config = conf("diffview"), after = "nvim-web-devicons" }
    -- use { 'sindrets/diffview-api-test' }
    use { 'sindrets/winshift.nvim', config = conf("winshift") }
    use {
      'TimUntersberger/neogit',
      config = conf("neogit"),
      requires = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    }
    use { 'simrat39/symbols-outline.nvim', setup = conf("symbols-outline") }
    use {
      'p00f/nvim-ts-rainbow',
      requires = { 'nvim-treesitter/nvim-treesitter' },
      config = conf("nvim-ts-rainbow")
    }
    use { 'tpope/vim-fugitive' }
    -- use {
    --   'rhysd/conflict-marker.vim',
    --   setup = function ()
    --     vim.g.conflict_marker_begin = '^<<<<<<< .*$'
    --     vim.g.conflict_marker_common_ancestors = '^||||||| .*$'
    --     vim.g.conflict_marker_separator = '^=======$'
    --     vim.g.conflict_marker_end   = '^>>>>>>> .*$'
    --     vim.g.conflict_marker_highlight_group = ''
    --     vim.api.nvim_exec([[
    --       hi! link ConflictMarkerBegin DiffAdd
    --       hi! link ConflictMarkerOurs DiffAdd
    --       hi! link ConflictMarkerCommonAncestors DiffText
    --       hi! link ConflictMarkerCommonAncestorsHunk DiffText
    --       hi! link ConflictMarkerSeparator DiffText
    --       hi! link ConflictMarkerTheirs DiffChange
    --       hi! link ConflictMarkerEnd DiffText
    --     ]], false)
    --   end
    -- }
    use { 'glepnir/dashboard-nvim', setup = conf("dashboard") }
    use { 'ryanoasis/vim-devicons' }
    use {
      'iamcco/markdown-preview.nvim',
      run = 'cd app && yarn install',
      setup = function ()
        vim.api.nvim_exec([[
          function! MkdpOpenInNewWindow(url)
            lua require'nvim-config.lib'.mkdp_open_in_new_window(vim.fn.eval("a:url"))
          endfunction
          ]], false)
        vim.g.mkdp_browserfunc = "MkdpOpenInNewWindow"
      end
    }
    use { 'honza/vim-snippets' }

    -- THEMES
    use { 'rktjmp/lush.nvim' }
    use { 'rakr/vim-one' }
    use { 'ayu-theme/ayu-vim' }
    use { 'phanviet/vim-monokai-pro' }
    use { 'tomasiser/vim-code-dark' }
    use { 'w0ng/vim-hybrid' }
    use { 'nanotech/jellybeans.vim' }
    use { 'cocopon/iceberg.vim' }
    use { 'junegunn/seoul256.vim' }
    use { 'arzg/vim-colors-xcode' }
    use { 'haishanh/night-owl.vim' }
    use { 'KeitaNakamura/neodark.vim' }
    use { 'dim13/smyck.vim' }
    use { 'barlog-m/oceanic-primal-vim', branch = 'main', }
    use { 'jacoborus/tender.vim' }
    use { 'ntk148v/vim-horizon' }
    use { 'ajh17/Spacegray.vim' }
    use { 'sainnhe/gruvbox-material' }
    use { 'gruvbox-community/gruvbox' }
    use { 'kjssad/quantum.vim' }
    use { 'juanedi/predawn.vim' }
    use { 'glepnir/zephyr-nvim' }
    use { 'folke/tokyonight.nvim' }
    use { 'Mofiqul/dracula.nvim' }
    use { 'sindrets/material.nvim' }
    use { 'sindrets/rose-pine-neovim', as = 'rose-pine' }
    use { 'mcchrish/zenbones.nvim', requires = 'rktjmp/lush.nvim' }
    use { 'sainnhe/everforest' }
    use { 'Cybolic/palenight.vim' }
    use { 'olimorris/onedarkpro.nvim', branch = 'main' }
    use { 'RRethy/nvim-base16' }
    use { 'NTBBloodbath/doom-one.nvim' }
    use { 'catppuccin/nvim', as = "catppuccin" }
  end
}
