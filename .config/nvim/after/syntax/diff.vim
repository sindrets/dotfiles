lua <<EOF
local hl = Config.common.hl
hl.hi("GitFolded", { fg = hl.get_fg("diffFile"), bg = hl.get_bg("Folded"), default = true })
EOF

exe 'setl winhl=' . &winhl . (&winhl == "" ? "" : ",") . "diffAdded:DiffInlineAdd,diffRemoved:DiffInlineDelete"
