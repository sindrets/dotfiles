"      _       _ __        _         
"     (_)___  (_) /__   __(_)___ ___ 
"    / / __ \/ / __/ | / / / __ `__ \
"   / / / / / / /__| |/ / / / / / / /
"  /_/_/ /_/_/\__(_)___/_/_/ /_/ /_/ 
"                                    

": SETTINGS {{{

set nu
set rnu
set autoindent
set shiftwidth=4
set tabstop=4
set softtabstop=-1
set expandtab
set ignorecase
set smartcase
set wildignorecase
set showcmd
set mouse=a
set hidden
set cursorline
set splitbelow
set splitright
set wrap linebreak
set noswapfile
set updatetime=100
set backspace=indent,eol,start
set inccommand=split
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99
set completeopt=menuone,noselect
set signcolumn=auto:2
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize
set diffopt=internal,filler,closeoff,iwhite
set pyx=3
set pyxversion=3
set shada=!,'10,/100,:100,<0,@1,f1,h,s1
set writebackup
set undofile

let g:data_backup = stdpath("data") . "/backup"
let g:data_undo = stdpath("data") . "/undo"
execute("set backupdir=" . g:data_backup)
execute("set undodir=" . g:data_undo)

if ! isdirectory(g:data_backup)
    call system("mkdir " . g:data_backup)
endif

if ! isdirectory(g:data_undo)
    call system("mkdir " . g:data_undo)
endif

if executable("ag")
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
endif

if has("termguicolors")
    set termguicolors
endif

" ruler
set colorcolumn=100

" render whitespace
set list
set listchars=tab:\ ──,space:·,nbsp:␣,trail:•,eol:↵,precedes:«,extends:»
set showbreak=⤷\ 

syntax on
syntax sync minlines=3000
filetype plugin indent on

let s:init_extra_path = system("realpath -m " . $MYVIMRC . "/../init_extra.vim")[:-2]
if filereadable(s:init_extra_path)
    exec "source " . s:init_extra_path
endif

": }}}

": PLUGIN CONFIG {{{

let mapleader = " "                             " set the leader key
let g:netrw_liststyle= 3
let g:python_recommended_style = 0

let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.2"}

let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'

let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.xml'
let g:closetag_filetypes = 'html,xhtml,phtml,xml'

let g:user_emmet_leader_key='<C-Z>'

let g:mkdp_browserfunc = "MkdpOpenInNewWindow"

if isdirectory(expand('%'))
    exec "cd " . expand("%")
endif

": }}}

": PLUG {{{

call plug#begin("~/.vim/plug")
" SYNTAX
Plug 'kevinoid/vim-jsonc'
Plug 'sheerun/vim-polyglot'
" BEHAVIOUR
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }
Plug 'mfussenegger/nvim-jdtls'
Plug 'hrsh7th/nvim-compe'
Plug 'kyazdani42/nvim-tree.lua'
Plug 'windwp/nvim-autopairs'
Plug 'onsails/lspkind-nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'scrooloose/nerdcommenter'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-telescope/telescope-media-files.nvim'
Plug 'akinsho/nvim-bufferline.lua'
Plug 'mileszs/ack.vim'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-abolish'
Plug 'alvan/vim-closetag'
Plug 'Rasukarusan/nvim-block-paste'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
" MISC
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
Plug 'lewis6991/gitsigns.nvim'
Plug 'lukas-reineke/indent-blankline.nvim', { 'branch': 'lua' }
Plug 'folke/lsp-trouble.nvim'
Plug 'tpope/vim-fugitive'
Plug 'glepnir/dashboard-nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'kevinhwang91/rnvimr'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'honza/vim-snippets'
" THEMES
Plug 'rakr/vim-one'
Plug 'ayu-theme/ayu-vim'
Plug 'kaicataldo/material.vim'
Plug 'phanviet/vim-monokai-pro'
Plug 'tomasiser/vim-code-dark'
Plug 'w0ng/vim-hybrid'
Plug 'chriskempson/base16-vim'
Plug 'nanotech/jellybeans.vim'
Plug 'cocopon/iceberg.vim'
Plug 'junegunn/seoul256.vim'
Plug 'arzg/vim-colors-xcode'
Plug 'haishanh/night-owl.vim'
Plug 'KeitaNakamura/neodark.vim'
Plug 'dim13/smyck.vim'
Plug 'barlog-m/oceanic-primal-vim', {'branch': 'main'}
Plug 'jacoborus/tender.vim'
Plug 'ntk148v/vim-horizon'
Plug 'ajh17/Spacegray.vim'
Plug 'sainnhe/gruvbox-material'
Plug 'kjssad/quantum.vim'
Plug 'juanedi/predawn.vim'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
Plug 'glepnir/zephyr-nvim'
Plug 'folke/tokyonight.nvim'
call plug#end()

