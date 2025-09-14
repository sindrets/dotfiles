" Temporarily set 'lazyredraw' and execute {cmd}.
function! s:LazyCmd(cmd) abort
    let l:save_lazyredraw = &lazyredraw
    let l:err = v:null

    try
        set lazyredraw
        call execute(a:cmd)
    catch /.*/
        let l:err = v:exception
    finally
        if !l:save_lazyredraw
            set nolazyredraw
        endif
    endtry

    if l:err != v:null
        echohl ErrorMsg
        echom l:err
        echohl NONE
    endif
endfunction

" Temporarily set 'lazyredraw' and execute normal mode commands {cmd}.
function! s:LazyNorm(cmd) abort
    call s:LazyCmd("norm! " . a:cmd)
endfunction

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

" Do camel-case-delete-word-backwards, *unless* the text left of the cursor is
" only whitespace, in which case: do the normal <C-w>.
inoremap <expr> <C-w> col(".") == 1 \|\| getline(".")[0:max([col(".")-2, 0])] =~# "^\\s*$"
            \ ? '<C-w>'
            \ : '<C-\><C-o>d<Plug>CamelCaseMotion_b'

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
nnoremap <expr> y <SID>PlusYank()
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

" Yank path
nnoremap <leader>yp <CMD>let @+ = expand("%:.") \| let @0 = @+<CR>
nnoremap <leader>yP <CMD>let @+ = expand("%:p") \| let @0 = @+<CR>
nnoremap <leader>yl <CMD>let @+ = printf("%s:%d", expand("%"), getcurpos()[1]) \| let @0 = @+<CR>
nnoremap <leader>yL <CMD>let @+ = printf("%s:%d", expand("%:p"), getcurpos()[1]) \| let @0 = @+<CR>

" File explorer
nnoremap - <Cmd>Oil<CR>
nnoremap _ <Cmd>exe 'e ' . getcwd()<CR>
nnoremap <leader>es <Cmd>sp <bar> Oil<CR>
nnoremap <leader>ev <Cmd>vsp <bar> Oil<CR>
nnoremap <leader>ee <Cmd>exe 'Float' <bar> Oil<CR>
nnoremap <leader>E <Cmd>exe 'Float' <bar> exe 'Oil ' . fnameescape(getcwd())<CR>

" Navigate buffers
nnoremap  <silent>   <tab> :bn<CR>
nnoremap  <silent> <s-tab> :bp<CR>
nnoremap <leader><leader> <Cmd>buffer #<CR>
nnoremap ~ <Cmd>buffer #<CR>
nnoremap <silent> <leader>w <Cmd>lua require'user.lib'.remove_buffer()<CR>
nnoremap <silent> <leader>W <Cmd>lua require'user.lib'.remove_buffer(true)<CR>
nnoremap <silent> gb <Cmd>BufferLinePick<CR>
nnoremap X <Cmd>lua require'user.lib'.smart_buf_delete(false)<CR>

" Navigate tabs
nnoremap <M-[> <Cmd>tabp<CR>
nnoremap <M-]> <Cmd>tabn<CR>
nnoremap <leader>x <Cmd>tabc<CR>
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

