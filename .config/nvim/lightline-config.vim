let g:lightline = {
            \   'colorscheme': 'one',
            \   'active': {
            \       'left': [ [ 'mode', 'paste' ],
            \               [ 'gitbranch', 'readonly', 'filename' ]
            \       ]
            \   },
            \   'component': {
            \       'lineinfo': ' %3l:%-2v',
            \   },
            \   'component_function': {
            \       'gitbranch': 'FugitiveHead'
            \   },
            \   'component_expand': {
            \       'buffers': 'lightline#bufferline#buffers'
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
            \   }
            \ }
set showtabline=2  " Show tabline
set guioptions-=e  " Don't use GUI tabline

" vim: shiftwidth=4 et
