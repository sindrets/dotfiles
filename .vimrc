
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

syntax on

let mapleader = " "						" set the leader key
let g:airline_powerline_fonts = 1      " enable powerline symbols
let g:airline_theme='powerlineish'      " set airline theme
let NERDTreeShowHidden=1                " show dot files in NERDtree

call plug#begin("~/.vim/bundle")

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'Yggdroot/indentLine'
Plug 'anned20/vimsence'
Plug 'jiangmiao/auto-pairs'

call plug#end()

set background=dark

set t_8b=[48;2;%lu;%lu;%lum
set t_8f=[38;2;%lu;%lu;%lum

" Copy and paste to/from system clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <C-C> "+y
map <silent> <Leader>e :NERDTreeFocus<CR>
map <silent> <Leader>b :NERDTreeToggle<CR>
map <silent> <Leader><Tab> :tabn<CR>

