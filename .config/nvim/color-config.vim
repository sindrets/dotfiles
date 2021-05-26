let g:colorscheme = "tokyonight"

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
let g:tokyonight_style = "night"
let g:tokyonight_sidebars = [ "DiffviewFiles" ]
set background=dark

" Neovim Terminal Colors
function! ApplyTerminalColorDefaults() 
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
endfunction

augroup init_colors
    au!
    au ColorScheme * call ApplyColorTweaks()
augroup END

" A lot of vim colorschemes provide some wild defaults for diff colors. This
" function sets the diff colors to some more sane defaults that at least looks
" quite pleasant in most colorschemes.
function! SaneDiffDefaults()
    hi DiffAdd    ctermfg=234 ctermbg=114 guibg=#26332c guifg=NONE
    hi DiffChange cterm=underline ctermfg=180 guibg=#273842 guifg=NONE
    hi DiffDelete ctermfg=234 ctermbg=168 guibg=#572E33 guifg=NONE
    hi DiffText   ctermfg=234 ctermbg=180 guibg=#314753 guifg=NONE
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
" hi! LspDiagnosticsSignHint guifg=#36d0e0
" hi! LspDiagnosticsVirtualTextHint guifg=#36d0e0
" hi! LspDiagnosticsUnderlineHint cterm=underline gui=undercurl guisp=#36d0e0

" Colorscheme tweaks
function! ApplyColorTweaks()
    let g:colorscheme = g:colors_name

    hi! LspDiagnosticsDefaultError gui=bold
    hi! LspDiagnosticsDefaultWarning gui=bold
    hi! LspDiagnosticsDefaultHint gui=bold
    hi! LspDiagnosticsDefaultInformation gui=bold

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
        call SaneDiffDefaults()

    elseif g:colorscheme ==# "zephyr"
        hi! Visual guifg=NONE guibg=#393e49

    elseif g:colorscheme ==# "tokyonight"
        hi! link ColorColumn CursorLine
        hi! link NvimTreeFolderIcon NormalFloat
        hi! link NvimTreeFolderName Directory
        hi DiffAdd    guibg=#283B4D guifg=NONE
        hi DiffChange guibg=#283B4D guifg=NONE
        hi DiffDelete guibg=#3C2C3C guifg=#573f57 gui=bold
        hi DiffText   guibg=#365069 guifg=NONE
        hi! link DiffviewNormal NormalSB
        " hi! BufferlineFill guibg=#131620
        " call SaneDiffDefaults()

    endif
endfunction

execute("colorscheme " . g:colorscheme)
