setl nolist
setl scl=yes:2
setl nonu nornu

" Navigate quickfix history
if len(getloclist(0)) > 0
    nnoremap <buffer> J <Cmd>lnewer<CR>
    nnoremap <buffer> K <Cmd>lolder<CR>
else
    nnoremap <buffer> J <Cmd>cnewer<CR>
    nnoremap <buffer> K <Cmd>colder<CR>
endif