" Theme settings
source ~/.config/nvim/color-config.vim

luafile ~/.config/nvim/lua/nvim-config/nvim-web-devicons-config.lua
luafile ~/.config/nvim/lua/nvim-config/treesitter-config.lua
luafile ~/.config/nvim/lua/nvim-config/lspsaga-config.lua
luafile ~/.config/nvim/lua/nvim-config/lsp-config.lua
luafile ~/.config/nvim/lua/nvim-config/nvim-compe-config.lua
luafile ~/.config/nvim/lua/nvim-config/nvim-tree-config.lua
luafile ~/.config/nvim/lua/nvim-config/nvim-autopairs-config.lua
luafile ~/.config/nvim/lua/nvim-config/nvim-colorizer-config.lua
luafile ~/.config/nvim/lua/nvim-config/lspkind-config.lua
luafile ~/.config/nvim/lua/nvim-config/telescope-config.lua
luafile ~/.config/nvim/lua/nvim-config/nvim-bufferline-config.lua
luafile ~/.config/nvim/lua/nvim-config/gitsigns-config.lua
luafile ~/.config/nvim/lua/nvim-config/galaxyline-config.lua
luafile ~/.config/nvim/lua/nvim-config/indent-blankline-config.lua
luafile ~/.config/nvim/lua/nvim-config/lsp-trouble-config.lua
luafile ~/.config/nvim/lua/nvim-config/dashboard-config.lua

": }}}

": MAPPINGS {{{

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
map <silent> <Leader>e <Cmd>lua NvimTreeFocus()<CR>
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
nnoremap <leader><leader> <C-^>zz
nnoremap <silent> <leader>w :call CloseBufferAndGoToAlt()<CR>
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
nnoremap <C-P> <Cmd>call WorkspaceFiles()<CR>
nnoremap <leader>p <Cmd>call WorkspaceFiles('-a')<CR>
nnoremap <M-b> <Cmd>Telescope buffers<CR>
nnoremap <M-f> <Cmd>Telescope live_grep<CR>
nnoremap <M-t> <Cmd>Telescope lsp_workspace_symbols<CR>
nnoremap <M-o> <Cmd>Telescope lsp_document_symbols<CR>
nnoremap <M-d> <Cmd>Telescope lsp_document_diagnostics<CR>
" nnoremap <C-P> :call WorkspaceFiles()<CR>
" nnoremap <M-b> :Buffers<CR>
" nnoremap <C-F> :Ack! 

" LspTrouble
nnoremap <A-S-D> <Cmd>lua LspTroubleCustomToggle()<CR>

nnoremap <leader>rh :call FindAndReplaceInAll()<CR>

" Open a terminal split
nnoremap <Leader>t :call FocusTerminalSplit()<CR>
nnoremap <silent> <C-L> :call ToggleTerminalSplit()<CR>
inoremap <silent> <C-L> <Esc>:call ToggleTerminalSplit()<CR>
tnoremap <silent> <C-L> <C-\><C-N>:call ToggleTerminalSplit()<CR>
tnoremap <silent> <Esc> <C-\><C-n>

" Toggle quickfix
nnoremap <M-q> <Cmd>call ToggleQuickFix()<CR>

" Trigger completion
inoremap <silent><expr> <C-Space> compe#complete()
" inoremap <silent><expr> <Cr> compe#confirm("<Cr>")

" Navigate snippet placeholders
imap <expr> <C-j> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>'
smap <expr> <C-j> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<C-j>'
imap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'
smap <expr> <C-k> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-k>'

