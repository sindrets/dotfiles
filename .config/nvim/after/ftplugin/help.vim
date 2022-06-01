setl comments+=n:•
setl formatoptions=tnqro

" Send all helptags to loclist
nnoremap <buffer> <M-o> <Cmd>lvimgrep /\v.*\*\S+\*$/j % <bar> lopen<CR>

function! s:format_helptags() abort
  let l:view = winsaveview()
  %sub/\v(.{-})(\s{2,})(\*.*\*)/\=submatch(1) . repeat(" ", 48 - len(submatch(1))) . submatch(3)
  noh
  call winrestview(l:view)
endfunction

nnoremap <buffer> <leader>ff <Cmd>call <sid>format_helptags()<CR>
