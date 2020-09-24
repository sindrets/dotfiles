"      _       _ __        _         
"     (_)___  (_) /__   __(_)___ ___ 
"    / / __ \/ / __/ | / / / __ `__ \
"   / / / / / / /__| |/ / / / / / / /
"  /_/_/ /_/_/\__(_)___/_/_/ /_/ /_/ 
"                                    

set nu
set rnu
set autoindent
set shiftwidth=4
set tabstop=4
set softtabstop=4
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
set updatetime=1000
set backspace=indent,eol,start
set pyx=3
set pyxversion=3
set shada=!,'10,/100,:100,<0,@1,f1,h,s1

if has("termguicolors")
    set termguicolors
endif

" ruler
set colorcolumn=100
highlight ColorColumn ctermbg=0

" render whitespace
set list
set listchars=tab:\ ―►,space:·,nbsp:␣,trail:•,eol:↵,precedes:«,extends:»
set showbreak=⤷\ 

syntax on
syntax sync minlines=3000
filetype plugin indent on

let s:init_extra_path = system("realpath -m " . $MYVIMRC . "/../init_extra.vim")[:-2]
if filereadable(s:init_extra_path)
    exec "source " . s:init_extra_path
endif

let mapleader = " "                             " set the leader key
let g:startify_session_dir="$HOME/.vim/session"
let g:python_recommended_style = 0

let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.2"}

let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.xml'
let g:closetag_filetypes = 'html,xhtml,phtml,xml'

let g:user_emmet_leader_key='<C-Z>'

let g:mkdp_browserfunc = "MkdpOpenInNewWindow"

source ~/.config/nvim/lightline-config.vim
source ~/.config/nvim/chadtree-config.vim

call plug#begin("~/.vim/bundle")
" SYNTAX
Plug 'kevinoid/vim-jsonc'
Plug 'sheerun/vim-polyglot'
Plug 'vim-scripts/TagHighlight'
" BEHAVIOUR
Plug 'terryma/vim-multiple-cursors'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ap/vim-css-color'
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-sleuth'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-abolish'
Plug 'alvan/vim-closetag'
" MISC
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
" THEMES
Plug 'rakr/vim-one'
Plug 'ayu-theme/ayu-vim'
Plug 'kaicataldo/material.vim'
Plug 'phanviet/vim-monokai-pro'
Plug 'tomasiser/vim-code-dark'
Plug 'w0ng/vim-hybrid'
Plug 'chriskempson/base16-vim'
Plug 'nanotech/jellybeans.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'cocopon/iceberg.vim'
Plug 'junegunn/seoul256.vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'arzg/vim-colors-xcode'
" CoC
Plug 'neoclide/coc-css', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-html', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-java', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-pairs', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-python', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile'}
Plug 'iamcco/coc-vimlsp', {'do': 'yarn install --frozen-lockfile'}
call plug#end()

" Theme settings
let ayucolor="dark"
let g:material_terminal_italics = 1
let g:material_theme_style = 'darker'
let g:gruvbox_italic = 1
let g:gruvbox_contrast_dark = "hard"
let g:gruvbox_invert_selection = 0
let base16colorspace = 256
let g:seoul256_background = 234
let g:palenight_terminal_italics=1
set background=dark
colorscheme xcodedark
" Override ruler column from theme
" highlight ColorColumn guibg=#282a2e

" Allow movement through display lines (wrapped lines)
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <expr> <DOWN> v:count == 0 ? 'gj' : '<DOWN>'
nnoremap <expr> <UP> v:count == 0 ? 'gk' : '<UP>'
xnoremap <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> <DOWN> v:count == 0 ? 'gj' : '<DOWN>'
xnoremap <expr> <UP> v:count == 0 ? 'gk' : '<UP>'
inoremap <expr> <DOWN> pumvisible() ? '<DOWN>' : '<C-\><C-O>gj'
inoremap <expr> <UP> pumvisible() ? '<UP>' : '<C-\><C-O>gk'

" Home moves to first non-whitespace on display line
nnoremap <expr> <Home> v:count == 0 ? "g^" : "^"
nnoremap <expr> <End> v:count == 0 ? "g$" : "$"
xnoremap <expr> <Home> v:count == 0 ? "g^" : "^"
xnoremap <expr> <End> v:count == 0 ? "g$" : "$"
inoremap <Home> <C-\><C-O>g^
inoremap <End> <C-\><C-O>g$

" Copy, cut and paste to/from system clipboard
vnoremap <expr> y v:register == '"' ? '"+y' : 'y'
vnoremap <expr> <S-Y> v:register == '"' ? '"+Y' : 'Y'
vnoremap <C-x> "+d
nnoremap <S-P> "+p

" File explorer
map <silent> <Leader>e :call CHADtreeFocus()<CR>
map <silent> <Leader>b :call CHADtreeToggle()<CR>

nnoremap <silent> <Leader>q :q<CR>
inoremap <M-Space> <Esc>

" Navigate buffers
nnoremap  <silent>   <tab> :bn<CR> 
nnoremap  <silent> <s-tab> :bp<CR>
nnoremap <leader><leader> <C-^>zz
nnoremap <silent> <leader>w :call CloseBufferAndGoToAlt()<CR>

" Navigate tabs
map <silent> <Leader><Tab> :tabn<CR>
map <silent> <Leader><S-Tab> :tabp<CR>