" LSP
nmap <silent> gd <Cmd>lua vim.lsp.buf.definition()<CR>zz
nmap <silent> gV <C-W>v<Cmd>lua vim.lsp.buf.definition()<CR>zz
nmap <silent> gs <C-W>s<Cmd>lua vim.lsp.buf.definition()<CR>zz
nmap <silent> gy <Cmd>lua vim.lsp.buf.type_definition()<CR>zz
nmap <silent> gi <Cmd>lua vim.lsp.buf.implementation()<CR>zz
nmap <silent> gr <Cmd>Lspsaga lsp_finder<CR>
nmap <silent> <leader>rn <Cmd>Lspsaga rename<CR>
nmap <silent> <F2> <Cmd>Lspsaga rename<CR>
nnoremap <silent> <leader>f <Cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> K <Cmd>Lspsaga hover_doc<CR>
nnoremap <leader>. <Cmd>Lspsaga code_action<CR>
vnoremap <leader>. <Cmd>Lspsaga range_code_action<CR>
nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
nnoremap <silent> <leader>ld <Cmd>Lspsaga show_line_diagnostics<CR>
" nnoremap <M-c> :call CocAction("pickColor")<CR>
" nnoremap <M-O> <Cmd>lua vim.lsp.buf.organize_imports()<CR>
" nnoremap <M-t> :CocList symbols<CR>

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

inoremap <silent> <Tab> <Cmd>call FullIndent()<CR>

" Show highlight group under cursor
nnoremap <F10> <Cmd>call SynStack() \| call SynGroup()<CR>

": }}}

": COMMANDS {{{

command! -nargs=+ Rnew call ReadNew(<q-args>)
command! Ssync syntax sync minlines=3000
command! DiffSaved call FuncDiffSaved()
command! CocJavaClearCache call CocJavaClearCacheFunc()
command! CocJavaExploreCache call CocJavaExploreCacheFunc()
command! -nargs=1 SplitOn call SplitLineOnPattern(<args>)
command! ExecuteSelection call execute(GetVisualSelection())
command! HiShow execute('redir=>a | silent hi | redir END | enew | put=a '
            \ . '| set nomod | f Highlights | execute("normal! gg") | ColorizerAttachToBuffer')

": }}}

": FUNCTIONS {{{

function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
endfunction

" Read the output of a command into a new buffer
function! ReadNew(expr)
    enew | set ft=log
    exec "r! " . a:expr
endfunction

function! GetVisualSelection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! FuncDiffSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction

function! WorkspaceFiles(...)
    if get(a:, 1, '0') ==# "-a"
        " if '-a': show all files including ignored
        call luaeval("require('telescope.builtin').find_files({
                    \ hidden=true,
                    \ find_command={ 'fd', '--type', 'f', '--no-ignore' }
                    \ })")
    elseif !empty(glob("./.git"))
        Telescope git_files
    else
        lua require("telescope.builtin").find_files({ hidden=true })
    endif
endfunction

function! MoveSelection(direction)
    if a:direction ==# "up"
        exec "'<,'> m'<-2"
        normal! gv=gv
    elseif a:direction ==# "down"
        exec "'<,'>  m'>+"
        normal! gv=gv
    endif
endfunction

function! WipeAll()
    let i = 0
    let n = bufnr("$")
    while i < n
        let i = i + 1
        if bufexists(i)
            execute("bw " . i)
        endif
    endwhile
endfunction

function! GetBufferWithPattern(pattern)
    let i = 0
    let n = bufnr("$")
    while i < n
        let i = i + 1
        if (bufname(i)) =~ a:pattern
            return i
        endif
    endwhile
    return -1
endfunction

function! GetBufferWithVar(var, value)
    let i = 0
    let n = bufnr("$")
    while i < n
        let i = i + 1
        let v = getbufvar(i, a:var)
        if !empty(v) && v == a:value
            return i
        endif
    endwhile
    return -1
endfunction

