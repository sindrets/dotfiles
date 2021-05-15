augroup init_vim
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
                \ |   exe "normal! g`\"zz"
                \ | endif

    " Highlight yanks
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="Visual", timeout=300}

    " Set quickfix buffer unlisted
    au BufWinEnter quickfix set nobuflisted | setlocal nowrap

    au TermEnter * setlocal nonu nornu signcolumn=no

    au TermLeave * setlocal nu rnu
augroup END
