let g:colorscheme = "horizon"

let ayucolor="dark"
let g:material_terminal_italics = 1
let g:material_theme_style = 'darker'
let g:gruvbox_italic = 1
let g:gruvbox_contrast_dark = "medium"
let g:gruvbox_invert_selection = 0
let base16colorspace = 256
let g:seoul256_background = 234
let g:palenight_terminal_italics=1
let g:neodark#background = '#202020'
let g:neodark#use_256color = 0
let g:neodark#solid_vertsplit = 1
set background=dark
execute("colorscheme " . g:colorscheme)

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

function! SaneDiffDefaults()
    hi DiffAdd    ctermbg=4 guifg=#acf2e4 guibg=#243330
    hi DiffChange ctermbg=5 guifg=#ffa14f guibg=NONE
    hi DiffDelete ctermfg=12 ctermbg=6 guifg=#ff8170 guibg=#3b2d2b
    hi DiffText   ctermbg=9 guifg=#ffa14f guibg=#382e27
    hi link diffAdded       DiffAdd
    hi link diffChanged     DiffChange
    hi link diffRemoved     DiffDelete
    hi link diffBDiffer     WarningMsg
    hi link diffCommon      WarningMsg
    hi link diffDiffer      WarningMsg
    hi link diffFile        Directory
    hi link diffIdentical   WarningMsg
    hi link diffIndexLine   Number
    hi link diffIsA         WarningMsg
    hi link diffNoEOL       WarningMsg
    hi link diffOnly        WarningMsg
endfunction

" Colorscheme overrides
if g:colorscheme ==# "codedark"
    hi NonText guibg=NONE
    call SaneDiffDefaults()

elseif g:colorscheme ==# "tender"
    hi Visual cterm=NONE ctermbg=237 gui=NONE guibg=#293b44
    hi VertSplit ctermfg=234 ctermbg=234 guifg=#202020 guibg=NONE
    hi Search cterm=bold ctermfg=15 gui=bold ctermfg=250 ctermbg=242 guifg=#dddddd guibg=#7a6a24
    call SaneDiffDefaults()
elseif g:colorscheme ==# "horizon"
    hi NonText guibg=NONE
    hi VertSplit cterm=bold ctermfg=233 ctermbg=NONE gui=bold guifg=#0f1117 guibg=NONE
    call SaneDiffDefaults()
endif
