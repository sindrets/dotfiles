" Allow movement through display lines (wrapped lines)
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> <DOWN> v:count == 0 ? 'gj' : '<DOWN>'
nnoremap <expr> <UP> v:count == 0 ? 'gk' : '<UP>'
xnoremap <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> <DOWN> v:count == 0 ? 'gj' : '<DOWN>'
xnoremap <expr> <UP> v:count == 0 ? 'gk' : '<UP>'
inoremap <expr> <DOWN> pumvisible() ? '<DOWN>' : '<C-\><C-o>gj'
inoremap <expr> <UP> pumvisible() ? '<UP>' : '<C-\><C-o>gk'

" Home moves to first non-whitespace on display line
nnoremap <expr> <Home> v:count == 0 ? "g^" : "^"
nnoremap <expr> <End> v:count == 0 ? "g$" : "$"
xnoremap <expr> <Home> v:count == 0 ? "g^" : "^"
xnoremap <expr> <End> v:count == 0 ? "g$" : "$"
inoremap <Home> <Cmd>normal g^<CR>
inoremap <End> <C-\><C-O>g$

" Copy, cut and paste to/from system clipboard
xnoremap <expr> y v:register == '"' ? '"+y' : 'y'
xnoremap <expr> <S-Y> v:register == '"' ? '"+Y' : 'Y'
nnoremap <expr> yy v:register == '"' ? '"+yy' : 'yy'
nnoremap <M-p> "+p
nnoremap <M-P> "+P
inoremap <M-p> <Cmd>set paste \| exec 'normal "+p' \| set nopaste<CR><RIGHT>
inoremap <M-P> <Cmd>set paste \| exec 'normal "+P' \| set nopaste<CR><RIGHT>

" File explorer
map <silent> <Leader>e <Cmd>lua NvimTreeConfig.focus()<CR>
map <silent> <Leader>b <Cmd>NvimTreeToggle<CR>

nnoremap <silent> <Leader>q :q<CR>
inoremap <M-Space> <Esc>

" Make session
nnoremap <silent> <M-S> <Cmd>call MakeSession()<CR>

" Begin new line above from insert mode
inoremap <M-Return> <Esc>O

" Navigate buffers
nnoremap  <silent>   <tab> :bn<CR>
nnoremap  <silent> <s-tab> :bp<CR>
nnoremap <leader><leader> <Cmd>:buffer #<CR>
nnoremap <silent> <leader>w <Cmd>lua require'nvim-config.lib'.close_buffer_and_go_to_alt()<CR>
nnoremap <silent> gb <Cmd>BufferLinePick<CR>

" Navigate tabs
map <silent> <Leader><Tab> :tabn<CR>
map <silent> <Leader><S-Tab> :tabp<CR>

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

" Remap jump forward
nnoremap <C-S> <C-I>

" Search for selected text
vnoremap // "vy/\V<C-R>=escape(@",'/\')<CR><CR>

" Move lines up/down
nnoremap <A-UP> <Cmd>m-2<CR>==
nnoremap <A-DOWN> <Cmd>m+<CR>==
inoremap <A-UP> <Cmd>m-2 \| normal! ==<CR>
inoremap <A-DOWN> <Cmd>m+ \| normal! ==<CR>
vnoremap <A-UP> :m '<-2<CR>gv=gv
vnoremap <A-DOWN> :m '>+<CR>gv=gv
" vnoremap <A-UP> <Cmd>call MoveSelection("up")<CR>
" vnoremap <A-DOWN> <Cmd>call MoveSelection("down")<CR>
" vnoremap <A-UP> <Cmd>'<,'>m '<-2<CR>gv=gv
" vnoremap <A-DOWN> <Cmd>'<,'>m '>+<CR>gv=gv

" Select all
nnoremap <C-A> ggVG
inoremap <C-A> <ESC>ggVG
vnoremap <C-A> <ESC>ggVG 

" Shift+arrow selection
nmap <S-Up> v<Up>
nmap <S-Down> v<Down>
nmap <S-Left> v<Left>
nmap <S-Right> v<Right>
vmap <S-Up> <Up>
vmap <S-Down> <Down>
vmap <S-Left> <Left>
vmap <S-Right> <Right>
imap <S-Up> <Esc>v<Up>
imap <S-Down> <Esc>v<Down>
imap <S-Left> <Esc>v
imap <S-Right> <Esc><Right>v

" Ctrl+backspace to delete prev word, ctrl+del to delete next word
inoremap <C-H> <C-\><C-o>db
inoremap <C-Del> <C-\><C-o>dw

" Indentation
vmap <lt> <gv
vmap > >gv

" Turn off search highlight until next search
nnoremap <F3> :noh<CR>

" Repeat prev macro
nmap , @@

" Toggle comments
nnoremap <C-\> :call NERDComment(0, "toggle")<CR>
inoremap <C-\> <Esc>:call NERDComment(0, "toggle")<CR>a
vnoremap <C-\> :call NERDComment(0, "toggle")<CR>gv

