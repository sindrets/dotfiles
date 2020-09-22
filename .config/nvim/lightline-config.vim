let g:lightline = {
            \   "colorscheme": "one",
            \   "active": {
            \       "left": [
            \           [ "mode", "paste" ],
            \           [ "gitbranch", "readonly", "filename" ] 
            \       ],
            \       "right": [
            \           [ "lineinfo" ],
            \           [ "percent" ],
            \           [ "filetype", "fileencoding" ]
            \       ]
            \   },
            \   "tabline": {
            \       "left": [ ["buffers"] ],
            \       "right": [ ["time"] ]
            \   },
            \   "component": {
            \   },
            \   "component_function": {
            \       "mode": "LightlineMode",
            \       "filename": "LightlineFilename",
            \       "gitbranch": "LightlineGitbranch",
            \       "fileencoding": "LightlineFileencoding",
            \       "time": "LightlineTime",
            \   },
            \   "component_expand": {
            \       "buffers": "lightline#bufferline#buffers",
            \       "lineinfo": "LightlineLineinfo",
            \       "percent": "LightlinePercent",
            \       "filetype": "LightlineFiletype",
            \   },
            \   "component_type": {
            \       "buffers": "tabsel"
            \   },
            \   "component_raw": {
            \       "buffers": 1
            \   },
            \   "separator": {
            \       "left": "", "right": ""
            \   },
            \   "subseparator": {
            \       "left": "", "right": "" 
            \   },
            \ }

let g:lightline#bufferline#modified = " +"
let g:lightline#bufferline#unnamed = "[No Name]"
let g:lightline#bufferline#enable_devicons = 1
let g:lightline#bufferline#unicode_symbols = 1
let g:lightline#bufferline#clickable = 1

function! LightlineShouldIgnore()
    return &ft == "CHADTree"
endfunction

function! LightlineMode()
    return LightlineShouldIgnore() ? "" : lightline#mode()
endfunction

function! LightlineGitbranch()
    return LightlineShouldIgnore()
                \ || winwidth(0) < 70 ? "" : FugitiveHead()
endfunction

function! LightlineFilename()
    return LightlineShouldIgnore() ? "" : expand("%:t")
endfunction

function! LightlineLineinfo()
    return "%L  %l:%-2v"
endfunction

function! LightlinePercent()
    return "%p%%"
endfunction

function! LightlineFiletype()
    return LightlineShouldIgnore()
                \ || winwidth(0) < 50 ? "" : "%{&ft!=#''?&ft:'no ft'}"
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

function! LightlineTime()
    return strftime("%H:%M")
endfunction

function! TablineUpdate(timer_id)
    exec "set showtabline=" . &showtabline
endfunction

" Update tabline every minute
call timer_start(1000 * 60, "TablineUpdate", {"repeat": -1})

set showtabline=2  " Show tabline

" vim: shiftwidth=4 et
