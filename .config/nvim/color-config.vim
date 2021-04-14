let g:colorscheme = "zephyr"

let ayucolor="dark"
let g:material_terminal_italics = 1
let g:material_theme_style = 'darker'
let g:gruvbox_italic = 1
let g:gruvbox_contrast_dark = "medium"
let g:gruvbox_invert_selection = 0
let g:gruvbox_material_background = 'medium'
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_diagnostic_line_highlight = 1
let base16colorspace = 256
let g:seoul256_background = 234
let g:palenight_terminal_italics=1
let g:neodark#background = '#202020'
let g:neodark#use_256color = 0
let g:neodark#solid_vertsplit = 1
let g:spacegray_use_italics = 1
let g:spacegray_low_contrast = 1
set background=dark
execute("colorscheme " . g:colorscheme)

" Neovim Terminal Colors
" black
let g:terminal_color_0  = "#222222"
let g:terminal_color_8  = "#666666"
" red
let g:terminal_color_1  = "#e84f4f"
let g:terminal_color_9  = "#d23d3d"
" green
let g:terminal_color_2  = "#b7ce42"
let g:terminal_color_10 = "#bde077"
" yellow
let g:terminal_color_3  = "#fea63c"
let g:terminal_color_11 = "#ffe863"
" blue
let g:terminal_color_4  = "#66a9b9"
let g:terminal_color_12 = "#aaccbb"
" magenta
let g:terminal_color_5  = "#b7416e"
let g:terminal_color_13 = "#e16a98"
" cyan
let g:terminal_color_6  = "#6dc1b6"
let g:terminal_color_14 = "#42717b"
" white
let g:terminal_color_7  = "#cccccc"
let g:terminal_color_15 = "#ffffff"

" A lot of vim colorschemes provide some wild defaults for diff colors. This
" function sets the diff colors to some more sane defaults that at least looks
" quite pleasant in most colorschemes.
function! SaneDiffDefaults()
    hi DiffAdd    ctermfg=234 ctermbg=114 guifg=#1e1e1e guibg=#98c379
    hi DiffChange cterm=underline ctermfg=180 gui=underline guifg=#e5c07b
    hi DiffDelete ctermfg=234 ctermbg=168 guifg=#1e1e1e guibg=#e06c75
    hi DiffText   ctermfg=234 ctermbg=180 guifg=#1e1e1e guibg=#e5c07b
    hi! link       diffAdded     DiffAdd
    hi! link       diffChanged   DiffChange
    hi! link       diffRemoved   DiffDelete
    hi! link       diffBDiffer   WarningMsg
    hi! link       diffCommon    WarningMsg
    hi! link       diffDiffer    WarningMsg
    hi! link       diffFile      Directory
    hi! link       diffIdentical WarningMsg
    hi! link       diffIndexLine Number
    hi! link       diffIsA       WarningMsg
    hi! link       diffNoEOL     WarningMsg
    hi! link       diffOnly      WarningMsg
endfunction

hi! def GitDirty guifg=#e2c08d
hi! NonText gui=nocombine

" Lsp
hi! link LspReferenceText Visual
hi! link LspReferenceRead Visual
hi! link LspReferenceWrite Visual
hi! LspDiagnosticsSignHint guifg=#36d0e0
hi! LspDiagnosticsVirtualTextHint guifg=#36d0e0
hi! LspDiagnosticsUnderlineHint cterm=underline gui=undercurl guisp=#36d0e0

" Colorscheme tweaks
if g:colorscheme ==# "codedark"
    hi NonText guibg=NONE
    call SaneDiffDefaults()

elseif g:colorscheme ==# "tender"
    hi   Visual             cterm=NONE  ctermbg=237 gui=NONE      guibg=#293b44
    hi   VertSplit          ctermfg=234 ctermbg=234 guifg=#202020 guibg=NONE
    hi   Search             cterm=bold  ctermfg=15  gui=bold      ctermfg=250   ctermbg=242 guifg=#dddddd guibg=#7a6a24
    call SaneDiffDefaults()

elseif g:colorscheme ==# "horizon"
    hi NonText      ctermfg=233 ctermbg=233   guifg=#414559 guibg=NONE
    hi VertSplit    cterm=bold  ctermfg=233   ctermbg=NONE  gui=bold      guifg=#0f1117 guibg=NONE
    hi Pmenu        ctermfg=255 ctermbg=236   guibg=#272c42 guifg=#eff0f4
    hi PmenuSel     ctermfg=255 ctermbg=240   guibg=#5b6389
    hi PmenuSbar    ctermbg=236 guibg=#3d425b
    hi PmenuThumb   ctermbg=233 guibg=#0f1117
    hi CursorLineNr cterm=bold  gui=bold      ctermfg=48    guifg=#09f7a0 ctermbg=NONE  guibg=NONE
    hi QuickFixLine ctermbg=235 ctermfg=NONE  guibg=#335172 guifg=NONE
    hi link         vimVar      NONE
    hi link         vimFuncVar  NONE
    hi link         vimUserFunc NONE
    hi link         jsonQuote   NONE
    call SaneDiffDefaults()

