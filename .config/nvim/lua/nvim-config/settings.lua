local opts_info = vim.api.nvim_get_all_options_info()

local opt =
  setmetatable(
  {},
  {
    __newindex = function(_, key, value)
      vim.o[key] = value
      local info = opts_info[key]
      if info then
        local scope = info.scope
        if scope == "win" then
          vim.wo[key] = value
        elseif scope == "buf" then
          vim.bo[key] = value
        end
      end
    end
  }
)

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
opt.splitbelow = true
opt.splitright = true
opt.wrap = true
opt.linebreak = true
opt.swapfile = false
opt.updatetime = 100
opt.termguicolors = true
opt.backspace = list {"indent", "eol", "start"}
opt.inccommand = "split"
opt.foldmethod = "expr"
opt.foldexpr = vim.fn.eval("nvim_treesitter#foldexpr()")
opt.foldlevelstart = 99
opt.scrolloff = 3
opt.completeopt = list { "menuone", "noselect" }
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
  "internal",
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
  "vert:▏",
  "diff:╱"
}
opt.showbreak = "⤷ "
opt.writebackup = true
opt.undofile = true

local data_backup = vim.fn.stdpath("data") .. "/backup"
local data_undo = vim.fn.stdpath("data") .. "/undo"

opt.backupdir = data_backup
opt.undodir = data_undo

if vim.fn.isdirectory(data_backup) ~= 1 then
  vim.cmd("system(mkdir " .. vim.fn.shellescape(data_backup) .. ")")
end

if vim.fn.isdirectory(data_undo) ~= 1 then
  vim.cmd("system(mkdir " .. vim.fn.shellescape(data_undo) .. ")")
end

if vim.fn.executable("ag") == 1 then
  opt.grepprg = "ag --vimgrep $*"
  opt.grepformat = "%f:%l:%c:%m"
end

vim.cmd("syntax on")
vim.cmd("syntax sync minlines=3000")
vim.cmd("filetype plugin indent on")

local init_extra_path = vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/init_extra.vim"
if vim.fn.filereadable(init_extra_path) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(init_extra_path))
end

vim.g.mapleader = " "
