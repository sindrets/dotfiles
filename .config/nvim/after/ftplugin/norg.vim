setl breakindentopt=list:-1
setl formatlistpat=^\\s*[-~\\*]\\+\\s\\+

if &readonly || ! &modifiable
    setl concealcursor=nc conceallevel=3
else
    setl sw=2 tw=80
endif

" Try using conceal by default
setl concealcursor=nc conceallevel=3

lua vim.opt_local.listchars = "trail:" .. vim.opt.listchars:get().trail
