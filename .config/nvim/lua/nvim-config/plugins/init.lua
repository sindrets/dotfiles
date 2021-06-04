vim.cmd("packadd packer.nvim")

local function conf(config_name)
  return require(string.format("nvim-config.plugins.%s", config_name))
end

return require'packer'.startup {
  ---@diagnostic disable-next-line: unused-local
  function (use, use_rocks)

    vim.g.netrw_liststyle = 3
    vim.g.netrw_bufsettings = "noma nomod nonu nowrap ro nornu"

    use 'wbthomason/packer.nvim'

    -- SYNTAX
    use { 'kevinoid/vim-jsonc' }
    use { 'sheerun/vim-polyglot' }
    use { 'teal-language/vim-teal' }

    -- BEHAVIOUR
    use { 'nvim-lua/popup.nvim' }
    use { 'nvim-lua/plenary.nvim' }
    use { 'kyazdani42/nvim-web-devicons', config = conf("nvim-web-devicons") }
    use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = conf("treesitter")
    }
    use { 'nvim-treesitter/playground', requires = "nvim-treesitter/nvim-treesitter" }
    use { 'neovim/nvim-lspconfig' }
    -- use { 'glepnir/lspsaga.nvim', { 'branch': 'main' } }
    use { 'mfussenegger/nvim-jdtls' }
    use { 'hrsh7th/nvim-compe', config = conf("nvim-compe") }
    use {
      'kyazdani42/nvim-tree.lua',
      config = conf("nvim-tree"),
      requires = "kyazdani42/nvim-web-devicons"
    }
    use { 'windwp/nvim-autopairs', config = conf("nvim-autopairs") }
    use { 'onsails/lspkind-nvim', config = conf("lspkind") }
    use { 'norcalli/nvim-colorizer.lua', config = conf("nvim-colorizer") }
    use { 'hrsh7th/vim-vsnip' }
    use { 'hrsh7th/vim-vsnip-integ' }
    use { 'scrooloose/nerdcommenter', setup = function ()
      vim.g.NERDSpaceDelims = 1
      vim.g.NERDDefaultAlign = "left"
    end }
    use { 'nvim-telescope/telescope.nvim', config = conf("telescope") }
    use { 'nvim-telescope/telescope-fzy-native.nvim' }
    use { 'nvim-telescope/telescope-media-files.nvim' }
    use { 'akinsho/nvim-bufferline.lua', config = conf("nvim-bufferline") }
    use { 'karb94/neoscroll.nvim', config = conf("neoscroll") }
    use { 'windwp/nvim-spectre', config = conf("spectre") }
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

    -- MISC
    use { 'glepnir/galaxyline.nvim', branch = 'main', config = conf("galaxyline") }
    use { 'lewis6991/gitsigns.nvim', config = conf("gitsigns") }
    use { 'lukas-reineke/indent-blankline.nvim', branch = 'lua', setup = conf("indent-blankline") }
    use { 'folke/lsp-trouble.nvim', config = conf("lsp-trouble") }
    use { 'sindrets/diffview.nvim', config = conf("diffview") }
    use { 'sindrets/diffview-api-test' }
    use {
      'sindrets/neogit',
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
    use { 'glepnir/dashboard-nvim', setup = conf("dashboard") }
    use { 'ryanoasis/vim-devicons' }
    use { 'kevinhwang91/rnvimr' }
    use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', setup = function ()
      vim.api.nvim_exec([[
        function! MkdpOpenInNewWindow(url)
          lua require'nvim-config.lib'.mkdp_open_in_new_window(vim.fn.eval("a:url"))
        endfunction
        ]], false)
      vim.g.mkdp_browserfunc = "MkdpOpenInNewWindow"
    end }
    use { 'honza/vim-snippets' }

    -- THEMES
    use { 'rakr/vim-one' }
    use { 'ayu-theme/ayu-vim' }
    use { 'kaicataldo/material.vim' }
    use { 'phanviet/vim-monokai-pro' }
    use { 'tomasiser/vim-code-dark' }
    use { 'w0ng/vim-hybrid' }
    use { 'chriskempson/base16-vim' }
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
    use { 'kjssad/quantum.vim' }
    use { 'juanedi/predawn.vim' }
    use { 'christianchiarulli/nvcode-color-schemes.vim' }
    use { 'glepnir/zephyr-nvim' }
    use { 'sindrets/tokyonight.nvim' }
  end
}
