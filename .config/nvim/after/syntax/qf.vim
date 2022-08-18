" NOTE: These patterns assumes the qf format provided by nvim-pqf.

syn clear qfPath

syn match qfPathBasename /\v(.{-})(:\d+(:\d+)?)@=/ nextgroup=qfPosition contained
syn match qfPath /\v(\S*\/)?/ nextgroup=qfPathBasename contained

hi! link qfPath Comment
hi def link qfPathBasename Keyword

" -2:   UNSET
" -1:   CLEARED
" >=0:  SET

if !exists("b:qf_conceal_state")
  let b:qf_conceal_state = {
        \   "dir": { "pattern": '\v(\S*\/)', "id": -2, },
        \   "basename": { "pattern": '\v(\S*\/)\zs(.{-})\ze(:\d+:\d+)', "id": -2 },
        \   "pos": { "pattern": '\v(:\d+:\d+)', "id": -2 },
        \ }
endif

if !exists("w:qf_conceal_state")
  let w:qf_conceal_state = {
        \   "dir": { "id": -2, },
        \   "basename": { "id": -2 },
        \   "pos": { "id": -2 },
        \ }
endif

if !get(s:, "ready")
  function! s:SetConcealPath(target, flag) abort
    let l:id = w:qf_conceal_state[a:target].id
    let l:pattern = b:qf_conceal_state[a:target].pattern

    if a:flag
      if l:id < 0
        let w:qf_conceal_state[a:target].id = matchadd("Conceal", l:pattern)
      endif
    else
      if l:id > -1
        try
          call matchdelete(l:id)
        catch /^Vim\%((\a\+)\)\=:E803:/
        endtry

        let w:qf_conceal_state[a:target].id = -1
      endif
    endif

    let b:qf_conceal_state[a:target].id = w:qf_conceal_state[a:target].id
  endfunction

  function! s:ToggleConcealPath() abort
    call s:SetConcealPath("dir", b:qf_conceal_state.dir.id < 0)
  endfunction

  let s:ready = v:true
endif

nnoremap <buffer> <M-o> <Cmd>call <SID>ToggleConcealPath()<CR>

let s:loclist = getloclist(0)

if b:qf_conceal_state.dir.id ==# -2 && len(s:loclist) > 0
  let s:bufname = bufname(s:loclist[0].bufnr)

  " Automatically conceal dir in help files and man pages.
  if s:bufname =~ ".*/runtime/doc/.*" || s:bufname =~ "^man://.*"
    call s:SetConcealPath("dir", v:true)
  endif
else
  call s:SetConcealPath("dir", b:qf_conceal_state.dir.id > -1)
endif
