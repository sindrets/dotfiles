" Allow movement through display lines (wrapped lines)
nnoremap <silent> <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <silent> <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <silent> <expr> <DOWN> v:count == 0 ? 'gj' : '<DOWN>'
nnoremap <silent> <expr> <UP> v:count == 0 ? 'gk' : '<UP>'
xnoremap <silent> <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <silent> <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <silent> <expr> <DOWN> v:count == 0 ? 'gj' : '<DOWN>'
xnoremap <silent> <expr> <UP> v:count == 0 ? 'gk' : '<UP>'
inoremap <silent> <expr> <DOWN> pumvisible()
            \ ? '<DOWN>' : '<Cmd>lua require"user.lib".nav_display_line(1)<CR>'
inoremap <silent> <expr> <UP> pumvisible()
            \ ? '<UP>' : '<Cmd>lua require"user.lib".nav_display_line(-1)<CR>'

" Navigate in insert mode
imap <C-h> <Left>
imap <C-j> <Down>
imap <C-k> <Up>
imap <C-l> <Right>

" Smart case motions
noremap <silent> w <Plug>CamelCaseMotion_w
noremap <silent> b <Plug>CamelCaseMotion_b
noremap <silent> e <Plug>CamelCaseMotion_e
noremap <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge
inoremap <C-w> <C-\><C-o>d<Plug>CamelCaseMotion_b
inoremap <C-BS> <C-\><C-o>d<Plug>CamelCaseMotion_b

" Navigate snippet placeholders
imap <expr> <C-f> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : ''
smap <expr> <C-f> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : ''
imap <expr> <C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : ''
smap <expr> <C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : ''

" Home moves to first non-whitespace on display line
nnoremap H g^
nnoremap L g$
nnoremap <expr> <Home> v:count == 0 ? "g^" : "^"
nnoremap <expr> <End> v:count == 0 ? "g$" : "$"
xnoremap H g^
xnoremap L g$
xnoremap <expr> <Home> v:count == 0 ? "g^" : "^"
xnoremap <expr> <End> v:count == 0 ? "g$" : "$"
inoremap <Home> <Cmd>normal g^<CR>
inoremap <End> <C-\><C-O>g$

" Yank, delete, paste
nnoremap <expr> y PlusYank()
nnoremap <expr> yy v:register == '"' ? '"+yy' : 'yy'
nnoremap <expr> Y v:register == '"' ? '"+y$' : 'y$'
nnoremap <M-p> "+p
nnoremap <M-P> "+P
xnoremap <expr> y v:register == '"' ? '"+y' : 'y'
xnoremap <expr> <S-Y> v:register == '"' ? '"+Y' : 'Y'
xnoremap <expr> p v:register == '"' ? '"_dP' : '"_d"' . v:register . 'P'
xnoremap <M-p> "_d"+P
inoremap <M-p> <Cmd>set paste <bar> exe 'norm! "+p' <bar> set nopaste<CR><RIGHT>
inoremap <M-P> <Cmd>set paste <bar> exe 'norm! "+P' <bar> set nopaste<CR><RIGHT>

" File explorer
nnoremap - <Cmd>LirExplore<CR>
nnoremap _ <Cmd>exe 'e ' . getcwd()<CR>
nnoremap <leader>es <Cmd>sp <bar> LirExplore<CR>
nnoremap <leader>ev <Cmd>vsp <bar> LirExplore<CR>
nnoremap <leader>ee <Cmd>call v:lua.Config.plugin.lir.toggle_float()<CR>
nnoremap <leader>E <Cmd>call v:lua.Config.plugin.lir.toggle_float(getcwd())<CR>

" Navigate buffers
nnoremap  <silent>   <tab> :bn<CR>
nnoremap  <silent> <s-tab> :bp<CR>
nnoremap <leader><leader> <Cmd>buffer #<CR>
nnoremap ~ <Cmd>buffer #<CR>
nnoremap <silent> <leader>w <Cmd>lua require'user.lib'.remove_buffer()<CR>
nnoremap <leader>W <Cmd>bd<CR>
nnoremap <silent> gb <Cmd>BufferLinePick<CR>

" Navigate tabs
nnoremap <silent> <Leader><Tab> g<Tab>
nnoremap <leader>1 <Cmd>1tabn<CR>
nnoremap <leader>2 <Cmd>2tabn<CR>
nnoremap <leader>3 <Cmd>3tabn<CR>
nnoremap <leader>4 <Cmd>4tabn<CR>
nnoremap <leader>5 <Cmd>5tabn<CR>
nnoremap <leader>6 <Cmd>6tabn<CR>
nnoremap <leader>7 <Cmd>7tabn<CR>
nnoremap <leader>8 <Cmd>8tabn<CR>
nnoremap <leader>9 <Cmd>9tabn<CR>
nnoremap <leader>x <Cmd>tabc<CR>