" Remap jump forward
nnoremap <C-S> <C-I>

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

" Move lines up/down
nnoremap <A-UP> :m-2<CR>==
nnoremap <A-DOWN> :m+<CR>==
inoremap <A-UP> <ESC>:m-2<CR>==gi
inoremap <A-DOWN> <ESC>:m+<CR>==gi
vnoremap <A-UP> :m '<-2<CR>gv=gv
vnoremap <A-DOWN> :m '>+<CR>gv=gv

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
inoremap <C-H> <C-\><C-O>db
inoremap <C-Del> <C-\><C-O>dw

" Indentation
vmap <lt> <gv
vmap > >gv

" Turn off search highlight until next search
nnoremap <F3> :noh<CR>

" Repeat prev macro
nmap , @@

" Toggle comments
nnoremap <C-\> :call NERDComment(0, "toggle")<CR>
inoremap <C-\> <Esc>:call NERDComment(0, "toggle")<CR>i
vnoremap <C-\> :call NERDComment(0, "toggle")<CR>gv

" FZF
nnoremap <C-P> :call WorkspaceFiles()<CR>
nnoremap <M-b> :Buffers<CR>
nnoremap <C-F> :Ag 

nnoremap <leader>rh :call FindAndReplaceInAll()<CR>

" Open a terminal split
nnoremap <Leader>t :call FocusTerminalSplit()<CR>
nnoremap <silent> <C-L> :call ToggleTerminalSplit()<CR>
inoremap <silent> <C-L> <Esc>:call ToggleTerminalSplit()<CR>
tnoremap <silent> <C-L> <C-\><C-N>:call ToggleTerminalSplit()<CR>

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Notify coc.nvim that <CR> has been pressed.
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gv <C-W>v<Plug>(coc-definition)
nmap <silent> gs <C-W>s<Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>rn <PLug>(coc-rename)
nmap <silent> <F2> <Plug>(coc-rename)
nmap <silent> <leader>f :call CocAction("format")<CR>
nmap <leader>. :CocAction<CR>

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

" Neovim Terminal Colors
" black
let g:terminal_color_0 =   "#222222"
let g:terminal_color_8 =   "#666666"
" red
let g:terminal_color_1 =   "#e84f4f"
let g:terminal_color_9 =   "#d23d3d"
" green
let g:terminal_color_2 =   "#b7ce42"
let g:terminal_color_10 =  "#bde077"
" yellow
let g:terminal_color_3 =   "#fea63c"
let g:terminal_color_11 =  "#ffe863"
" blue
let g:terminal_color_4 =   "#66a9b9"
let g:terminal_color_12 =  "#aaccbb"
" magenta
let g:terminal_color_5 =   "#b7416e"
let g:terminal_color_13 =  "#e16a98"
" cyan
let g:terminal_color_6 =   "#6dc1b6"
let g:terminal_color_14 =  "#42717b"
" white
let g:terminal_color_7 =   "#cccccc"
let g:terminal_color_15 =  "#ffffff"

command! -nargs=+ Rnew call ReadNew(<q-args>)
command! Synsync syntax sync minlines=3000

" Wrapper function to allow exec calls from expressions
function! Exec(cmd)
    exec a:cmd
endfunction

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" Read the output of a command into a new buffer
function! ReadNew(expr)
    enew | set ft=log
    exec "r! " . a:expr
endfunction

function! WorkspaceFiles()
    if !empty(glob("./.git"))
        GFiles --cached --others --exclude-standard
    else
        Files
    endif
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
        au WinClosed <buffer> let g:term_split_height = winheight("%")
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

function! s:show_documentation()
    call CocAction('doHover')
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

function! CocJavaClearCache()
    exec system('rm -rf ~/.config/coc/extensions/coc-java-data/jdt_ws_$(printf "' . getcwd()
                \ . '" | md5sum | awk "{print \$1}")')
endfunction

" AutoCommands

"   Restore cursor pos
autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\"zz"
    \ | endif

"   Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

"   Update NERDtree dir on dir change
" autocmd DirChanged *
"     \ exec SourceProjectConfig()
"     \ | NERDTreeCWD | wincmd p

"   Update NERDtree when new file is written
" let s:should_refresh_tree = 0
" autocmd BufWrite *
"     \ if !filereadable(expand("%:p"))
"     \ |     let s:should_refresh_tree = 1
"     \ | endif

" autocmd BufWritePost *
"     \ if s:should_refresh_tree
"     \ |     NERDTreeRefreshRoot | NERDTreeRefreshRoot
"     \ |     let s:should_refresh_tree = 0
"     \ | endif

function! s:filter_header(lines) abort
    let longest_line   = max(map(copy(a:lines), 'strwidth(v:val)'))
    let centered_lines = map(copy(a:lines),
        \ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
    return centered_lines
endfunction
let s:startify_ascii_header = [
\ '     _   __         _    ___          ',
\ '    / | / /__  ____| |  / (_)___ ___  ',
\ '   /  |/ / _ \/ __ \ | / / / __ `__ \ ',
\ '  / /|  /  __/ /_/ / |/ / / / / / / / ',
\ ' /_/ |_/\___/\____/|___/_/_/ /_/ /_/  ',
\ '                                      ',
\ ]
let g:startify_custom_header = s:filter_header(s:startify_ascii_header)

exec SourceProjectConfig()

" vim: shiftwidth=4 tabstop=4 expandtab
