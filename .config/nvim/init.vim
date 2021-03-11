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
set pyx=3
set pyxversion=3
set shada=!,'10,/100,:100,<0,@1,f1,h,s1

if has("termguicolors")
    set termguicolors
endif

" ruler
set colorcolumn=100

" render whitespace
set list
set listchars=tab:\ ――,space:·,nbsp:␣,trail:•,eol:↵,precedes:«,extends:»
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
let g:startify_session_dir="$HOME/.vim/session"
let g:python_recommended_style = 0

let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": get(split($TMUX, ","), 0), "target_pane": ":.2"}

let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'

let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.xml'
let g:closetag_filetypes = 'html,xhtml,phtml,xml'

let g:user_emmet_leader_key='<C-Z>'

let g:mkdp_browserfunc = "MkdpOpenInNewWindow"

if executable('ag')
    let g:ackprg = 'ag --vimgrep'
endif

if isdirectory(expand('%'))
    exec "cd " . expand("%")
endif

source ~/.config/nvim/lightline-config.vim
" source ~/.config/nvim/chadtree-config.vim

": }}}

": PLUG {{{

function FuncCocPlug(repo)
    execute "Plug '" . a:repo . "',  {'do': 'yarn install --frozen-lockfile'}"
endfunction

command! -nargs=1 CocPlug call FuncCocPlug(<args>)

call plug#begin("~/.vim/plug")
" SYNTAX
Plug 'kevinoid/vim-jsonc'
Plug 'sheerun/vim-polyglot'
" BEHAVIOUR
Plug 'terryma/vim-multiple-cursors'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-sleuth'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'akinsho/nvim-bufferline.lua'
Plug 'mileszs/ack.vim'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-abolish'
Plug 'alvan/vim-closetag'
Plug 'Rasukarusan/nvim-block-paste'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'
" MISC
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
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
Plug 'shinchu/lightline-gruvbox.vim'
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
" CoC
CocPlug 'neoclide/coc-css'
CocPlug 'neoclide/coc-html'
CocPlug 'neoclide/coc-java'
CocPlug 'neoclide/coc-json'
CocPlug 'neoclide/coc-pairs'
CocPlug 'neoclide/coc-python'
CocPlug 'neoclide/coc-tsserver'
CocPlug 'neoclide/coc-prettier'
CocPlug 'neoclide/coc-highlight'
CocPlug 'neoclide/coc-snippets'
CocPlug 'iamcco/coc-vimlsp'
CocPlug 'weirongxu/coc-explorer'
CocPlug 'josa42/coc-go'
call plug#end()

" Theme settings
source ~/.config/nvim/color-config.vim

luafile ~/.config/nvim/lua/treesitter-config.lua
luafile ~/.config/nvim/lua/telescope-config.lua
luafile ~/.config/nvim/lua/nvim-bufferline-config.lua

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
map <silent> <Leader>e :CocCommand explorer --no-toggle<CR>
map <silent> <Leader>b :CocCommand explorer --toggle<CR>

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
" vnoremap <A-UP> <Cmd>'<,'>m '<-2 \| normal! gv=gv<CR>
" vnoremap <A-DOWN> <Cmd>'<,'>m '>+ \| normal! gv=gv<CR>

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
inoremap <C-\> <Esc>:call NERDComment(0, "toggle")<CR>i
vnoremap <C-\> :call NERDComment(0, "toggle")<CR>gv

" Telescope
nnoremap <C-P> <Cmd>call WorkspaceFiles()<CR>
nnoremap <M-b> <Cmd>Telescope buffers<CR>
nnoremap <M-f> <Cmd>Telescope live_grep<CR>
" nnoremap <C-P> :call WorkspaceFiles()<CR>
" nnoremap <M-b> :Buffers<CR>
" nnoremap <C-F> :Ack! 

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
nmap <silent> gV <C-W>v<Plug>(coc-definition)zz
nmap <silent> gs <C-W>s<Plug>(coc-definition)zz
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>rn <PLug>(coc-rename)
nmap <silent> <F2> <Plug>(coc-rename)
nmap <silent> <leader>f :call CocAction("format")<CR>
nmap <leader>. :CocAction<CR>
nmap <M-c> :call CocAction("pickColor")<CR>
nnoremap <M-O> :CocCommand editor.action.organizeImport<CR>
nnoremap <M-t> :CocList symbols<CR>

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