let g:term_split_height = 16
function! FocusTerminalSplit()
    let term_buf_id = GetBufferWithPattern("term_split")
    if term_buf_id != -1
        if exists("g:term_split_winid") && win_id2win(g:term_split_winid) > 0
            call win_gotoid(g:term_split_winid)
        else
            100 wincmd j
            belowright split
            exec "res " . min([g:term_split_height, float2nr(&lines / 2)])
            let g:term_split_winid = win_getid()
        endif
        exec "buffer " . term_buf_id
        startinsert
    else
        belowright split | term
        set nobuflisted | file! term_split
        let g:term_split_winid = win_getid()
        augroup term_split
            au!
            au QuitPre <buffer> let g:term_split_height = winheight("%")
        augroup END
        exec "res " . min([g:term_split_height, float2nr(&lines / 2)])
        startinsert
    endif
endfunction

function! ToggleTerminalSplit()
    let term_buf_id = GetBufferWithPattern("term_split")
    if term_buf_id == -1
        call FocusTerminalSplit()
    elseif exists("g:term_split_winid")
        " term buffer exists. check if it is focused
        if g:term_split_winid == win_getid()
            " term is focused: close it
            wincmd q
        else
            call FocusTerminalSplit()
        endif
    endif
endfunction

function! ToggleQuickFix()
    let qf_buf_id = GetBufferWithVar("&filetype", "qf")
    if qf_buf_id == -1
        cope
        return
    endif

    let qf_win_ids = win_findbuf(qf_buf_id)
    if empty(qf_win_ids)
        cope
    else
        if qf_win_ids[0] == win_getid()
            " quickfix is current window: close it
            cclose
        else
            " quickfix is not current window: focus it
            cope
        endif
    endif
endfunction

function! MakeSession()
    silent !mkdir -p .vim
    let wasOpen = luaeval("require('nvim-tree.view').win_open()")
    if wasOpen == v:true
        silent NvimTreeClose
    endif
    silent mks! .vim/Session.vim
    if wasOpen == v:true
        silent NvimTreeOpen
        wincmd p
    endif
    echom 'Session saved!'
endfunction

function! FindAndReplaceInAll()
    call inputsave()
    let find_string = substitute(input("Find: "), "/", "\\\\/", "g")
    exec "term ag '" . find_string . "'"
    let find_preview_nr = bufnr("$")
    sleep 100m
    redraw
    let replace_string = substitute(input("Replace with: "), "/", "\\\\/", "g")
    call inputrestore()
    if bufnr("#") != -1 | edit # | else | bp | endif
    exec "bd! " . find_preview_nr
    echo "\n"
    exec "!{ag -0 -l '" . find_string . "' | xargs -0 sed -i -e 's/" . find_string . "/" . replace_string . "/g'}"
endfunction

function! CloseBufferAndGoToAlt(...)
    if &modified
        echohl ErrorMsg | echo "No write since last change!"
        return
    endif

    let cur_buf = get(a:000, 0, bufnr("%"))
    if bufnr("#") != -1 | edit # | else | bp | endif
    exec "bw " . cur_buf
endfunction

let s:last_sourced_config = ""
function! SourceProjectConfig()
    if filereadable(".vim/init.vim")
        let project_config_path = system('realpath -m .vim/init.vim')
        if s:last_sourced_config != project_config_path
            source .vim/init.vim
            let s:last_sourced_config = project_config_path
            echom "Sourced project config: " . project_config_path
        endif
    endif
endfunction

let s:last_sourced_session = ""
function! SourceProjectSession()
    if len(v:argv) == 1 && filereadable(".vim/Session.vim")
        let project_session_path = system('realpath -m .vim/Session.vim')
        if s:last_sourced_session != project_session_path
            source .vim/Session.vim
            let s:last_sourced_session = project_session_path
        endif
    endif
endfunction

function! GetIndentLevel()
    let l:lnum = line(".")
    if l:lnum ==# 0
        return 0
    endif
    let l:indent = cindent(l:lnum)
    return l:indent
endfunction

