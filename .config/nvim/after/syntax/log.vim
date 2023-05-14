setl conceallevel=2
setl concealcursor=nvic

syn match logDate /\v(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\ \d{1,2}\ (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\ \d{2,4}/

if bufname() =~ 'diffview.log$'
  syn match logPath /\v\S*\/\S*\/diffview.nvim\/lua\/diffview\// conceal
  syn match logPath /\v\.\.\.\S*\/lua\/diffview\// conceal
endif
