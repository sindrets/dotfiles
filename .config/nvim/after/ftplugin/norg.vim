setl sw=2 tw=80
setl concealcursor=nc conceallevel=2
setl breakindentopt=list:-1
setl formatlistpat=^\\s*[-~\\*]\\+\\s\\+

lua vim.opt_local.listchars = "trail:" .. vim.opt.listchars:get().trail
