let g:lightline = {
            \   'colorscheme': 'one',
            \   'active': {
            \       'left': [
            \           [ 'mode', 'paste' ],
            \           [ 'gitbranch', 'readonly', 'filename' ] 
            \       ],
            \       'right': [
            \           [ 'lineinfo' ],
            \           [ 'percent' ],
            \           [ 'filetype', 'fileencoding' ]
            \       ]
            \   },
            \   'component': {
            \   },
            \   'component_function': {
            \       "mode": "LightlineMode",
            \       'gitbranch': 'LightlineGitbranch',
            \       "fileencoding": "LightlineFileencoding",
            \   },
            \   'component_expand': {
            \       "buffers": "lightline#bufferline#buffers",
            \       "lineinfo": "LightlineLineinfo",
            \       "percent": "LightlinePercent",
            \   },
            \   'component_type': {
            \       'buffers': 'tabsel'
            \   },
            \   "separator": {
            \       'left': '', 'right': ''
            \   },
            \   "subseparator": {
            \       'left': '', 'right': '' 
            \   },
            \   "tabline": {
            \       'left': [ ['buffers'] ],
            \       "right": []
            \   }
            \ }

function! LightlineShouldIgnore()
    return &ft == "CHADTree"
endfunction

function! LightlineMode()
    return LightlineShouldIgnore() ? "" : lightline#mode()
endfunction

function! LightlineGitbranch()
    return LightlineShouldIgnore() ? "" : FugitiveHead()
endfunction

function! LightlineLineinfo()
    return LightlineShouldIgnore() ? "" : '%L  %l:%-2v'
endfunction

function! LightlinePercent()
    return LightlineShouldIgnore() ? "" : '%p%%'
endfunction

function! LightlineFiletype()
    return LightlineShouldIgnore() ? "" : '%{&ft!=#""?&ft:"no ft"}'
endfunction

function! LightlineFileencoding()
    if LightlineShouldIgnore() || winwidth(0) < 70
        return ""
    endif

    let result = (&fenc !=# '' ? &fenc : &enc)
    if &ff == "unix"
        let result .= " "
    elseif &ff == "dos"
        let result .= " "
    elseif &ff == "mac"
        let result .= " "
    endif

    return result
endfunction

set showtabline=2  " Show tabline

" vim: shiftwidth=4 et
