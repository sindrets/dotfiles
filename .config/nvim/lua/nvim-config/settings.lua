local opt = vim.opt

local function list(value, str, sep)
  sep = sep or ","
  str = str or ""
  value = type(value) == "table" and table.concat(value, sep) or value
  return str ~= "" and table.concat({value, str}, sep) or value
end

opt.number = true
opt.relativenumber = true
opt.autoindent = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = -1
opt.expandtab = true
opt.ignorecase = true
opt.smartcase = true
opt.wildignorecase = true
opt.showcmd = true
opt.mouse = "a"
opt.hidden = true
opt.cursorline = true
opt.guicursor = "n-v-c-sm:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20"
opt.splitbelow = true
opt.splitright = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.swapfile = true
opt.shortmess = "filnxtToOFIA"
opt.updatetime = 4096 -- change cursorhold time with 'vim.g.cursorhold_updatetime'
opt.termguicolors = true
opt.backspace = list { "indent", "eol", "start" }
opt.inccommand = "split"
-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldlevelstart = 99
opt.foldlevel = 99 -- 'foldlevelstart' isn't working correctly?
opt.scrolloff = 3
opt.completeopt = list { "menuone", "noselect" }
opt.virtualedit = list { "block" }
opt.signcolumn = "yes:2"
opt.colorcolumn = list { "100" }
opt.sessionoptions = list {
  "blank",
  "buffers",
  "curdir",
  "folds",
  "help",
  "tabpages",
  "winsize"
}
opt.diffopt = list {
  "algorithm:histogram",
  "internal",
  "indent-heuristic",
  "filler",
  "closeoff",
  "iwhite",
  "vertical"
}
opt.pyxversion = 3
opt.shada = list {
  "!",
  "'10",
  "/100",
  ":100",
  "<0",
  "@1",
  "f1",
  "h",
  "s1"
}
opt.list = true
opt.listchars = list {
  "tab: ──",
  "space:·",
  "nbsp:␣",
  "trail:•",
  "eol:↵",
  "precedes:«",
  "extends:»"
}
opt.fillchars = list {
  -- "vert:▏",
  "vert:│",
  "diff:╱",
  "foldclose:",
  "foldopen:"
}
opt.showbreak = "⤷ "
opt.writebackup = true
opt.undofile = true
opt.isfname:append(":")
opt.laststatus = 3
opt.lazyredraw = true

local data_backup = vim.fn.stdpath("data") .. "/backup"
local data_undo = vim.fn.stdpath("data") .. "/undo"

opt.backupdir = data_backup
opt.undodir = data_undo

if vim.fn.isdirectory(data_backup) ~= 1 then
  vim.fn.mkdir(data_backup, "p")
end

if vim.fn.isdirectory(data_undo) ~= 1 then
  vim.fn.mkdir(data_undo, "p")
end

if vim.fn.executable("ag") == 1 then
  opt.grepprg = "ag --vimgrep $*"
  opt.grepformat = "%f:%l:%c:%m"
end

if vim.fn.executable("nvr") == 1 then
  vim.env.GIT_EDITOR = "nvr -cc split +'setl bh=delete' --remote-wait"
  vim.env.EDITOR = "nvr -l --remote"
  vim.env.VISUAL = "nvr -l --remote"
end

vim.env.MANWIDTH = 80 -- Text width in man pages.

-- vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

local init_extra_path = vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/init_extra.vim"
if vim.fn.filereadable(init_extra_path) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(init_extra_path))
end

vim.g.mapleader = " "

if vim.g.neovide then
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_trail_length = 0
  vim.g.neovide_floating_blur = false
  vim.g.neovide_floating_opacity = 1.0
end