" Journal
nnoremap <leader>jo <Cmd>Neorg journal toc open<CR>
nnoremap <leader>jj <Cmd>Neorg journal today<CR>

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
inoremap <C-a> <Home>
" end-of-line
inoremap <C-e> <End>
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
nmap <silent> <C-\> gcc
imap <silent> <C-\> <Esc>mcgcc`cllla
vmap <silent> <C-\> gcgv
nmap <silent> <leader>' gcc
vmap <silent> <leader>' gcgv

" Picker
nnoremap <C-P> <Cmd>lua require('user.lib').workspace_files()<CR>
nnoremap <leader>p <Cmd>lua require('user.lib').workspace_files({ all = true })<CR>
nnoremap <C-M-P> <Cmd>lua Snacks.picker.git_status()<CR>
nnoremap <M-b> <Cmd>lua Snacks.picker.buffers({ sort_lastused = true })<CR>
nnoremap <M-f> <Cmd>lua Snacks.picker.grep({ hidden = true })<CR>
nnoremap <M-O> <Cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>
nnoremap <M-o> <Cmd>lua Snacks.picker.lsp_symbols()<CR>
nnoremap <M-d> <Cmd>lua Snacks.picker.diagnostics_buffer()<CR>
nnoremap z= <Cmd>lua Snacks.picker.spelling({ layout = { preset = "select", layout = { relative = "cursor", row = 1, max_width = 45, max_height = 10 } } })<CR>
nnoremap <leader>fl <Cmd>lua Snacks.picker.lines({ layout = { preset = "ivy", preview = "" } })<CR>
nnoremap ;; <Cmd>lua Snacks.picker.resume()<CR>

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

" Diff
xnoremap <silent> <leader>do :diffget<CR>
xnoremap <silent> <leader>dp :diffput<CR>
"   toggle iwhite
nnoremap <leader>ow <Cmd>
            \ lua if vim.tbl_contains(vim.opt.diffopt:get(), "iwhite") then
            \ vim.opt.diffopt:remove("iwhite"); Config.common.notify.info("'iwhite' disabled.");
            \ else vim.opt.diffopt:append("iwhite"); Config.common.notify.info("'iwhite' enabled.");
            \ end<CR>

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

nmap ø [
nmap æ ]
nmap <M-ø> <M-[>
nmap <M-æ> <M-]>

nnoremap n <Cmd>set hlsearch <bar> call <SID>LazyNorm(v:searchforward ? "nzz" : "Nzz")<CR>
nnoremap N <Cmd>set hlsearch <bar> call <SID>LazyNorm(v:searchforward ? "Nzz" : "nzz")<CR>

" Center jumplist jumps and remap jump forward
nnoremap <C-o> <C-o>zz
nnoremap <C-s> <C-i>zz

" LSP
nmap <silent> gd <Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gV <C-W>v<Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> <C-w>gd <C-W>s<Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gy <Cmd>lua vim.lsp.buf.type_definition()<CR>
nmap <silent> gi <Cmd>lua vim.lsp.buf.implementation()<CR>
nmap <silent> gr <Cmd>lua Snacks.picker.lsp_references()<CR>
nmap <silent> <leader>rn <Cmd>lua vim.lsp.buf.rename()<CR>
nmap <silent> <F2> <Cmd>lua vim.lsp.buf.rename()<CR>
" noremap <silent> <leader>ff <Cmd>lua require("conform").format({ async = true, lsp_format = "fallback" })<CR>
nnoremap <silent> K <Cmd>lua Config.lsp.buf_hover()<CR>
nnoremap <leader>. <Cmd>lua vim.lsp.buf.code_action()<CR>
vnoremap <leader>. <Cmd>lua vim.lsp.buf.range_code_action()<CR>
nnoremap <silent> <leader>ld <Cmd>lua vim.diagnostic.open_float({ scope = "line", border = "single" })<CR>
" nnoremap <M-O> <Cmd>lua vim.lsp.buf.organize_imports()<CR>
lua <<EOF
vim.keymap.set("", "<leader>ff", function()
  require("conform").format({ async = true }, function(err)
    if not err then
      local mode = vim.api.nvim_get_mode().mode
      if vim.startswith(string.lower(mode), "v") then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      end
    end
  end)
end, { desc = "Format code" })
EOF

" Misc: {{{

" Toggle conceal
nnoremap <leader>oc <Cmd>
            \ lua if vim.opt.conceallevel:get() > 0 then
            \   vim.opt.conceallevel = 0; Config.common.notify.info("Conceal disabled.");
            \ else
            \   vim.opt.conceallevel = 3; Config.common.notify.info("Conceal enabled.");
            \ end<CR>

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

" Use 'lazyredraw' when replaying macro
nnoremap @ <Cmd>call <SID>LazyNorm(v:count1 . "@" . getcharstr())<CR>
nnoremap @@ <Cmd>call <SID>LazyNorm(v:count1 . "@@")<CR>
nnoremap Q <Cmd>call <SID>LazyNorm(v:count1 . "@@")<CR>

" }}}

" Show highlight group under cursor
nnoremap <F10> <Cmd>lua require'user.lib'.print_syn_group()<CR>

" OPERATOR FUNCTIONS

" Always yank to plus registry by default.
function! s:PlusYank(type = "") abort
    if a:type == ''
        let b:save_register = v:register
        set opfunc=<SID>PlusYank
        return 'g@'
    endif

    let l:reg = b:save_register == '"' ? '+' : b:save_register
    let l:save_sel = &selection
    let l:save_cb = &clipboard
    let l:save_visual_marks = [getpos("'<"), getpos("'>")]

    try
        set clipboard= selection=inclusive
        let commands = #{
                    \ line: "'[V']\"" . l:reg . "y",
                    \ char: "`[v`]\"" . l:reg . "y",
                    \ block: "`[\<c-v>`]\"" . l:reg . "y",
                    \ }
        silent exe 'keepjumps normal! ' .. get(commands, a:type, '')
    finally
        call setpos("'<", l:save_visual_marks[0])
        call setpos("'>", l:save_visual_marks[1])
        let &clipboard = l:save_cb
        let &selection = l:save_sel
    endtry
endfunction

" vim: fdm=marker