nnoremap <silent> <leader>d :GitGutterPreviewHunk<CR>

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

inoremap <silent> <Tab> <Cmd>call FullIndent()<CR>

" Show highlight group under cursor
nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

": }}}

": COMMANDS {{{

command! -nargs=+ Rnew call ReadNew(<q-args>)
command! Ssync syntax sync minlines=3000
command! DiffSaved call FuncDiffSaved()
command! CocJavaClearCache call CocJavaClearCacheFunc()
command! CocJavaExploreCache call CocJavaExploreCacheFunc()
command! -nargs=1 SplitOn call SplitLineOnPattern(<args>)
command! ExecuteSelection call execute(GetVisualSelection())

": }}}

": FUNCTIONS {{{
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

function! WorkspaceFiles()
    if !empty(glob("./.git"))
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

function! MakeSession()
    silent !mkdir -p .vim
    silent mks! .vim/Session.vim
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
    if filereadable(".vim/Session.vim")
        let project_session_path = system('realpath -m .vim/Session.vim')
        if s:last_sourced_session != project_session_path
            source .vim/Session.vim
            let s:last_sourced_session = project_session_path
        endif
    endif
endfunction

function! s:show_documentation()
    call CocAction('doHover')
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

function! s:isdir(dir)
    return !empty(a:dir) && (isdirectory(a:dir) ||
                \ (!empty($SYSTEMDRIVE) && isdirectory('/'.tolower($SYSTEMDRIVE[0]).a:dir)))
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

    " Highlight the symbol and its references when holding the cursor.
    au CursorHold * silent call CocActionAsync('highlight')

    " Highlight yanks
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="Visual", timeout=300}

    " Set quickfix buffer unlisted
    au BufWinEnter quickfix set nobuflisted | setlocal nowrap

    au TermEnter * setlocal nonu nornu

    au TermLeave * setlocal nu rnu
augroup END

": }}}

": MISC {{{

function! s:filter_header(lines) abort
    let longest_line   = max(map(copy(a:lines), 'strwidth(v:val)'))
    let centered_lines = map(copy(a:lines),
                \ 'repeat(" ", (&columns / 2) - (longest_line / 2)) . v:val')
    return centered_lines
endfunction
let s:startify_ascii_header = [
\ '  ⣠⣾⣄⠀⠀⠀⢰⣄⠀                                  ',
\ '⠀⣾⣿⣿⣿⣆⠀⠀⢸⣿⣷ ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡿⠀⠀⠀⠀⠀⠀⠀ ⠀⠀⠀',
\ ' ⣿⣿⡟⢿⣿⣧⡀⢸⣿⣿ ⠀⣠⠴⠶⠦⡄⠀⢀⡤⠶⠶⣤⡀⣶⣦⠀⠀⢠⣶⡖⣶⣶⠀⣶⣦⣶⣶⣦⣠⣶⣶⣶⡄',
\ ' ⣿⣿⡇⠈⢻⣿⣷⣼⣿⣿ ⢸⣇⣀⣀⣀⣹⢠⡟⠀⠀⠀⠈⣷⠘⣿⣇⠀⣾⡿⠀⣿⣿⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿',
\ ' ⢿⣿⡇⠀⠀⠹⣿⣿⣿⡿ ⢸⡄⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀⣿⠀⠹⣿⣼⣿⠁⠀⣿⣿⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿',
\ ' ⠀⠙⠇⠀⠀⠀⠘⠿⠋⠀ ⠀⠛⠦⠤⠴⠖⠀⠙⠦⠤⠤⠞⠁⠀⠀⠻⠿⠃⠀⠀⠿⠿⠀⠿⠿⠀⠀⠿⠿⠀⠀⠿⠿',
\ ]
let g:startify_custom_header = s:filter_header(s:startify_ascii_header)

exec SourceProjectConfig()
exec SourceProjectSession()

": }}}

" vim: sw=4 ts=4 et foldmethod=marker foldlevel=0
