setl nolist colorcolumn= nonu nornu scl=yes:1
setl foldmethod=syntax

nnoremap <buffer> q <Cmd>lua Config.lib.comfy_quit({ keep_last = true })<CR>
nmap <buffer> <Tab> =
nnoremap <buffer> R <Cmd>edit<CR>
nnoremap <buffer> P <Cmd>Git push<CR>
nnoremap <buffer> p <Cmd>Git pull<CR>
