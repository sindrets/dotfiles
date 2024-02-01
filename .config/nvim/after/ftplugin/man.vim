setl nowrap

" Send all flag options to loclist
nnoremap <buffer> <M-o> <Cmd>lvimgrep /\v^\s*--?\w+/j % <bar> lopen<CR>

" Navigate headings
nnoremap <buffer> ]] <Cmd>call search('\v^[A-Z0-9\-_()]{2,}(\s[A-Z0-9\-_()]+)*')<CR>
nnoremap <buffer> [[ <Cmd>call search('\v^[A-Z0-9\-_()]{2,}(\s[A-Z0-9\-_()]+)*', 'b')<CR>
