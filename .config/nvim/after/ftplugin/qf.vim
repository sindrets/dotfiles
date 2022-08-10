setl nolist
setl scl=yes:2
setl nonu nornu

if !get(s:, "ready")
  function! s:jump_stack(reverse, use_loclist) abort
    try
      if a:use_loclist
        if a:reverse
          lolder
        else
          lnewer
        endif
      else
        if a:reverse
          colder
        else
          cnewer
        endif
      endif
    catch /^Vim\%((\a\+)\)\=:E38[01]:/
    endtry
  endfunction

  let s:ready = v:true
endif

" Navigate quickfix history
if len(getloclist(0)) > 0
  nnoremap <buffer> J <Cmd>call <SID>jump_stack(v:false, v:true)<CR>
  nnoremap <buffer> K <Cmd>call <SID>jump_stack(v:true, v:true)<CR>
else
  nnoremap <buffer> J <Cmd>call <SID>jump_stack(v:false, v:false)<CR>
  nnoremap <buffer> K <Cmd>call <SID>jump_stack(v:true, v:false)<CR>
endif
