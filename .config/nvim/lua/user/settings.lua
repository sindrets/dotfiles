local opt = vim.opt

local function list(items, sep)
  return table.concat(items, sep or ",")
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
opt.mousemoveevent = true
opt.hidden = true
opt.cursorline = true
opt.cursorlineopt = list { "screenline", "number" }
opt.guicursor = list {
  "n-v-c-sm:block-Cursor/lCursor",
  "i-ci-ve:ver25-Cursor/lCursor",
  "r-cr-o:hor20",
}
opt.splitbelow = true
opt.splitright = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.swapfile = true
opt.shortmess = "filnxtToOFIAS"
opt.updatetime = 4096 -- change cursorhold time with 'vim.g.cursorhold_updatetime'
opt.termguicolors = true
opt.backspace = list { "indent", "eol", "start" }
opt.inccommand = "split"
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldlevelstart = 99
opt.foldlevel = 99 -- 'foldlevelstart' isn't working correctly?
opt.scrolloff = 3

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
end

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
  "vertical",
  "linematch:100",
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
  "lead:·",
  "trail:•",
  "nbsp:␣",
  -- "eol:↵",
  "precedes:«",
  "extends:»"
}
opt.fillchars = list {
  -- "vert:▏",
  "vert:│",
  "diff:╱",
  "foldclose:",
  "foldopen:",
  "fold: ",
  "msgsep:─",
}
opt.showbreak = "⤷ "
opt.concealcursor = "nc"
opt.writebackup = true
opt.undofile = true
opt.isfname:append(":")
opt.laststatus = 3
-- TODO: Lazyredraw is causing cursor flickering at the moment. Hopefully
-- re-enable soon when this is fixed.
-- @see [Neovim issue](https://github.com/neovim/neovim/issues/17765)
opt.lazyredraw = false
opt.formatoptions = table.concat({
  "c", -- Auto wrap using 'textwidth'
  "r", -- Auto insert comment leader
  "o", -- Auto insert comment leader after "o" or "O"
  "q", -- Allow formatting of comments with "gq"
  "2", -- The second line decides the indent for the paragraph
  "l", -- Long lines are not broken in insert mode
  "j", -- Remove comment leader when joining lines
})
opt.jumpoptions = list { "stack" }

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
  local nvr = "nvr --servername " .. vim.v.servername .. " "
  vim.env.GIT_EDITOR = nvr .. "-cc split +'setl bh=delete' --remote-wait"
  vim.env.EDITOR = nvr .. "-l --remote"
  vim.env.VISUAL = nvr .. "-l --remote"
end

vim.env.MANWIDTH = 80 -- Text width in man pages.

local init_extra_path = vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/init_extra.vim"
if vim.fn.filereadable(init_extra_path) == 1 then
  local data = vim.secure.read(init_extra_path)
  if data then vim.cmd.source(init_extra_path) end
end

vim.g.mapleader = " "

if vim.g.neovide then
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_trail_length = 0
  vim.g.neovide_floating_blur = false
  vim.g.neovide_floating_opacity = 1.0
end
