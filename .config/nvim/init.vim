"      _       _ __        _         
"     (_)___  (_) /__   __(_)___ ___ 
"    / / __ \/ / __/ | / / / __ `__ \
"   / / / / / / /__| |/ / / / / / / /
"  /_/_/ /_/_/\__(_)___/_/_/ /_/ /_/ 
"                                    

set nu
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
set backspace=indent,eol,start
set termguicolors
set pyx=3
set pyxversion=3
set shada=!,'10,/100,:100,<0,@1,f1,h,s1

" ruler
set colorcolumn=100
highlight ColorColumn ctermbg=0

" render whitespace
set list
set listchars=tab:\ ―→,space:·,nbsp:␣,trail:•,eol:↵,precedes:«,extends:»
set showbreak=⤷\ 

syntax on
filetype plugin indent on

let mapleader = " "                             " set the leader key
let g:airline_powerline_fonts = 1               " enable powerline symbols
let g:python_recommended_style = 0
let g:airline_theme='powerlineish'              " set airline theme
let g:airline#extensions#tabline#enabled = 1    " enable airline tabline
let NERDTreeShowHidden=1                        " show dot files in NERDtree
let g:startify_session_dir="$HOME/.vim/session"
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.2"}
let g:NERDToggleCheckAllLines = 1
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'

let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
let g:airline#extensions#tabline#ignore_bufadd_pat = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

call plug#begin("~/.vim/bundle")
" SYNTAX
Plug 'kevinoid/vim-jsonc'
Plug 'sheerun/vim-polyglot'
" BEHAVIOUR
Plug 'terryma/vim-multiple-cursors'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ap/vim-css-color'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-sleuth'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-abolish'
" MISC
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ananagame/vimsence'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
" THEMES
Plug 'rakr/vim-one'
Plug 'ayu-theme/ayu-vim'
Plug 'kaicataldo/material.vim'
Plug 'phanviet/vim-monokai-pro'
Plug 'tomasiser/vim-code-dark'
Plug 'w0ng/vim-hybrid'
Plug 'chriskempson/base16-vim'
Plug 'nanotech/jellybeans.vim'
Plug 'morhetz/gruvbox'
" CoC
Plug 'neoclide/coc-css', {'do': 'yarn install --frozen-lockfile'}
Plug 'weirongxu/coc-explorer', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-html', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-java', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-pairs', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-python', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}

call plug#end()

" Theme settings
let g:airline_theme="codedark"
"let ayucolor="mirage"
let g:material_terminal_italics = 1
let g:material_theme_style = 'darker'
let g:gruvbox_italic = 1
let base16colorspace=256
set background=dark
colorscheme gruvbox
" Override ruler column from theme
" highlight ColorColumn guibg=#282a2e

" Copy, cut and paste to/from system clipboard
noremap <Leader>y "+y
noremap <C-C> "+y
vnoremap <C-x> "+d

map <silent> <Leader>e :CocCommand explorer --no-toggle<CR>
map <silent> <Leader>b :CocCommand explorer --toggle<CR>

" Navigate buffers
nnoremap  <silent>   <tab> :bn<CR> 
nnoremap  <silent> <s-tab> :bp<CR>
nnoremap <leader><leader> <C-^>zz
nnoremap <silent> <leader>w :call CloseBufferAndGoToAlt()<CR>

" Navigate tabs
map <silent> <Leader><Tab> :tabn<CR>
map <silent> <Leader><S-Tab> :tabp<CR>

" Home moves to first non-whitespace char
noremap <Home> ^
inoremap <Home> <Esc>^i

" Move lines up/down
nnoremap <A-UP> :m-2<CR>==
nnoremap <A-DOWN> :m+<CR>==
inoremap <A-UP> <ESC>:m-2<CR>==gi
inoremap <A-DOWN> <ESC>:m+<CR>==gi
vnoremap <A-UP> :m '<-2<CR>gv=gv
vnoremap <A-DOWN> :m '>+1<CR>gv=gv

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

" Indentation
vmap <lt> <gv
vmap > >gv

" Turn off search highlight until next search
nnoremap <F3> :noh<CR>

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

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Notify coc.nvim that <CR> has been pressed.
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>rn <PLug>(coc-rename)
nmap <silent> <F2> <Plug>(coc-rename)
nmap <silent> <leader>f :call CocAction("format")<CR>
nmap <leader>. :CocAction<CR>

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

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

function! FocusTerminalSplit()
    let term_buf_id = GetBufferWithPattern("term_split")
    if term_buf_id != -1
        if exists("g:term_split_winid") && win_id2win(g:term_split_winid) > 0
            call win_gotoid(g:term_split_winid)
        else
            100 wincmd j
            belowright split
            exec "res " . min([16, float2nr(&lines / 2)])
            let g:term_split_winid = win_getid()
        endif
        exec "buffer " . term_buf_id
        startinsert
    else
        belowright split | term
        set nobuflisted | file! term_split
        let g:term_split_winid = win_getid()
        exec "res " . min([16, float2nr(&lines / 2)])
        startinsert
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

function! s:show_documentation()
    if &filetype == 'vim'
        exec 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

" AutoCommands

"   Restore cursor pos
autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\"zz"
        \ | endif

"   Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

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

" vim: shiftwidth=4 tabstop=4 expandtab
