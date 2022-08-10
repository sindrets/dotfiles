" NOTE: These patterns assumes the qf format provided by nvim-pqf.

syn clear qfPath

syn match qfPathBasename /\v(.{-})(:\d+(:\d+)?)@=/ nextgroup=qfPosition contained
syn match qfPath /\v(\S*\/)?/ nextgroup=qfPathBasename contained

hi! link qfPath Comment
hi def link qfPathBasename Keyword

if !exists("b:qf_conceal_state")
  let b:qf_conceal_state = {
        \   "dir": { "pattern": '\v(\S*\/)', "id": -1, },
        \   "basename": { "pattern": '\v(\S*\/)\zs(.{-})\ze(:\d+:\d+)', "id": -1 },
        \   "pos": { "pattern": '\v(:\d+:\d+)', "id": -1 },
        \ }
endif

if !get(s:, "ready")
  function! s:SetConcealPath(target, flag) abort
    let l:id = b:qf_conceal_state[a:target]["id"]
    let l:pattern = b:qf_conceal_state[a:target]["pattern"]
    if a:flag
      if l:id ==# -1
        let b:qf_conceal_state[a:target]["id"] = matchadd("Conceal", l:pattern)
      endif
    else
      if l:id > -1
        try
          call matchdelete(l:id)
          let b:qf_conceal_state[a:target]["id"] = -1
        catch /^Vim\%((\a\+)\)\=:E803:/
          let b:qf_conceal_state[a:target]["id"] = -1
          call s:SetConcealPath(a:target, v:true)
        endtry
      endif
    endif
  endfunction

  function! s:ToggleConcealPath() abort
    call s:SetConcealPath("dir", b:qf_conceal_state["dir"]["id"] ==# -1)
  endfunction

  let s:ready = v:true
endif

nnoremap <buffer> <M-o> <Cmd>call <SID>ToggleConcealPath()<CR>

call s:SetConcealPath("dir", v:true)