" Navigate windows
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
nnoremap <C-x> <C-w>p

" Window splits
nnoremap <leader>v <Cmd>vsp<CR>
nnoremap <leader>s <Cmd>sp<CR>

" Resize windows
nnoremap <C-M-h> <Cmd>vertical res -2<CR>
nnoremap <C-M-l> <Cmd>vertical res +2<CR>
nnoremap <C-M-j> <Cmd>res +1<CR>
nnoremap <C-M-k> <Cmd>res -1<CR>
tnoremap <C-M-h> <Cmd>vertical res -2<CR>
tnoremap <C-M-l> <Cmd>vertical res +2<CR>
tnoremap <C-M-j> <Cmd>res +1<CR>
tnoremap <C-M-k> <Cmd>res -1<CR>

" Move windows
nnoremap <C-w><C-m> <Cmd>WinShift<CR>
nnoremap <C-w>m <Cmd>WinShift<CR>
nnoremap <C-w>X <Cmd>WinShift swap<CR>
nnoremap <S-Left> <Cmd>exe win_gettype(0) ==# "popup" ? "FloatMove -2" : "WinShift left"<CR>
nnoremap <S-Right> <Cmd>exe win_gettype(0) ==# "popup" ? "FloatMove +2" : "WinShift right"<CR>
nnoremap <S-Down> <Cmd>exe win_gettype(0) ==# "popup" ? "FloatMove +0 +1" : "WinShift down"<CR>
nnoremap <S-Up> <Cmd>exe win_gettype(0) ==# "popup" ? "FloatMove +0 -1" : "WinShift up"<CR>
nnoremap <M-S-Space> <Cmd>Float --toggle<CR>
tnoremap <M-S-Space> <Cmd>Float --toggle<CR>

" Window zoom
nnoremap <C-w>o <Cmd>ZoomWinTabToggle<CR>
nnoremap <C-w><C-o> <Cmd>ZoomWinTabToggle<CR>

" Scratchpad
nnoremap <M-S--> <Cmd>Scratchpad move<CR>
nnoremap <M--> <Cmd>Scratchpad show<CR>
tnoremap <M-S--> <Cmd>Scratchpad move<CR>
tnoremap <M--> <Cmd>Scratchpad show<CR>

nnoremap <Leader>q <Cmd>lua Config.lib.comfy_quit()<CR>
nnoremap <C-q> <Cmd>lua Config.lib.comfy_quit()<CR>

nnoremap <leader>z <Cmd>lua Config.lib.set_center_cursor()<CR>

" Move lines
nnoremap <A-K> <Cmd>m-2<CR>==
nnoremap <A-J> <Cmd>m+<CR>==
nnoremap <A-H> <<
nnoremap <A-L> >>
inoremap <A-K> <Cmd>m-2 <bar> normal! ==<CR>
inoremap <A-J> <Cmd>m+ <bar> normal! ==<CR>
inoremap <A-H> <Cmd>norm! <<<CR>
inoremap <A-L> <CMD>norm! >><CR>
vnoremap <A-K> :m '<-2<CR>gv=gv
vnoremap <A-J> :m '>+<CR>gv=gv
vnoremap <A-H> <gv
vnoremap <A-L> >gv

nnoremap <A-UP> <Cmd>m-2<CR>==
nnoremap <A-DOWN> <Cmd>m+<CR>==
inoremap <A-UP> <Cmd>m-2 \| normal! ==<CR>
inoremap <A-DOWN> <Cmd>m+ \| normal! ==<CR>
vnoremap <A-UP> :m '<-2<CR>gv=gv
vnoremap <A-DOWN> :m '>+<CR>gv=gv

" Select all
nnoremap <C-A> ggVG
inoremap <C-A> <ESC>ggVG
vnoremap <C-A> <ESC>ggVG 

" Readline mappings
" @see [GNU readline command docs](https://www.gnu.org/software/bash/manual/html_node/Readline-Interaction.html#Readline-Interaction)

