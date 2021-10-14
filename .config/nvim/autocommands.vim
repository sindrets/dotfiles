augroup NvimConfig
    au!

    " nuke netrw brain damage
    au VimEnter * silent! au! FileExplorer *
    " au BufEnter * if isdirectory(expand('%')) | bd | endif

    au VimEnter * lua require'nvim-config.au'.source_project_config();
                \ require'nvim-config.au'.source_project_session()

    " Restore cursor pos
    au BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                \ |     exe "normal! g`\"zz"
                \ | endif

    " Highlight yanks
    au TextYankPost * silent!
                \ lua vim.highlight.on_yank({ higroup="Visual", timeout=300, on_visual=true })

    au BufWinEnter quickfix set nobuflisted | setl nowrap cc=

    au TermEnter * setl nonu nornu signcolumn=no

    au TermLeave * setl nu rnu

    " Run PackerCompile when changes are made to plugin configs.
    au BufWritePost */lua/nvim-config/plugins/*.lua PackerCompile
    au User PackerCompileDone lua require'nvim-config.utils'.info("Packer compiled!")

    au TabEnter * silent! NvimTreeRefresh

    au BufEnter *
                \ if expand("<afile>") =~ '.*:\d\+:\d\+$'
                \ |     exe 'lua require"nvim-config.au"'
                \           . '.open_file_location(vim.fn.expand("<afile>"))'
                \ | endif
augroup END