" Insert the appropriate number of indent chars if there is no text on the
" line, the cursor is on the last column of the line, and current indentation
" level is less than appropriate.
function! FullIndent()
    let [_, l:lnum, l:col, _, _] = getcurpos()
    let l:cur_view = winsaveview()
    normal $
    let l:lastCol = getcurpos()[2]
    normal 0
    let l:first_nonspace = searchpos("\\S", "nc", l:lnum)[1]
    call winrestview(l:cur_view)

    if l:first_nonspace > 0 || l:col < l:lastCol
        call feedkeys("\<Tab>", "n")
        return
    endif

    let l:indent = GetIndentLevel()

    if &et
        if l:indent == 0
            let l:indent = &sw > 0 ? &sw : 4
        endif
        if l:indent < l:col
            call feedkeys("\<Tab>", "n")
            return
        endif
        normal d0x
        execute("call feedkeys('" . repeat(" ", l:indent) . "', 'n')")
    else
        if l:indent == 0
            let l:indent = &ts > 0 ? &ts : 4
        endif
        if l:indent < l:col
            call feedkeys("\<Tab>", "n")
            return
        endif
        let l:ntabs = l:indent / &ts
        let l:nspaces = l:indent - l:ntabs * &ts
        normal d0x
        execute("call feedkeys('" . repeat("\<Tab>", l:ntabs) . repeat(" ", l:nspaces) . "', 'n')")
    endif
endfunction

function! CHADtreeFocus()
    if exists("g:chadtree_winid") && win_id2win(g:chadtree_winid) > 0
        call win_gotoid(g:chadtree_winid)
    else
        let cur_winid = win_getid()
        CHADopen
        while win_getid() == cur_winid
            sleep 1m
        endwhile
        let g:chadtree_winid = win_getid()
        augroup chadtree_focus
            au!
            au WinClosed <buffer> unlet g:chadtree_winid
        augroup END
    endif
endfunction

function! CHADtreeToggle()
    if exists("g:chadtree_winid") && win_id2win(g:chadtree_winid) > 0
        call win_gotoid(g:chadtree_winid)
        wincmd q
    else
        call CHADtreeFocus()
    endif
endfunction

function! MkdpOpenInNewWindow(url)
    exec system("$BROWSER --new-window " . a:url)
endfunction

function! CocJavaClearCacheFunc()
    exec system('rm -rf ~/.config/coc/extensions/coc-java-data/jdt_ws_$(printf "' . getcwd()
                \ . '" | md5sum | awk "{print \$1}")')
endfunction

function! CocJavaExploreCacheFunc()
    let name = system('printf jdt_ws_$(printf "' . getcwd() . '" | md5sum | awk "{print \$1}")')
    echom 'Calculated coc-java cache dir name: ' . name
    exec 'CocCommand explorer --position floating ~/.config/coc/extensions/coc-java-data/' . name
endfunction

function! SplitLineOnPattern(pattern)
    let curLine = line(".")
    let escapedPattern = substitute(a:pattern, "/", "\\\\/", "g")
    exec curLine . "," . curLine . "s/" . escapedPattern . "/" . escapedPattern . "\\r/g"
    noh
endfunction

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echom map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction

function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echom synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfunction

function! s:isdir(dir)
    return !empty(a:dir) && (isdirectory(a:dir) ||
                \ (!empty($SYSTEMDRIVE) && isdirectory('/'.tolower($SYSTEMDRIVE[0]).a:dir)))
endfunction

function! NvimTreeToggleNoFocus()
lua << EOF
    local view = require'nvim-tree.view'
    if view.win_open() then
        view.close()
    else
        view.open()
        vim.cmd("wincmd p")
    end
EOF
endfunction

": }}}

": AUTO COMMANDS {{{

augroup init_vim
    au!
    " nuke netrw brain damage
    au VimEnter * silent! au! FileExplorer *
    au BufEnter *
                \ if <SID>isdir(expand('%'))
                \ |     bd
                \ | endif

    au VimEnter * exec SourceProjectConfig() | exec SourceProjectSession()


    " Restore cursor pos
    au BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
                \ |   exe "normal! g`\"zz"
                \ | endif

    " Highlight yanks
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="Visual", timeout=300}

    " Set quickfix buffer unlisted
    au BufWinEnter quickfix set nobuflisted | setlocal nowrap

    au TermEnter * setlocal nonu nornu

    au TermLeave * setlocal nu rnu
augroup END

": }}}

": MISC {{{

exec SourceProjectConfig()
exec SourceProjectSession()

": }}}

" vim: sw=4 ts=4 et foldmethod=marker foldlevel=0
