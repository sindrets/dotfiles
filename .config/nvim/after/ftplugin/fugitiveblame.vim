" Open diffview for the commit under the cursor
nnoremap <buffer> <C-M-d> <Cmd>exe 'norm! 0"xyiw' <bar> wincmd l <bar> exe 'DiffviewOpen ' . getreg("x") . '^!'<CR>
" Open file history for the current file, from the commit under the cursor
nnoremap <buffer> <C-M-h> <Cmd>exe 'norm! 0"xyiw' <bar> wincmd l <bar> exe 'DiffviewFileHistory % --range=' . getreg("x")<CR>
