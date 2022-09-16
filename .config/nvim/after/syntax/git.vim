highlight default link gitPath Directory
highlight default link gitNameStatus gitPath

highlight default link gitStatusModified diffChanged
highlight default link gitStatusAdded diffAdded
highlight default link gitStatusDeleted diffRemoved
highlight default link gitStatusRenamed diffChanged

" log --name-status

syntax region gitNameStatus start=/\v^([A-Z](\d{3})?\t)/ end=/$/ oneline keepend contains=gitStatusModified,gitStatusAdded,gitStatusDeleted,gitStatusRenamed

syntax match gitStatusModified /\v^M(\t)@=/ contained
syntax match gitStatusAdded /\v^A(\t)@=/ contained
syntax match gitStatusDeleted /\v^D(\t)@=/ contained
syntax match gitStatusRenamed /\v^R\d{3}(\t)@=/ contained

" log --numstat

highlight default link gitNumstat gitPath

syntax region gitNumstat start=/\v^\d+\t\d+\t.+/ end=/$/ oneline keepend contains=gitDiffAdded,gitDiffRemoved

syntax match gitDiffRemoved /\v\d+\ze\t/ contained
syntax match gitDiffAdded /\v^\d+\ze\t/ contained

" log --stat

highlight default link gitStat gitPath
highlight default link gitNonText NonText

syntax region gitStat start=/\v^ \S.* \| +\d+/ end=/$/ oneline keepend contains=gitDiffAdded,gitDiffRemoved,Number,gitNonText

syntax match gitDiffRemoved /\v-+$/ contained
syntax match gitDiffAdded /\v\++\ze-*$/ contained
syntax match gitNonText /\v\|\ze +\d+/ contained nextgroup=Number
syntax match Number /\v \zs\d+/ contained

" log --shortstat

highlight default gitShortstat gui=bold

syntax region gitShortstat start=/\v^ \d+ files? changed/ end=/$/ oneline keepend contains=Number

syntax match Number /\v \zs\d+/ contained