" beginning-of-line
inoremap <C-a> <C-o>^
" end-of-line
inoremap <C-e> <C-o>$
" backward-word
inoremap <M-b> <C-o>b
" forward-word
inoremap <M-f> <C-o>w
" backward-kill-word
inoremap <M-BS> <C-w>
" kill-word
inoremap <M-d> <C-\><C-o>dw
" kill-line
" inoremap <C-k> <Cmd>norm! D<CR><Right>
" backward-kill-line
inoremap <C-u> <Cmd>norm! d0<CR>
" beginning-of-line
cnoremap <C-a> <Home>
" end-of-line
cnoremap <C-e> <End>
" backward-word
cnoremap <M-b> <C-Left>
" forward-word
cnoremap <M-f> <C-Right>
" backward-char
cnoremap <C-b> <Left>
" forward-char
cnoremap <C-f> <Right>
" backward-kill-word
cnoremap <M-BS> <C-w>
" kill-word
cnoremap <expr> <M-d> repeat("<Del>", len(matchstr(getcmdline()[getcmdpos() - 1:-1], '\v^\W*\w*(>\|$)')))
" kill-line
cnoremap <expr> <C-k> repeat("<Del>", len(getcmdline()[getcmdpos() - 1:-1]))
" backward-kill-line
cnoremap <expr> <C-u> repeat("<Bs>", len(getcmdline()[0:getcmdpos()]))
" kill-whole-line
cnoremap <expr> <M-k> "<Home>" . repeat("<Del>", len(getcmdline()))

" Turn off search highlight until next search
nnoremap <Esc> <Cmd>noh<CR>
nnoremap <expr> * v:lua.Config.lib.expr.comfy_star()

" Toggle comments
nnoremap <silent> <C-\> <Cmd>call nerdcommenter#Comment(0, "toggle")<CR>
inoremap <silent> <C-\> <Esc>:call nerdcommenter#Comment(0, "toggle")<CR>a
vnoremap <silent> <C-\> :call nerdcommenter#Comment(0, "toggle")<CR>gv
nnoremap <silent> <leader>' <Cmd>call nerdcommenter#Comment(0, "toggle")<CR>
vnoremap <silent> <leader>' :call nerdcommenter#Comment(0, "toggle")<CR>gv

" Telescope
nnoremap <C-P> <Cmd>lua require('user.lib').workspace_files()<CR>
nnoremap <leader>p <Cmd>lua require('user.lib').workspace_files({ all = true })<CR>
nnoremap <C-M-P> <Cmd>Telescope git_status<CR>
nnoremap <M-b> <Cmd>Telescope buffers<CR>
nnoremap <M-f> <Cmd>Telescope live_grep<CR>
nnoremap <M-O> <Cmd>Telescope lsp_dynamic_workspace_symbols<CR>
nnoremap <M-o> <Cmd>Telescope lsp_document_symbols<CR>
nnoremap <M-d> <Cmd>Telescope lsp_document_diagnostics<CR>
nnoremap z= <Cmd>Telescope spell_suggest theme=get_cursor<CR>
nnoremap <leader>fl <Cmd>Telescope current_buffer_fuzzy_find theme=get_ivy<CR>
nnoremap ;; <Cmd>Telescope resume<CR>

" Git
nnoremap <leader>G <Cmd>lua Config.plugin.fugitive.status_open("tab", { use_last = true })<CR>
nnoremap <leader>gs <Cmd>lua Config.plugin.fugitive.status_open("split")<CR>
nnoremap <leader>gl <Cmd>exe 'Flogsplit -max-count=256' <bar> wincmd J<CR>
nnoremap <leader>ga <Cmd>silent exe '!git add %' <bar> lua Config.common.notify.git("Staged "
            \ .. Config.common.utils.str_quote(pl:vim_expand("%:.")))<CR>
nnoremap <leader>gA <Cmd>silent exe '!git add .' <bar>lua Config.common.notify.git("Staged "
            \ .. Config.common.utils.str_quote(pl:vim_fnamemodify(".", ":~")))<CR> 
nnoremap <leader>gcc <Cmd>Git commit <bar> wincmd J<CR>
nnoremap <leader>gC <Cmd>Git commit -a <bar> wincmd J<CR>
nnoremap <leader>gca <Cmd>Git commit --amend <bar> wincmd J<CR>
nnoremap <leader>gb <Cmd>Git blame <bar> wincmd p<CR>
nnoremap <leader>gd <Cmd>DiffviewOpen<CR>
nnoremap <leader>gh <Cmd>DiffviewFileHistory<CR>
nnoremap <leader>gH <Cmd>DiffviewFileHistory %<CR>
xnoremap <leader>gh <Esc><Cmd>'<,'>DiffviewFileHistory<CR>

" LspTrouble and Symbols outline
nnoremap <A-S-D> <Cmd>lua Config.fn.toggle_diagnostics()<CR>
nnoremap <C-M-o> <Cmd>lua Config.fn.toggle_outline()<CR>
nnoremap <M-CR> <Cmd>lua Config.fn.update_messages_win()<CR>

" Open a terminal split
nnoremap <silent> <C-l> <Cmd>TermToggle<CR>
tnoremap <silent> <C-l> <Cmd>TermToggle<CR>
tnoremap <silent> <Esc> <C-\><C-n>
tnoremap <silent> <M-Space> <Esc>
" Clear screen + scrollback
tnoremap <C-M-l> <C-a><C-k>clear<CR><Cmd>setl scrollback=1 so=0 <bar> setl scrollback=10000 so<<CR>
xnoremap <C-s> :TermSend<CR>

