setl breakindentopt=list:-1
setl formatlistpat=^\\s*[-~\\*]\\+\\s\\+

if &readonly || ! &modifiable
    setl concealcursor=nc conceallevel=2
else
    setl sw=2 tw=80
endif

lua vim.opt_local.listchars = "trail:" .. vim.opt.listchars:get().trail
