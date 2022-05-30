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

    " Disable modelines after the first time it's processed.
    au BufWinEnter * setl nomodeline

    au TermEnter * setl nonu nornu signcolumn=no | IlluminationDisable!

    au TermLeave * if &buftype ==# "terminal" | setl nu rnu | endif

    au BufEnter * if &buftype ==# "terminal" | startinsert | endif

    au BufWinEnter,FileType fugitiveblame setl nolist

    " Run PackerCompile when changes are made to plugin configs.
    au BufWritePost */lua/nvim-config/plugins/*.lua
                \ exe "so " . stdpath("config") . "/lua/nvim-config/plugins/init.lua"
                \ | PackerCompile

    au User PackerCompileDone exe 'lua Config.common.utils.info("Packer compiled!")'
                \ | do <nomodeline> ColorScheme

    " Enable 'onemore' in visual mode.
    au ModeChanged *:[v]* setl virtualedit+=onemore
    au ModeChanged [v]*:* setl virtualedit<

    " Automatically reload file if it's been changed outside vim.
    au BufEnter,CursorHold * silent! checktime %

    " Handle opening buffers with the format`foo/bar/baz:128:17`
    au BufEnter *
                \ if expand("<afile>") =~ '\v.*:(\d+)?(:\d+:?)?$'
                \ |     exe "lua require'nvim-config.au'"
                \           . ".open_file_location(vim.fn.expand('<afile>'))"
                \ | endif

    au BufWinLeave * if get(t:, "compare_mode", 0) | diffoff | endif
    au BufEnter * if get(t:, "compare_mode", 0)
                \ |     if &bt ==# ""
                \ |         setl diff cursorbind scrollbind fdm=diff fdl=0
                \ |     else
                \ |         setl nodiff nocursorbind noscrollbind
                \ |     endif
                \ | endif
augroup END
