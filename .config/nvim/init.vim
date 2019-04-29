
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
set backspace=indent,eol,start
set termguicolors

syntax on
filetype plugin on

let mapleader = " "						" set the leader key
let g:airline_powerline_fonts = 1       " enable powerline symbols
let g:airline_theme='powerlineish'      " set airline theme
let NERDTreeShowHidden=1                " show dot files in NERDtree
let g:startify_session_dir="/home/sindrets/.vim/session"

let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

call plug#begin("~/.vim/bundle")

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'Yggdroot/indentLine'
Plug 'anned20/vimsence'
Plug 'jiangmiao/auto-pairs'
Plug 'mhinz/vim-startify'
" THEMES
Plug 'rakr/vim-one'
Plug 'ayu-theme/ayu-vim'

call plug#end()

" Theme settings
let ayucolor="mirage"
let g:airline_theme="ayu_mirage"
colorscheme ayu
set background=dark

" Copy and paste to/from system clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <C-C> "+y
map <silent> <Leader>e :NERDTreeFocus<CR>
map <silent> <Leader>b :NERDTreeToggle<CR>
" map <silent> <Leader><Tab> :tabn<CR>

" Navigate buffers
nnoremap  <silent>   <tab> :bn<CR> 
nnoremap  <silent> <s-tab> :bp<CR>

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

" Turn off search highlight until next search
nnoremap <F3> :noh<CR>

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

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