elseif g:colorscheme ==# "monokai_pro"
    hi NonText ctermfg=240 ctermbg=236 guifg=#5b595c guibg=None
    hi VertSplit      ctermfg=59 ctermbg=None guifg=#696769 guibg=None
    hi Pmenu          ctermfg=150 guifg=#a9dc76 guibg=#252226
    hi PmenuSel       ctermbg=59 guibg=#403e41
    hi PmenuSbar      ctermbg=248 guibg=Grey
    hi PmenuThumb     ctermbg=15 guibg=White
    hi CursorLineNr   ctermfg=11 gui=bold guifg=Yellow ctermbg=None guibg=#423f42
    hi SignColumn     ctermbg=237 guibg=#423f42
    hi FoldColumn     ctermfg=14 ctermbg=242 guifg=Cyan guibg=#423f42
    hi QuickFixLine   guibg=#714754 guifg=NONE
    hi Search         guifg=#ffd866 gui=bold,underline
    hi link         vimVar      NONE
    hi link         vimFuncVar  NONE
    hi link         vimUserFunc NONE
    hi link         jsonQuote   NONE
    call SaneDiffDefaults()

elseif g:colorscheme ==# "gruvbox-material"
    hi CursorLineNr gui=bold guifg=#a9b665
    call SaneDiffDefaults()

elseif g:colorscheme ==# "predawn"
    hi NonText     ctermfg=235 ctermbg=235 guifg=#3c3c3c guibg=None
    hi CursorLine  ctermbg=237 guibg=#303030
    hi SignColumn  ctermfg=14 ctermbg=242 guifg=#8c8c8c guibg=#3c3c3c
    hi link         vimVar      NONE
    hi link         vimFuncVar  NONE
    hi link         vimUserFunc NONE
    hi link         jsonQuote   NONE
    hi GitGutterAdd   ctermfg=231 ctermbg=242 guifg=#46830d guibg=None
    hi GitGutterChange ctermfg=231 ctermbg=242 guifg=#243958 guibg=None
    hi GitGutterDelete ctermfg=88 ctermbg=242 guifg=#8b0808 guibg=None

elseif g:colorscheme ==# "nvcode"
    hi CocExplorerGitIgnored ctermfg=241 guifg=#5C6370
    hi! link GitGutterAdd diffAdded
    hi! link GitGutterRemoved diffRemoved
    hi! link GitGutterChange diffChanged
    hi link         vimVar      NONE
    hi link         vimFuncVar  NONE
    hi link         vimUserFunc NONE

elseif g:colorscheme ==# "onedark"
    hi! link GitGutterAdd diffAdded
    hi! link GitGutterRemoved diffRemoved
    hi! link GitGutterChange diffChanged
    " hi link         vimFuncVar  NONE
    " hi link         vimUserFunc NONE

elseif g:colorscheme ==# "zephyr"
    hi! Visual guifg=NONE guibg=#393e49

endif

if exists('g:lightline.colorscheme') && g:lightline.colorscheme ==# "horizon"
    let s:gray1 = [ '#2e303e', 235 ]
    let s:gray2 = [ '#141414', 233 ]
    let s:white = [ '#6c6f93', 242 ]
    let s:cyan = [ '#25b0bc', 37 ]
    let s:green = [ '#09f7a0', 48 ]
    let s:purple = [ '#b877db', 171 ]
    let s:red = [ '#e95678', 203 ]
    let s:yellow = [ '#09f7a0', 150 ]
    let s:salmon = [ '#fab795', 209 ]

    let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}
    let s:p.normal.left = [ [ s:gray1, s:salmon ], [ s:red, s:gray2 ] ]
    let s:p.normal.right = [ [ s:gray1, s:salmon ], [ s:gray1, s:yellow ] ]
    let s:p.inactive.right = [ [ s:gray1, s:gray2 ], [ s:white, s:gray1 ] ]
    let s:p.inactive.left =  [ [ s:cyan, s:gray1 ], [ s:white, s:gray1 ] ]
    let s:p.insert.left = [ [ s:gray1, s:purple ], [ s:green, s:gray2 ] ]
    let s:p.insert.right = [ [ s:gray1, s:purple ], [ s:gray1, s:yellow ] ]
    let s:p.replace.left = [ [ s:gray1, s:red ], [ s:cyan, s:gray2 ] ]
    let s:p.visual.left = [ [ s:gray1, s:cyan ], [ s:purple, s:gray2 ] ]
    let s:p.visual.right = [ [ s:gray1, s:cyan ], [ s:gray1, s:yellow ] ]
    let s:p.normal.middle = [ [ s:white, s:gray2 ] ]
    let s:p.inactive.middle = [ [ s:white, s:gray2 ] ]
    let s:p.tabline.left = [ [ s:cyan, s:gray2 ] ]
    let s:p.tabline.tabsel = [ [ s:green, s:gray1 ] ]
    let s:p.tabline.middle = [ [ s:yellow, s:gray2 ] ]
    let s:p.tabline.right = copy(s:p.normal.right)
    let s:p.normal.error = [ [ s:red, s:gray1 ] ]
    let s:p.normal.warning = [ [ s:yellow, s:gray1 ] ]

    let g:lightline#colorscheme#horizon#palette = lightline#colorscheme#flatten(s:p)
endif
