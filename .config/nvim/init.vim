
set nu
set autoindent
set shiftwidth=4
set tabstop=4
set softtabstop=4
set ignorecase
set smartcase
set showcmd
set mouse=a
set hidden
set wrap linebreak nolist
set backspace=indent,eol,start
set termguicolors
set pyx=3
set pyxversion=3

" ruler
set colorcolumn=100
highlight ColorColumn ctermbg=0 guibg=#292929

" render whitespace
set list
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:↵,precedes:«,extends:»

syntax on
filetype plugin on

let mapleader = " "						" set the leader key
let g:airline_powerline_fonts = 1				" enable powerline symbols
let g:python_recommended_style = 0
let g:airline_theme='powerlineish'				" set airline theme
let g:airline#extensions#tabline#enabled = 1			" enable airline tabline
let NERDTreeShowHidden=1					" show dot files in NERDtree
let g:startify_session_dir="$HOME/.vim/session"
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.2"}
let g:NERDToggleCheckAllLines = 1
let g:NERDSpaceDelims = 1

let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
let g:airline#extensions#tabline#ignore_bufadd_pat = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

call plug#begin("~/.vim/bundle")
" SYNTAX
Plug 'leafgarland/typescript-vim'
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
Plug 'mustache/vim-mustache-handlebars'
" BEHAVIOUR
Plug 'terryma/vim-multiple-cursors'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'ap/vim-css-color'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-sleuth'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
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

call plug#end()

" Theme settings
let g:airline_theme="ayu_mirage"
"let ayucolor="mirage"
let g:material_terminal_italics = 1
let g:material_theme_style = 'darker'
colorscheme monokai_pro
set background=dark
" Override ruler column from theme
highlight ColorColumn guibg=#292929

" Copy, cut and paste to/from system clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <C-C> "+y
vnoremap <C-x> "+d

map <silent> <Leader>e :NERDTreeFocus<CR>
map <silent> <Leader>b :NERDTreeToggle<CR>

" Navigate buffers
nnoremap  <silent>   <tab> :bn<CR> 
nnoremap  <silent> <s-tab> :bp<CR>

" Navigate tabs
map <silent> <Leader><Tab> :tabn<CR>
map <silent> <Leader><S-Tab> :tabp<CR>

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
nnoremap <C-P> :Files .<CR>
nnoremap <C-F> :Ag 

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

noremap <F2> <Plug>(coc-rename)
noremap <F12> :call CocAction("jumpDefinition")<CR>

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

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

