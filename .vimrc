
set nu
set autoindent
set shiftwidth=4
set tabstop=4
set softtabstop=4
set ignorecase
set smartcase
set showcmd
set mouse=a

syntax on

let mapleader = " "						" set the leader key
"let g:airline_powerline_fonts = 1      " enable powerline symbols
let g:airline_theme='powerlineish'      " set airline theme
let NERDTreeShowHidden=1                " show dot files in NERDtree

call plug#begin("~/.vim/bundle")

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'

call plug#end()

" CURSOR SHAPE
let &t_SI = "\<Esc>]50;CursorShape=1\x7"	" INSERT mode
let &t_SR = "\<Esc>]50;CursorShape=2\x7"	" REPLACE mode
let &t_EI = "\<Esc>]50;CursorShape=0\x7"	" NORMAL mode (ELSE)


" Copy and paste to/from system clipboard
noremap <Leader>y "+y
noremap <Leader>p "+p
noremap <C-C> "+y
map <silent> <Leader>e :NERDTreeFocus<CR>
map <silent> <Leader>b :NERDTreeToggle<CR>
map <silent> <Leader><Tab> :tabn<CR>