" Telescope
nnoremap <C-P> <Cmd>lua require'nvim-config.lib'.workspace_files()<CR>
nnoremap <leader>p <Cmd>lua require'nvim-config.lib'.workspace_files({ all = true })<CR>
nnoremap <M-b> <Cmd>Telescope buffers<CR>
nnoremap <M-f> <Cmd>Telescope live_grep<CR>
nnoremap <M-t> <Cmd>Telescope lsp_workspace_symbols<CR>
nnoremap <M-o> <Cmd>Telescope lsp_document_symbols<CR>
nnoremap <M-d> <Cmd>Telescope lsp_document_diagnostics<CR>

" Git
nnoremap <leader>gs <Cmd>Neogit kind=split<CR>
nnoremap <leader>gl <Cmd>Git log<CR>
nnoremap <leader>gcs <Cmd>Git commit<CR>
nnoremap <leader>gcc <Cmd>Git commit -a<CR>
nnoremap <leader>gb <Cmd>Git blame<CR>
nnoremap <leader>gd <Cmd>DiffviewOpen<CR>

" LspTrouble and Symbols outline
nnoremap <A-S-D> <Cmd>lua LspTroubleCustomToggle()<CR>
nnoremap <C-M-o> <Cmd>lua ToggleSymbolsOutline()<CR>

" Open a terminal split
nnoremap <silent> <C-L> <Cmd>lua ToggleTermSplit()<CR>
inoremap <silent> <C-L> <Cmd>lua ToggleTermSplit()<CR>
tnoremap <silent> <C-L> <Cmd>lua ToggleTermSplit()<CR>
tnoremap <silent> <Esc> <C-\><C-n>
tnoremap <silent> <C-q> <Esc>

" Quickfix and Location list
nnoremap <M-q> <Cmd>lua ToggleQF()<CR>
nnoremap [q <Cmd>cp<CR>
nnoremap ]q <Cmd>cn<CR>
nnoremap [Q <Cmd>cfirst<CR>
nnoremap ]Q <Cmd>clast<CR>
nnoremap [l <Cmd>lprevious<CR>
nnoremap ]l <Cmd>lnext<CR>
nnoremap [L <Cmd>lfirst<CR>
nnoremap ]L <Cmd>llast<CR>

" Trigger completion
inoremap <silent><expr> <C-Space> compe#complete()
" inoremap <silent><expr> <Cr> compe#confirm("<Cr>")

" Navigate snippet placeholders
imap <expr> <C-j> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>'
smap <expr> <C-j> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>'
imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'

" LSP
nmap <silent> gd <Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gV <C-W>v<Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gs <C-W>s<Cmd>lua vim.lsp.buf.definition()<CR>
nmap <silent> gy <Cmd>lua vim.lsp.buf.type_definition()<CR>
nmap <silent> gi <Cmd>lua vim.lsp.buf.implementation()<CR>
nmap <silent> gr <Cmd>Telescope lsp_references<CR>
nmap <silent> <leader>rn <Cmd>lua vim.lsp.buf.rename()<CR>
nmap <silent> <F2> <Cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> <leader>f <Cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> K <Cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>. <Cmd>Telescope lsp_code_actions theme=get_dropdown<CR>
vnoremap <leader>. <Cmd>Telescope lsp_range_code_actions theme=get_dropdown<CR>
nnoremap <silent> <leader>ld <Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
" nnoremap <silent> K <Cmd>Lspsaga hover_doc<CR>
" nnoremap <leader>. <Cmd>Lspsaga code_action<CR>
" vnoremap <leader>. <Cmd>Lspsaga range_code_action<CR>
" nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
" nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
" nnoremap <silent> <leader>ld <Cmd>Lspsaga show_line_diagnostics<CR>
" nnoremap <M-c> :call CocAction("pickColor")<CR>
" nnoremap <M-O> <Cmd>lua vim.lsp.buf.organize_imports()<CR>
" nnoremap <M-t> :CocList symbols<CR>

xnoremap @ :<C-u>lua require'nvim-config.lib'.execute_macro_over_visual_range()<CR>

inoremap <silent> <Tab> <Cmd>lua require'nvim-config.lib'.full_indent()<CR>

" Show highlight group under cursor
nnoremap <F10> <Cmd>lua require'nvim-config.lib'.print_syn_group()<CR>

" COMMANDS
command! -nargs=+ Rnew lua require'nvim-config.lib'.read_new(<q-args>)
command! Ssync syntax sync minlines=3000
command! DiffSaved lua require'nvim-config.lib'.diff_saved()
command! CocJavaClearCache call CocJavaClearCacheFunc()
command! CocJavaExploreCache call CocJavaExploreCacheFunc()
command! -nargs=1 SplitOn lua require'nvim-config.lib'.split_on_pattern(<args>)
command! ExecuteSelection lua vim.api.nvim_exec(require'nvim-config.lib'.get_visual_selection(), false)
command! -bang -bar Bd lua require'nvim-config.lib'.close_buffer_and_go_to_alt("<bang>" == "!")
command! -nargs=1 Grep silent! grep! <args> | belowright cope
command! Spectre lua require'spectre'.open()
command! SpectreFile lua require'spectre'.open_file_search()
command! HiShow execute('redir=>a | silent hi | redir END | enew | put=a '
            \ . '| execute("normal! ggdj") | set nomod | f Highlights | ColorizerAttachToBuffer')