" Quickfix, Location list, Jumps
nnoremap <M-q> <Cmd>lua Config.fn.toggle_quickfix()<CR>
nnoremap [q <Cmd>cp<CR>zz
nnoremap ]q <Cmd>cn<CR>zz
nnoremap [Q <Cmd>cfirst<CR>zz
nnoremap ]Q <Cmd>clast<CR>zz
nnoremap [l <Cmd>lprevious<CR>zz
nnoremap ]l <Cmd>lnext<CR>zz
nnoremap [L <Cmd>lfirst<CR>zz
nnoremap ]L <Cmd>llast<CR>zz

nnoremap [d <Cmd>exe 'lua vim.diagnostic.goto_prev({ float = false })'<CR>zz
nnoremap ]d <Cmd>exe 'lua vim.diagnostic.goto_next({ float = false })'<CR>zz
nnoremap [D <Cmd>exe 'norm! gg0' <bar> exe 'lua vim.diagnostic.goto_next({ float = false })'<CR>zz
nnoremap ]D <Cmd>exe 'norm! G0' <bar> exe 'lua vim.diagnostic.goto_prev({ float = false })'<CR>zz

nnoremap <expr> [r v:lua.Config.lib.expr.next_reference(v:true)
nnoremap <expr> ]r v:lua.Config.lib.expr.next_reference()

nnoremap n nzz
nnoremap N Nzz

" Center jumplist jumps and remap jump forward
nnoremap <C-o> <C-o>zz
nnoremap <C-s> <C-i>zz

" LSP
nmap <silent> gd <Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gV <C-W>v<Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gs <C-W>s<Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gy <Cmd>lua vim.lsp.buf.type_definition()<CR>
nmap <silent> gi <Cmd>lua vim.lsp.buf.implementation()<CR>
nmap <silent> gr <Cmd>Telescope lsp_references<CR>
nmap <silent> <leader>rn <Cmd>lua vim.lsp.buf.rename()<CR>
nmap <silent> <F2> <Cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <leader>ff <Cmd>lua vim.lsp.buf.format({ async = true })<CR>
xnoremap <silent> <leader>ff <Esc><Cmd>lua vim.lsp.buf.format({ range = {} })<CR>
nnoremap <silent> K <Cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>. <Cmd>lua vim.lsp.buf.code_action()<CR>
vnoremap <leader>. <Cmd>lua vim.lsp.buf.range_code_action()<CR>
nnoremap <silent> <leader>ld <Cmd>lua vim.diagnostic.open_float({ scope = "line", border = "single" })<CR>
" nnoremap <M-O> <Cmd>lua vim.lsp.buf.organize_imports()<CR>

" Misc: {{{

xnoremap @ :<C-u>lua Config.lib.execute_macro_over_visual_range()<CR>
inoremap <Tab> <Cmd>lua Config.lib.full_indent()<CR>
inoremap <M-Space> <Esc>

" Change mapping for digraphs
inoremap <C-d> <C-k>

" Begin new line above from insert mode
inoremap <M-Return> <Esc>O

" Search for selected text
vnoremap * "vy/\V<C-R>=escape(@",'/\')<CR><CR>

" Change the current word (dot-repeatable for all matches of <cword>)
nnoremap cn *``cgn

" Change the current selection (dot-repeatable for all macthes of the
" selection)
vnoremap cn "vy/\V<C-R>=escape(@",'/\')<CR><CR>``cgn

" Start search with very-magic mode
nnoremap / /\v
nnoremap ? ?\v

" Repeat prev macro
nmap , @@

" }}}

" Show highlight group under cursor
nnoremap <F10> <Cmd>lua require'user.lib'.print_syn_group()<CR>

" OPERATOR FUNCTIONS

" Always yank to plus registry by default.
function! PlusYank(type = "")
    if a:type == ''
        let b:_register = v:register
        set opfunc=PlusYank
        return 'g@'
    endif

    let l:reg = b:_register == '"' ? '+' : b:_register
    let sel_save = &selection
    let cb_save = &clipboard
    let visual_marks_save = [getpos("'<"), getpos("'>")]

    try
        set clipboard= selection=inclusive
        let commands = #{
                    \ line: "'[V']\"" . l:reg . "y",
                    \ char: "`[v`]\"" . l:reg . "y",
                    \ block: "`[\<c-v>`]\"" . l:reg . "y",
                    \ }
        silent exe 'keepjumps normal! ' .. get(commands, a:type, '')
    finally
        call setpos("'<", visual_marks_save[0])
        call setpos("'>", visual_marks_save[1])
        let &clipboard = cb_save
        let &selection = sel_save
    endtry
endfunction

" vim: fdm=marker
