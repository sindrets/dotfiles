augroup NvimConfig
    au!

    " nuke netrw brain damage
    au VimEnter * silent! au! FileExplorer *
    au BufEnter *
                \ if isdirectory(expand('%'))
                \ |     bd
                \ | endif

    au VimEnter * lua require'nvim-config.lib'.source_project_config();
                \ require'nvim-config.lib'.source_project_session()

    " Restore cursor pos
    au BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                \ |     exe "normal! g`\"zz"
                \ | endif

    " Highlight yanks
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="Visual", timeout=300}

    au BufWinEnter quickfix set nobuflisted | setlocal nowrap cc=

    au TermEnter * setlocal nonu nornu signcolumn=no

    au TermLeave * setlocal nu rnu

    " Run PackerCompile when changes are made to plugin configs.
    au BufWritePost */lua/nvim-config/plugins/*.lua execute 'PackerCompile' 
                \ | lua require'nvim-config.utils'.info('Packer compiled!')
augroup END
