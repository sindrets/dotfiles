augroup NvimConfig
    au!

    " nuke netrw brain damage
    au VimEnter * silent! au! FileExplorer *
    " au BufEnter * if isdirectory(expand('%')) | bd | endif

    au VimEnter * lua require'user.au'.source_project_config();
                \ require'user.au'.source_project_session()

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

    au TermEnter,TermOpen * setl nonu nornu signcolumn=yes:1 | IlluminationDisable!
    au TermOpen * let b:term_start = v:lua.vim.loop.hrtime()

    " Automatically close interactive term buffers if exit status is 0. Don't
    " close the terminal if its lifetime was less than 2 seconds. Define
    " `b:term_keep` to keep the term regardless.
    au TermClose * if v:event.status == 0 && exists("b:term_start") && !get(b:, "term_keep")
                \ && (v:lua.vim.loop.hrtime() - b:term_start) / 1000000 > 2000
                \   | bd | endif

    au TermOpen,BufEnter * lua
                \ if vim.bo[Config.state.term.actual_curbuf or 0].buftype == "terminal" then
                \       vim.cmd("startinsert")
                \ end

    au BufWinEnter,FileType fugitiveblame setl nolist

    " Run PackerCompile when changes are made to plugin configs.
    au BufWritePost */lua/user/plugins/*.lua
                \ exe "so " . stdpath("config") . "/lua/user/plugins/init.lua"
                \ | PackerCompile

    au User PackerCompileDone exe 'lua Config.common.utils.info("Packer compiled!")'
                \ | do <nomodeline> ColorScheme

    " Enable 'onemore' in visual mode.
    au ModeChanged *:[v]* setl virtualedit+=onemore
    au ModeChanged [v]*:* setl virtualedit<

    " Automatically reload file if it's been changed outside vim.
    au BufEnter,CursorHold * silent! checktime %

    " Open file location. Example: `foo/bar/baz:128:17`
    au BufReadCmd *:[0-9]\+ lua require("user.au").open_file_location(vim.fn.expand("<afile>"))

    au BufWinLeave * if get(t:, "compare_mode", 0) | diffoff | endif
    au BufEnter * if get(t:, "compare_mode", 0)
                \ |     if &bt ==# ""
                \ |         setl diff cursorbind scrollbind fdm=diff fdl=0
                \ |     else
                \ |         setl nodiff nocursorbind noscrollbind
                \ |     endif
                \ | endif
augroup END
