-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/marwanfikrat/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/marwanfikrat/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/marwanfikrat/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/marwanfikrat/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/marwanfikrat/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["FixCursorHold.nvim"] = {
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/FixCursorHold.nvim",
    url = "https://github.com/antoinemadec/FixCursorHold.nvim"
  },
  ["alpha-nvim"] = {
    config = { "\27LJ\2\nÓ\1\0\0\15\2\t\1'-\0\0\0009\0\0\0)\2\0\0B\0\2\0025\1\1\0006\2\2\0009\2\3\0029\2\4\2+\3\0\0006\4\5\0\18\6\1\0B\4\2\4X\a\22Ä-\t\1\0\18\n\b\0'\v\6\0\18\f\2\0&\n\f\n8\t\n\t\14\0\t\0X\n\2Ä-\t\1\0008\t\b\t6\n\2\0009\n\a\n\18\f\t\0'\r\b\0004\14\0\0B\n\4\2\18\3\n\0\21\n\3\0\22\n\0\n\3\n\0\0X\n\1ÄL\3\2\0E\a\3\3R\aË\1274\4\0\0L\4\2\0\2¿\1¿\6\n\nsplit\6_\vipairs\15background\6o\bvim\1\3\0\0\vmajora\tnvim\24nvim_win_get_height(<\0\0\5\2\2\0\a-\0\0\0009\0\0\0-\2\1\0'\3\1\0+\4\1\0B\0\4\1K\0\1\0\1\0\3¿\vnormal\18nvim_feedkeysÆ\2\1\3\n\2\r\0\24-\3\0\0009\3\0\3\18\5\2\0B\3\2\0025\4\1\0=\0\2\0043\5\3\0=\5\4\0045\5\5\0'\6\6\0\18\b\6\0009\6\a\6\18\t\2\0B\6\3\2=\6\b\5=\5\t\0045\5\n\0>\2\2\5>\1\3\0055\6\v\0>\6\4\5=\5\f\0042\0\0ÄL\4\2\0\6¿\2¿\vkeymap\1\0\2\vsilent\2\vnowait\2\1\2\0\0\6n\topts\rshortcut\vformat\t %s \1\0\6\vcursor\3\0\ahl\20DashboardCenter\19align_shortcut\nright\16hl_shortcut\22DashboardShortCut\nwidth\3(\rposition\vcenter\ron_press\0\bval\1\0\1\ttype\vbutton\6t⁄\2\0\1\r\2\17\0+6\1\0\0009\1\1\1+\2\1\0=\2\2\0016\1\0\0009\1\1\0016\2\4\0009\2\5\0025\4\6\0'\5\a\0B\2\3\2=\2\3\0016\1\b\0-\3\0\0009\3\t\3B\1\2\4X\4\23Ä-\6\1\0009\6\n\0069\b\v\5B\6\2\0026\a\0\0009\a\f\a'\t\r\0:\n\4\6\14\0\n\0X\v\1Ä4\n\0\0005\v\14\0=\0\15\vB\a\4\2>\a\4\0066\a\0\0009\a\v\a9\a\16\a:\t\1\6:\n\2\6:\v\3\6:\f\4\6B\a\5\1E\4\3\3R\4Á\127K\0\1\0\a¿\6¿\bset\vbuffer\1\0\0\nforce\15tbl_extend\vkeymap\14vec_slice\fbuttons\vipairs\6,\1\3\0\0\27Normal:DashboardNormal%EndOfBuffer:DashboardEndOfBuffer\vconcat\ntable\nwinhl\tlist\14opt_local\bvim¨\3\0\0\a\1\21\0(-\0\0\0009\0\0\0'\2\1\0'\3\2\0005\4\3\0B\0\4\1-\0\0\0009\0\4\0'\2\5\0005\3\6\0B\0\3\1-\0\0\0009\0\0\0'\2\a\0'\3\b\0005\4\t\0B\0\4\1-\0\0\0009\0\0\0'\2\n\0'\3\v\0005\4\f\0B\0\4\1-\0\0\0009\0\4\0'\2\r\0005\3\16\0-\4\0\0009\4\14\4'\6\15\0B\4\2\2=\4\17\3B\0\3\1-\0\0\0009\0\0\0'\2\18\0'\3\19\0005\4\20\0B\0\4\1K\0\1\0\4¿\1\0\1\fdefault\2\vNumber\20DashboardFooter\afg\1\0\2\fdefault\2\bgui\17bold,reverse\vString\vget_fg\22DashboardShortCut\1\0\1\fdefault\2\fKeyword\20DashboardCenter\1\0\1\fdefault\2\tType\20DashboardHeader\1\0\3\abg\abg\afg\abg\fdefault\2\25DashboardEndOfBuffer\ahi\1\0\1\fdefault\2\vNormal\20DashboardNormal\fhi_link)\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\3\0\20workspace_filesÜ\6\1\0\b\4%\1L6\0\0\0009\0\1\0006\2\0\0009\2\2\0029\2\3\2'\4\4\0+\5\2\0B\2\3\2'\3\5\0004\4\0\0B\0\4\2-\1\0\0005\2\a\0-\3\1\0B\3\1\2=\3\b\0025\3\t\0=\3\n\2=\2\6\1-\1\0\0005\2\f\0004\3\3\0'\4\r\0:\5\2\0&\4\5\4>\4\1\3=\3\b\0025\3\14\0=\3\n\2=\2\v\1-\1\0\0004\2\b\0-\3\2\0'\5\16\0'\6\17\0'\a\18\0B\3\4\2>\3\1\2-\3\2\0'\5\19\0003\6\20\0'\a\21\0B\3\4\2>\3\2\2-\3\2\0'\5\22\0'\6\23\0'\a\24\0B\3\4\2>\3\3\2-\3\2\0'\5\25\0'\6\26\0'\a\27\0B\3\4\2>\3\4\2-\3\2\0'\5\28\0'\6\29\0'\a\30\0B\3\4\2>\3\5\2-\3\2\0'\5\31\0'\6 \0'\a!\0B\3\4\2>\3\6\2-\3\2\0'\5\"\0'\6#\0'\a$\0B\3\4\0?\3\0\0=\2\15\1K\0\1\0\a¿\b¿\t¿\5¿\6q\22<Cmd>wincmd q<CR>\14Ôôô  Quit\afm\29<Cmd>Telescope marks<CR>\22Ôë°  Jump to Mark\afw!<Cmd>Telescope live_grep<CR>\19ÔûÉ  Find Word\arf <Cmd>Telescope oldfiles<CR>\29ÔÉÖ  Recently Used Files\ags\"<Cmd>Telescope git_status<CR>\20Ôû°  Git Status\aff\0\19Ôë´  Find File\6n\18<Cmd>enew<CR>\18ÔÖõ  New File\fbuttons\1\0\2\ahl\20DashboardFooter\rposition\vcenter\tÔîó \1\0\1\ttype\ttext\vfooter\topts\1\0\2\ahl\20DashboardHeader\rposition\vcenter\bval\1\0\1\ttype\ttext\vheader\6\n\fversion\14nvim_exec\bapi\nsplit\bvim\15ÄÄ¿ô\4\29\0\1\4\1\1\0\4-\1\0\0009\3\0\0B\1\2\1K\0\1\0\n¿\bbuf\21\0\1\3\1\0\0\3-\1\0\0B\1\1\1K\0\1\0\v¿ÿ\4\1\0\20\0%\0G6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\3\0009\2\4\0026\3\5\0009\3\6\0039\3\a\0036\4\5\0009\4\6\0049\4\b\0046\5\5\0009\5\t\0056\6\5\0009\6\6\0069\6\n\0065\a\v\0004\b\0\0=\b\f\a4\b\0\0=\b\r\a4\b\0\0=\b\14\a3\b\15\0003\t\16\0003\n\17\0003\v\18\0003\f\19\0009\r\20\3'\15\21\0004\16\0\0004\17\3\0005\18\22\0003\19\23\0=\19\24\18>\18\1\0175\18\25\0003\19\26\0=\19\24\18>\18\2\17B\r\4\1\18\r\f\0B\r\1\1\18\r\v\0B\r\1\0019\r\27\0005\15\29\0005\16\28\0=\16\30\0154\16\6\0005\17\31\0>\17\1\0169\17\f\a>\17\2\0165\17 \0>\17\3\0165\17!\0005\18\"\0=\18\30\0179\18\r\a=\18#\17>\17\4\0169\17\14\a>\17\5\16=\16$\15B\r\2\0012\0\0ÄK\0\1\0\vlayout\bval\1\0\1\fspacing\3\1\1\0\1\ttype\ngroup\1\0\2\ttype\fpadding\bval\3\2\1\0\2\ttype\fpadding\bval\3\1\topts\1\0\0\1\0\1\vmargin\3\5\nsetup\0\1\2\1\0\16ColorScheme\fpattern\6*\rcallback\0\1\2\1\0\tUser\fpattern\15AlphaReady\17alpha_config\18declare_group\0\0\0\0\0\vfooter\fbuttons\vheader\1\0\0\nutils\blib\ahl\aau\vcommon\vConfig\bapi\bvim\31user.plugins.alpha.banners\nalpha\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/alpha-nvim",
    url = "https://github.com/goolord/alpha-nvim"
  },
  catppuccin = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-git"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/cmp-git",
    url = "https://github.com/petertriho/cmp-git"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  ["cmp-spell"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/cmp-spell",
    url = "https://github.com/f3fora/cmp-spell"
  },
  ["cmp-vsnip"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/cmp-vsnip",
    url = "https://github.com/hrsh7th/cmp-vsnip"
  },
  ["csv.vim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/csv.vim",
    url = "https://github.com/chrisbra/csv.vim"
  },
  ["diffview.nvim"] = {
    config = { "\27LJ\2\n‰\2\0\0\6\2\r\0'-\0\0\0009\0\0\0-\2\1\0'\3\1\0B\0\3\1-\0\0\0009\0\0\0-\2\1\0'\3\2\0B\0\3\1-\0\1\0009\0\3\0009\0\4\0-\1\0\0009\1\6\1-\3\1\0009\3\3\0039\3\4\0039\3\5\0035\4\b\0005\5\a\0=\5\t\4B\1\3\2=\1\5\0-\0\1\0009\0\3\0009\0\4\0-\1\0\0009\1\6\1-\3\1\0009\3\3\0039\3\4\0039\3\n\0035\4\f\0005\5\v\0=\5\t\4B\1\3\2=\1\n\0K\0\1\0\0\0\0¿\1\0\0\1\3\0\0\23DiffChange:DiffAdd\25DiffText:DiffAddText\6b\nwinhl\1\0\0\1\3\0\0\31DiffChange:DiffAddAsDelete\28DiffText:DiffDeleteText\21tbl_union_extend\6a\ndiff2\fwinopts\20winopts.diff2.b\20winopts.diff2.a\15tbl_ensureM\1\1\a\1\4\0\v3\1\0\0009\2\1\0\18\4\2\0009\2\2\2'\5\3\0\18\6\1\0B\2\4\1\18\2\1\0B\2\1\0012\0\0ÄK\0\1\0\1¿\16post_layout\aon\femitter\0ì\1\0\1\5\1\6\0\18-\1\0\0009\1\0\1)\3\0\0)\4\1\0B\1\3\0016\1\1\0009\1\2\0019\1\3\1\18\3\0\0B\1\2\2)\2ƒ\t\3\2\1\0X\1\4Ä6\1\1\0009\1\4\1'\3\5\0B\1\2\1K\0\1\0\1¿\27IndentBlanklineDisable\bcmd\24nvim_buf_line_count\bapi\bvim\15set_cursorˇ\b\1\0\t\0;\0S6\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0019\1\4\0014\2\0\0006\3\0\0'\5\5\0B\3\2\0029\3\6\0035\5\a\0005\6\b\0=\6\t\0055\6\n\0=\6\v\0055\6\f\0=\6\r\0055\6\15\0005\a\14\0=\a\16\6=\6\17\0055\6\18\0005\a\19\0=\a\20\0065\a\21\0=\a\22\6=\6\23\0055\6\29\0005\a\25\0005\b\24\0=\b\26\a5\b\27\0=\b\28\a=\a\30\0065\a\31\0=\a\22\6=\6 \0055\6!\0004\a\0\0=\a\22\6=\6\"\0055\6#\0004\a\0\0=\a$\0064\a\0\0=\a%\6=\6&\0055\6(\0003\a'\0=\a)\0063\a*\0=\a+\6=\6,\0055\0062\0005\a.\0009\b-\0=\b/\a9\b0\0=\b1\a=\a\17\0065\a4\0009\b3\0=\b5\a9\b0\0=\b6\a9\b-\0=\b/\a=\a\23\0065\a7\0009\b3\0=\b5\a9\b-\0=\b/\a=\a \6=\0068\5B\3\2\0016\0039\0009\3\2\0039\3:\3=\2\5\0032\0\0ÄK\0\1\0\vplugin\a_G\fkeymaps\1\0\1\6?0<Cmd>h diffview-maps-file-history-panel<CR>\6s\t<cr>\1\0\1\6?(<Cmd>h diffview-maps-file-panel<CR>\16focus_entry\1\0\0\6-\23toggle_stage_entry\agf\1\0\0\19goto_file_edit\nhooks\18diff_buf_read\0\16view_opened\1\0\0\0\17default_args\24DiffviewFileHistory\17DiffviewOpen\1\0\0\21commit_log_panel\1\0\0\23file_history_panel\1\0\2\vheight\3\16\rposition\vbottom\16log_options\1\0\0\15multi_file\1\0\1\16diff_merges\17first-parent\16single_file\1\0\0\1\0\1\16diff_merges\rcombined\15file_panel\15win_config\1\0\2\nwidth\3#\rposition\tleft\17tree_options\1\0\2\20folder_statuses\16only_folded\17flatten_dirs\2\1\0\1\18listing_style\ttree\tview\15merge_tool\1\0\0\1\0\2\24disable_diagnostics\2\vlayout\16diff3_mixed\nsigns\1\0\2\14fold_open\bÔëº\16fold_closed\bÔë†\nicons\1\0\2\16folder_open\bÓóæ\18folder_closed\bÓóø\fgit_cmd\1\2\0\0\bgit\1\0\3\14use_icons\2\18diff_binaries\1\21enhanced_diff_hl\2\nsetup\rdiffview\nutils\vcommon\vConfig\21diffview.actions\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/diffview.nvim",
    url = "https://github.com/sindrets/diffview.nvim"
  },
  ["doom-one.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/doom-one.nvim",
    url = "https://github.com/NTBBloodbath/doom-one.nvim"
  },
  dracula = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/dracula",
    url = "https://github.com/sindrets/dracula-vim"
  },
  ["emmet-vim"] = {
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/emmet-vim",
    url = "https://github.com/mattn/emmet-vim"
  },
  everforest = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/everforest",
    url = "https://github.com/sainnhe/everforest"
  },
  ["feline.nvim"] = {
    config = { "\27LJ\2\nU\0\0\2\0\5\0\v6\0\0\0009\0\1\0009\0\2\0009\0\3\0B\0\1\0016\0\0\0009\0\1\0009\0\2\0009\0\4\0B\0\1\1K\0\1\0\nsetup\vupdate\vfeline\vplugin\vConfig\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/feline.nvim",
    url = "https://github.com/feline-nvim/feline.nvim"
  },
  firenvim = {
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/firenvim",
    url = "https://github.com/glacambre/firenvim"
  },
  ["github-nvim-theme"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/github-nvim-theme",
    url = "https://github.com/projekt0n/github-nvim-theme"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\nW\0\4\n\1\4\0\14\14\0\3\0X\4\1Ä4\3\0\0-\4\0\0=\4\0\0036\4\1\0009\4\2\0049\4\3\4\18\6\0\0\18\a\1\0\18\b\2\0\18\t\3\0B\4\5\1K\0\1\0\0¿\bset\vkeymap\bvim\vbufferD\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\0\0\rnorm! zz\bcmd\bvim\14next_hunkg\1\0\3\1\a\0\0156\0\0\0009\0\1\0009\0\2\0\15\0\0\0X\1\2Ä'\0\3\0002\0\aÄ6\0\0\0009\0\4\0003\2\5\0B\0\2\1'\0\6\0002\0\0ÄL\0\2\0L\0\2\0\1¿\r<Ignore>\0\rschedule\a]c\tdiff\awo\bvimD\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\0\0\rnorm! zz\bcmd\bvim\14prev_hunkg\1\0\3\1\a\0\0156\0\0\0009\0\1\0009\0\2\0\15\0\0\0X\1\2Ä'\0\3\0002\0\aÄ6\0\0\0009\0\4\0003\2\5\0B\0\2\1'\0\6\0002\0\0ÄL\0\2\0L\0\2\0\1¿\r<Ignore>\0\rschedule\a[c\tdiff\awo\bvimn\0\0\6\1\6\1\17-\0\0\0009\0\0\0004\2\3\0006\3\1\0009\3\2\0039\3\3\3'\5\4\0B\3\2\2>\3\1\0026\3\1\0009\3\2\0039\3\3\3'\5\5\0B\3\2\0?\3\0\0B\0\2\1K\0\1\0\1¿\6v\6.\tline\afn\bvim\15stage_hunk\5ÄÄ¿ô\4n\0\0\6\1\6\1\17-\0\0\0009\0\0\0004\2\3\0006\3\1\0009\3\2\0039\3\3\3'\5\4\0B\3\2\2>\3\1\0026\3\1\0009\3\2\0039\3\3\3'\5\5\0B\3\2\0?\3\0\0B\0\2\1K\0\1\0\1¿\6v\6.\tline\afn\bvim\15reset_hunk\5ÄÄ¿ô\0041\0\0\3\1\2\0\5-\0\0\0009\0\0\0005\2\1\0B\0\2\1K\0\1\0\1¿\1\0\1\tfull\2\15blame_lineœ\4\1\1\t\0!\0I6\1\0\0009\1\1\0019\1\2\0013\2\3\0\18\3\2\0'\5\4\0'\6\5\0003\a\6\0005\b\a\0B\3\5\1\18\3\2\0'\5\4\0'\6\b\0003\a\t\0005\b\n\0B\3\5\1\18\3\2\0'\5\4\0'\6\v\0009\a\f\1B\3\4\1\18\3\2\0'\5\4\0'\6\r\0009\a\14\1B\3\4\1\18\3\2\0'\5\15\0'\6\v\0003\a\16\0B\3\4\1\18\3\2\0'\5\15\0'\6\r\0003\a\17\0B\3\4\1\18\3\2\0'\5\4\0'\6\18\0009\a\19\1B\3\4\1\18\3\2\0'\5\4\0'\6\20\0009\a\21\1B\3\4\1\18\3\2\0'\5\4\0'\6\22\0009\a\23\1B\3\4\1\18\3\2\0'\5\4\0'\6\24\0003\a\25\0B\3\4\1\18\3\2\0'\5\4\0'\6\26\0009\a\27\1B\3\4\1\18\3\2\0'\5\4\0'\6\28\0009\a\29\1B\3\4\1\18\3\2\0005\5\30\0'\6\31\0'\a \0B\3\4\0012\0\0ÄK\0\1\0#:<C-U>Gitsigns select_hunk<CR>\aih\1\3\0\0\6o\6x\19toggle_deleted\15<leader>td\30toggle_current_line_blame\15<leader>tb\0\15<leader>hb\17preview_hunk\14<leader>d\20undo_stage_hunk\15<leader>hu\17stage_buffer\15<leader>hS\0\0\6v\15reset_hunk\15<leader>hr\15stage_hunk\15<leader>hs\1\0\1\texpr\2\0\a[c\1\0\1\texpr\2\0\a]c\6n\0\rgitsigns\vloaded\fpackageß\a\1\0\6\0#\0,6\0\0\0009\0\1\0009\0\2\0009\0\3\0006\1\4\0'\3\5\0B\1\2\0029\1\6\0015\3\18\0005\4\b\0005\5\a\0=\5\t\0045\5\n\0=\5\v\0045\5\f\0=\5\r\0045\5\14\0=\5\15\0045\5\16\0=\5\17\4=\4\19\0035\4\20\0=\4\21\0035\4\22\0=\4\23\0033\4\24\0=\4\25\3B\1\2\1\18\1\0\0'\3\26\0'\4\27\0005\5\28\0B\1\4\1\18\1\0\0'\3\29\0'\4\30\0005\5\31\0B\1\4\1\18\1\0\0'\3 \0'\4!\0005\5\"\0B\1\4\1K\0\1\0\1\0\1\fdefault\2\16diffRemoved\19GitSignsDelete\1\0\1\fdefault\2\16diffChanged\19GitSignsChange\1\0\1\fdefault\2\14diffAdded\16GitSignsAdd\14on_attach\0\14diff_opts\1\0\3\rinternal\2\14algorithm\14histogram\21indent_heuristic\2\17watch_gitdir\1\0\2\rinterval\3Ë\a\17follow_files\2\nsigns\1\0\4\vlinehl\1\20update_debounce\3d\18sign_priority\3\6\nnumhl\1\14topdelete\1\0\4\vlinehl\21GitSignsDeleteLn\ahl\19GitSignsDelete\ttext\b‚Äæ\nnumhl\21GitSignsDeleteNr\17changedelete\1\0\4\vlinehl\21GitSignsChangeLn\ahl\19GitSignsChange\ttext\b‚ñç\nnumhl\21GitSignsChangeNr\vdelete\1\0\4\vlinehl\21GitSignsDeleteLn\ahl\19GitSignsDelete\ttext\b‚ñç\nnumhl\21GitSignsDeleteNr\vchange\1\0\4\vlinehl\21GitSignsChangeLn\ahl\19GitSignsChange\ttext\b‚ñç\nnumhl\21GitSignsChangeNr\badd\1\0\0\1\0\4\vlinehl\18GitSignsAddLn\ahl\16GitSignsAdd\ttext\b‚ñç\nnumhl\18GitSignsAddNr\nsetup\rgitsigns\frequire\fhi_link\ahl\vcommon\vConfig\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  gruvbox = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/gruvbox",
    url = "https://github.com/gruvbox-community/gruvbox"
  },
  ["gruvbox-material"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/gruvbox-material",
    url = "https://github.com/sainnhe/gruvbox-material"
  },
  ["i3config.vim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/i3config.vim",
    url = "https://github.com/mboughaba/i3config.vim"
  },
  ["impatient.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/impatient.nvim",
    url = "https://github.com/lewis6991/impatient.nvim"
  },
  ["incline.nvim"] = {
    config = { "\27LJ\2\n“\5\0\1\14\4\31\1z6\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\0026\2\4\0\18\4\2\0009\2\5\2\18\5\1\0B\2\3\2\a\2\6\0X\3\2Ä'\3\a\0X\4\1Ä\18\3\2\0+\4\0\0\21\5\3\0-\6\0\0\22\6\0\6\1\6\5\0X\5\aÄ'\5\b\0\18\b\3\0009\6\t\3-\t\0\0\20\t\t\0B\6\3\2&\3\6\0056\5\0\0009\5\n\0059\6\3\0008\5\6\0059\5\v\5\a\5\f\0X\5\2Ä'\2\r\0X\5\6Ä6\5\4\0\18\a\5\0009\5\14\5\18\b\1\0B\5\3\2\18\4\5\0006\5\15\0006\a\0\0009\a\16\a9\b\3\0008\a\b\a9\a\17\aB\5\2\2\a\5\18\0X\5\fÄ6\5\0\0009\5\16\0059\6\3\0008\5\6\0055\6\19\0006\a\4\0\18\t\a\0009\a\15\a\18\n\1\0B\a\3\2=\a\20\6=\6\17\0056\5\0\0009\5\16\0059\6\3\0008\5\6\0059\5\17\5,\6\a\0009\b\20\5\a\b\21\0X\b\aÄ-\b\1\0009\b\22\b'\n\23\0B\b\2\3\18\a\t\0\18\6\b\0X\b\bÄ-\b\1\0009\b\22\b\18\n\2\0\18\v\4\0005\f\24\0B\b\4\3\18\a\t\0\18\6\b\0-\b\2\0009\b\25\b4\n\3\0005\v\27\0\18\f\6\0'\r\26\0&\f\r\f>\f\1\v-\f\3\0\15\0\f\0X\r\2Ä\f\f\a\0X\f\1Ä+\f\0\0=\f\28\v>\v\1\n4\v\3\0004\f\3\0>\3\1\f>\f\1\v6\f\0\0009\f\n\f9\r\3\0008\f\r\f9\f\29\f\15\0\f\0X\r\5Ä4\f\3\0005\r\30\0>\r\1\f\14\0\f\0X\r\1Ä+\f\0\0D\b\4\0\3¿\0¿\1¿\2¿\1\2\0\0\t [+]\rmodified\nguifg\1\0\0\6 \rvec_join\1\0\1\fdefault\2\20lir_folder_icon\19get_icon_color\14directory\nftype\1\0\0\bnil\18incline_state\6b\ttype\14extension\ash\rterminal\fbuftype\abo\bsub\a¬´\14[No Name]\5\rbasename\apl\bbuf\22nvim_buf_get_name\bapi\bvim\2≈\a\1\0\n\0+\00046\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0019\1\4\1+\2\1\0)\0032\0006\4\0\0'\6\5\0B\4\2\0029\4\6\0045\6\b\0003\a\a\0=\a\t\0065\a\n\0=\a\v\0065\a\f\0=\a\r\0065\a\15\0005\b\14\0=\b\16\a=\a\17\0065\a\18\0004\b\0\0=\b\19\a5\b\20\0=\b\21\a=\a\22\0065\a\28\0005\b\24\0005\t\23\0=\t\25\b5\t\26\0=\t\27\b=\b\29\a5\b\30\0=\b\31\a5\b \0=\b!\a5\b\"\0=\b#\a5\b%\0005\t$\0=\t&\b5\t'\0=\t(\b=\b)\a=\a*\6B\4\2\0012\0\0ÄK\0\1\0\vwindow\17winhighlight\rinactive\1\0\3\vSearch\tNone\vNormal\20InclineNormalNC\16EndOfBuffer\tNone\vactive\1\0\0\1\0\3\vSearch\tNone\vNormal\18InclineNormal\16EndOfBuffer\tNone\14placement\1\0\2\15horizontal\nright\rvertical\btop\fpadding\1\0\2\tleft\3\2\nright\3\2\foptions\1\0\3\rwinblend\3\20\15signcolumn\ano\twrap\1\vmargin\1\0\3\17padding_char\6 \vzindex\3\n\nwidth\bfit\rvertical\1\0\2\vbottom\3\0\btop\3\1\15horizontal\1\0\0\1\0\2\tleft\3\0\nright\3\1\vignore\14filetypes\1\a\0\0\18fugitiveblame\18DiffviewFiles\24DiffviewFileHistory\26DiffviewFHOptionPanel\fOutline\14dashboard\rbuftypes\1\0\3\18floating_wins\2\rwintypes\fspecial\21unlisted_buffers\1\14highlight\vgroups\1\0\0\1\0\2\20InclineNormalNC\tNONE\18InclineNormal\tNONE\thide\1\0\3\ronly_win\2\16focused_win\1\15cursorline\2\23debounce_threshold\1\0\2\vrising\3\0\ffalling\0032\vrender\1\0\0\0\nsetup\fincline\nutils\vcommon\vConfig\22nvim-web-devicons\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/incline.nvim",
    url = "https://github.com/b0o/incline.nvim"
  },
  ["indent-blankline.nvim"] = {
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["indent-o-matic"] = {
    config = { "\27LJ\2\nt\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\20standard_widths\1\5\0\0\3\2\3\3\3\4\3\b\1\0\1\14max_lines\3Ä\16\nsetup\19indent-o-matic\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/indent-o-matic",
    url = "https://github.com/Darazaki/indent-o-matic"
  },
  ["kanagawa.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/kanagawa.nvim",
    url = "https://github.com/rebelot/kanagawa.nvim"
  },
  ["lir-git-status.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/lir-git-status.nvim",
    url = "https://github.com/tamago324/lir-git-status.nvim"
  },
  ["lir.nvim"] = {
    config = { "\27LJ\2\nS\0\1\a\0\5\0\v6\1\0\0009\1\1\1'\3\2\0006\4\0\0009\4\3\0049\4\4\4\18\6\0\0B\4\2\2&\3\4\3B\1\2\1K\0\1\0\16fnameescape\afn\rnoau cd \bcmd\bvim≠\1\0\1\n\3\6\0\27-\1\0\0009\1\0\1B\1\1\2-\2\1\0\18\4\2\0009\2\1\2\18\5\0\0009\6\2\1B\2\4\2\18\5\1\0009\3\3\1-\6\1\0\18\b\6\0009\6\4\6\18\t\2\0B\6\3\2:\6\1\6B\3\3\2\15\0\3\0X\4\6Ä-\4\2\0009\4\5\4)\6\0\0\18\a\3\0)\b\0\0B\4\4\1K\0\1\0\4¿\a¿\b¿\15set_cursor\fexplode\findexof\bdir\rrelative\16get_contexty\0\0\6\1\6\0\0166\0\0\0009\0\1\0009\0\2\0)\2\0\0B\0\2\0026\1\0\0009\1\3\1'\3\4\0B\1\2\1-\1\0\0009\1\5\1)\3\0\0:\4\1\0)\5\0\0B\1\4\1K\0\1\0\b¿\15set_cursor\tedit\bcmd\24nvim_win_get_cursor\bapi\bvim≥\3\0\1\v\t\15\0G-\1\0\0-\3\1\0B\1\2\1-\1\2\0009\1\0\1B\1\1\1\n\0\0\0X\1\3Ä-\1\3\0\5\0\1\0X\1\1ÄK\0\1\0006\1\1\0009\1\2\1\18\3\0\0B\1\2\2\15\0\1\0X\2\nÄ9\2\3\1\a\2\4\0X\2\aÄ-\2\4\0\18\4\2\0009\2\5\2\18\5\0\0-\6\3\0B\2\4\2\18\0\2\0-\2\2\0009\2\6\2-\4\5\0B\2\2\2\15\0\2\0X\3\6Ä6\3\a\0009\3\b\0039\3\t\3+\5\1\0\18\6\2\0B\3\3\0016\3\1\0009\3\n\3-\5\4\0\18\a\5\0009\5\5\5-\b\6\0009\b\v\b-\t\3\0B\5\4\2-\6\4\0\18\b\6\0009\6\5\6-\t\6\0009\t\v\t\18\n\0\0B\6\4\0A\3\1\2-\4\a\0009\4\f\4B\4\1\1\14\0\3\0X\4\5Ä-\4\2\0009\4\r\4'\6\14\0B\4\2\1K\0\1\0-\4\b\0\18\6\0\0B\4\2\1K\0\1\0\2\0\3¿\3\0\2¿\1\0\4¿\0¿\4\0\5\0\19Rename failed!\berr\vreload\bdir\14fs_rename\18remove_buffer\blib\vConfig\21find_file_buffer\tjoin\14directory\ttype\ffs_stat\auv\17clear_promptÜ\2\1\0\n\6\18\0 -\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\0026\2\2\0009\2\3\0029\4\4\1-\5\1\0009\5\5\5'\6\6\0&\5\6\5'\6\a\0B\2\4\0026\3\b\0009\3\t\3B\3\1\0029\4\n\1-\5\2\0009\a\v\0B\5\2\1-\5\3\0009\5\f\5'\a\r\0005\b\14\0=\2\15\b3\t\16\0=\t\17\bB\5\3\0012\0\0ÄK\0\1\0\4¿\a¿\v¿\b¿\0¿\f¿\rcallback\0\fdefault\1\0\1\15completion\tfile\vMove: \ninput\bdir\rfullpath\bcwd\auv\5\6$\bsep\nvalue\tgsub\vstring\fcurrent\16get_contextq\0\1\a\3\5\0\r-\1\0\0-\2\1\0-\3\2\0009\3\0\3\18\5\0\0005\6\1\0B\3\3\2<\3\2\0016\1\2\0009\1\3\1-\3\0\0'\4\4\0D\1\3\0\5¿\4Ä\1\0\6 \vconcat\ntable\1\0\1\23only_if_whitespace\2\14str_quoteÀ\1\1\3\r\2\v\0\31-\3\0\0009\3\0\3\18\5\1\0\18\6\2\0B\3\3\0036\5\1\0009\5\2\5)\a\1\0\18\b\4\0B\5\3\2\18\4\5\0-\5\1\0009\5\3\5\18\a\3\0)\b\1\0\18\t\4\0B\5\4\0026\6\4\0009\6\5\0063\b\6\0006\t\4\0009\t\a\t9\t\b\t8\v\4\3\14\0\v\0X\f\1Ä'\v\t\0'\f\n\0B\t\3\0002\0\0ÄC\6\1\0\3\0\2\0\tfile\5\18getcompletion\afn\0\ftbl_map\bvim\14vec_slice\bmax\tmath\17scan_sh_argsÿ\5\0\1\17\a\28\1{-\1\0\0-\3\1\0B\1\2\1-\1\2\0009\1\0\1B\1\1\1\14\0\0\0X\1\1ÄK\0\1\0-\1\3\0009\1\1\1\18\3\0\0\21\4\0\0B\1\3\2,\2\3\0006\4\2\0\18\6\1\0B\4\2\4X\aXÄ-\t\4\0\18\v\t\0009\t\3\t\18\f\b\0-\r\5\0009\r\4\rB\t\4\2\18\2\t\0006\t\5\0009\t\6\t\18\v\b\0'\f\a\0B\t\3\2\15\0\t\0X\n\3Ä\18\t\2\0'\n\a\0&\2\n\t\18\v\2\0009\t\b\2'\f\t\0B\t\3\2\18\3\t\0-\t\4\0\18\v\t\0009\t\n\t\18\f\2\0B\t\3\2\14\0\t\0X\t:Ä\15\0\3\0X\t Ä-\t\4\0\18\v\t\0009\t\v\t\18\f\3\0B\t\3\2\14\0\t\0X\t\25Ä6\t\f\0006\v\5\0009\v\r\v9\v\14\v\18\f\3\0'\r\15\0B\t\4\3\15\0\t\0X\v\2Ä\b\n\0\0X\v\14Ä-\v\2\0009\v\16\v5\r\17\0006\14\18\0\18\16\n\0B\14\2\2\a\14\19\0X\14\2Ä\f\14\n\0X\14\1Ä+\14\0\0>\14\2\rB\v\2\1K\0\1\0\18\t\3\0'\n\a\0&\t\n\t\4\t\2\0X\t\19Ä6\t\20\0009\t\21\t\18\v\2\0'\f\22\0)\r§\1B\t\4\2\14\0\t\0X\n\aÄ-\n\2\0009\n\16\n'\f\23\0\18\r\2\0&\f\r\fB\n\2\1K\0\1\0006\n\20\0009\n\24\n\18\f\t\0B\n\2\1E\a\3\3R\a¶\1276\4\5\0009\4\25\4'\6\26\0006\a\5\0009\a\r\a9\a\27\a\18\t\3\0B\a\2\2&\6\a\6B\4\2\1-\4\6\0\18\6\2\0B\4\2\1K\0\1\0\1\0\1¿\2\0\3\0\4\0\0¿\5\0\16fnameescape\ae \bcmd\rfs_close\28Could not create file: \6w\ffs_open\auv\vstring\ttype\1\2\0\0\27Failed to create path!\berr\6p\nmkdir\afn\npcall\vis_dir\rreadable\n(.*)/\nmatch\6/\rendswith\bvim\bdir\rabsolute\vipairs\17scan_sh_args\17clear_prompt\2®\1\1\0\a\6\v\0\20-\0\0\0009\0\0\0B\0\1\0026\1\1\0009\1\2\1B\1\1\2-\2\1\0009\4\3\0B\2\2\1-\2\2\0009\2\4\2'\4\5\0005\5\a\0003\6\6\0=\6\b\0053\6\t\0=\6\n\5B\2\3\0012\0\0ÄK\0\1\0\4¿\v¿\b¿\6¿\a¿\f¿\rcallback\0\15completion\1\0\0\0\19Create paths: \ninput\bdir\bcwd\auv\16get_contextç\2\0\0\n\4\v\1\"-\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\2-\2\1\0009\2\2\2\18\4\0\0'\5\3\0B\2\3\2\14\0\2\0X\3\1ÄK\0\1\0-\3\1\0009\3\4\0035\5\5\0009\6\6\1>\6\3\5\18\6\2\0B\3\3\4\b\4\0\0X\6\aÄ-\6\2\0009\6\a\0069\6\b\6'\b\t\0\18\t\5\0&\b\t\bB\6\2\1-\6\3\0009\6\n\6B\6\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to stage path: \nerror\bgit\rfullpath\1\3\0\0\bgit\badd\16system_list\17git.toplevel\15tbl_access\fcurrent\16get_context\0Ù\1\0\0\t\4\n\1\31-\0\0\0009\0\0\0B\0\1\2-\1\1\0009\1\1\1\18\3\0\0'\4\2\0B\1\3\2\14\0\1\0X\2\1ÄK\0\1\0-\2\1\0009\2\3\0025\4\4\0009\5\5\0>\5\3\4\18\5\1\0B\2\3\4\b\3\0\0X\5\aÄ-\5\2\0009\5\6\0059\5\a\5'\a\b\0\18\b\4\0&\a\b\aB\5\2\1-\5\3\0009\5\t\5B\5\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to stage path: \nerror\bgit\bdir\1\3\0\0\bgit\badd\16system_list\17git.toplevel\15tbl_access\16get_context\0í\2\0\0\n\4\v\1\"-\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\2-\2\1\0009\2\2\2\18\4\0\0'\5\3\0B\2\3\2\14\0\2\0X\3\1ÄK\0\1\0-\3\1\0009\3\4\0035\5\5\0009\6\6\1>\6\4\5\18\6\2\0B\3\3\4\b\4\0\0X\6\aÄ-\6\2\0009\6\a\0069\6\b\6'\b\t\0\18\t\5\0&\b\t\bB\6\2\1-\6\3\0009\6\n\6B\6\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to reset path: \nerror\bgit\rfullpath\1\4\0\0\bgit\nreset\a--\16system_list\17git.toplevel\15tbl_access\fcurrent\16get_context\0˘\1\0\0\t\4\n\1\31-\0\0\0009\0\0\0B\0\1\2-\1\1\0009\1\1\1\18\3\0\0'\4\2\0B\1\3\2\14\0\1\0X\2\1ÄK\0\1\0-\2\1\0009\2\3\0025\4\4\0009\5\5\0>\5\4\4\18\5\1\0B\2\3\4\b\3\0\0X\5\aÄ-\5\2\0009\5\6\0059\5\a\5'\a\b\0\18\b\4\0&\a\b\aB\5\2\1-\5\3\0009\5\t\5B\5\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to reset path: \nerror\bgit\bdir\1\4\0\0\bgit\nreset\a--\16system_list\17git.toplevel\15tbl_access\16get_context\0Â\1\0\0\b\3\b\0%-\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\2-\2\1\0009\2\2\2\18\4\1\0'\5\3\0B\2\3\2\15\0\2\0X\3\aÄ\18\5\2\0009\3\4\2)\6\2\0)\a\2\0B\3\4\2\6\3\5\0X\3\4Ä-\3\2\0009\3\6\3B\3\1\1X\3\fÄ\15\0\2\0X\3\nÄ\18\5\2\0009\3\4\2)\6\1\0)\a\1\0B\3\4\2\15\0\3\0X\4\3Ä-\3\2\0009\3\a\3B\3\1\1K\0\1\0\4¿\b¿\0¿\14git_reset\14git_stage\6 \bsub\15git.status\15tbl_access\fcurrent\16get_context|\0\0\3\0\b\0\0156\0\0\0009\0\1\0009\0\2\0+\2\2\0B\0\2\0016\0\3\0009\0\4\0009\0\5\0\15\0\0\0X\1\4Ä6\0\3\0009\0\6\0'\2\a\0B\0\2\1K\0\1\0\rwincmd q\bcmd\17lir_is_float\6w\bvim\18remove_buffer\blib\vConfigE\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\5¿\fnorm! j\bcmd\bvim\16toggle_markE\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\5¿\fnorm! k\bcmd\bvim\16toggle_mark \0\0\1\0\1\0\0025\0\0\0L\0\2\0\1\0\1\vborder\vsingleö\2\0\1\t\1\t\0007-\1\0\0\18\3\1\0009\1\0\1-\4\0\0\18\6\4\0009\4\1\4\f\a\0\0X\a\1Ä'\a\2\0B\4\3\0A\1\1\2-\2\0\0\18\4\2\0009\2\3\2\18\5\1\0B\2\3\2\14\0\2\0X\3\23Ä-\2\0\0\18\4\2\0009\2\3\2-\5\0\0\18\a\5\0009\5\4\5\18\b\1\0B\5\3\2\14\0\5\0X\6\1Ä'\5\5\0B\2\3\2\14\0\2\0X\2\tÄ-\2\0\0\18\4\2\0009\2\0\0026\5\6\0009\5\a\5B\5\1\0A\2\1\2\18\1\2\0X\2\rÄ-\2\0\0\18\4\2\0009\2\b\2\18\5\1\0B\2\3\2\14\0\2\0X\2\6Ä-\2\0\0\18\4\2\0009\2\4\2\18\5\1\0B\2\3\2\18\1\2\0L\1\2\0\a¿\vis_dir\bcwd\auv\5\vparent\rreadable\6%\15vim_expand\rabsoluteW\0\1\t\1\5\0\r6\1\0\0009\1\1\1'\3\2\0006\4\0\0009\4\3\0049\4\4\4-\6\0\0\18\b\0\0B\6\2\0A\4\0\2&\3\4\3B\1\2\1K\0\1\0\r¿\16fnameescape\afn\ae \bcmd\bvimt\0\1\t\2\3\0\20+\1\0\0\15\0\0\0X\2\nÄ-\2\0\0\18\4\2\0009\2\0\2-\5\0\0\18\a\5\0009\5\1\5\18\b\0\0B\5\3\0A\2\1\2\18\1\2\0-\2\1\0009\2\2\2\f\4\1\0X\4\1Ä+\4\0\0B\2\2\1K\0\1\0\a¿\2¿\tinit\15vim_expand\rabsolute:\0\1\6\2\1\0\n-\1\0\0009\1\0\1-\3\1\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä+\3\0\0B\1\2\1K\0\1\0\2¿\r¿\vtoggleL\0\1\4\1\3\0\r-\1\0\0009\1\0\0019\3\1\0:\3\1\3\6\3\2\0X\3\4Ä9\3\1\0:\3\1\3\14\0\3\0X\4\1Ä+\3\0\0B\1\2\1K\0\1\0\n¿\5\nfargs\fexploreO\0\1\4\1\3\0\r-\1\0\0009\1\0\0019\3\1\0:\3\1\3\6\3\2\0X\3\4Ä9\3\1\0:\3\1\3\14\0\3\0X\4\1Ä+\3\0\0B\1\2\1K\0\1\0\n¿\5\nfargs\15open_floatô\n\1\0\19\0f\0î\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0026\3\0\0'\5\4\0B\3\2\0026\4\0\0'\6\5\0B\4\2\0026\5\0\0'\a\6\0B\5\2\0029\6\0\3'\b\a\0B\6\2\0026\a\b\0009\a\t\a9\a\n\a9\a\v\a6\b\b\0009\b\t\b9\b\n\b6\t\b\0009\t\t\t9\t\f\t4\n\0\0003\v\r\0003\f\14\0003\r\16\0=\r\15\0003\r\18\0=\r\17\0003\r\20\0=\r\19\0003\r\22\0=\r\21\0003\r\24\0=\r\23\0003\r\26\0=\r\25\0003\r\28\0=\r\27\0003\r\30\0=\r\29\0006\r\0\0'\15\5\0B\r\2\0029\r\31\r5\15 \0005\16!\0009\17\15\0=\17\"\0169\17#\0=\17$\0169\17#\0=\17%\0169\17#\0=\17&\0169\17'\0=\17(\0169\17)\0=\17*\0169\17+\0=\17,\0169\17-\0=\17.\0169\17-\0=\17/\0163\0170\0=\0171\0169\0172\0=\0173\0169\17\19\0=\0174\0169\17\17\0=\0175\0169\0176\0=\0177\0169\0178\0=\0179\0169\17:\0=\17;\0169\17<\0=\17=\0169\17>\5=\17?\0163\17@\0=\17A\0163\17B\0=\17C\0169\17D\1=\17E\0169\17F\1=\17G\0169\17H\1=\17I\0169\17\29\0=\17J\0169\17\23\0=\17K\0169\17\25\0=\17L\0169\17\27\0=\17M\16=\16N\0155\16O\0003\17P\0=\17Q\16=\16R\15B\r\2\0016\r\0\0'\15S\0B\r\2\0029\r\31\r5\15T\0B\r\2\0013\rU\0003\14W\0=\14V\n3\14Y\0=\14X\n3\14[\0=\14Z\n6\14\\\0009\14]\0149\14^\14'\16_\0003\17`\0005\18a\0B\14\4\0016\14\\\0009\14]\0149\14^\14'\16b\0003\17c\0005\18d\0B\14\4\0016\14\b\0009\14e\14=\n\5\0142\0\0ÄK\0\1\0\vplugin\1\0\3\bbar\2\nnargs\6?\rcomplete\bdir\0\rLirFloat\1\0\3\bbar\2\nnargs\6?\rcomplete\bdir\0\15LirExplore\29nvim_create_user_command\bapi\bvim\0\17toggle_float\0\15open_float\0\fexplore\0\1\0\1\17show_ignored\2\19lir.git_status\nfloat\rwin_opts\0\1\0\1\rwinblend\3\0\rmappings\6U\6u\6S\6s\6p\npaste\6x\bcut\6y\tcopy\6K\0\6J\0\6t\16toggle_mark\6d\vdelete\n<C-h>\23toggle_show_hidden\agy\14yank_path\n<C-]>\acd\6m\6a\6e\fnewfile\6q\0\6h\6-\aup\n<C-t>\ftabedit\n<C-v>\vvsplit\n<C-s>\nsplit\6l\6o\t<CR>\tedit\6R\1\0\0\1\0\3\22show_hidden_files\2\20devicons_enable\2\16hide_cursor\2\nsetup\0\21git_toggle_stage\0\18git_reset_all\0\14git_reset\0\18git_stage_all\0\14git_stage\0\17create_paths\0\tmove\0\vreload\0\0\vnotify\apl\nutils\vcommon\vConfig\24diffview.arg_parser\21lir.mark.actions\blir\14user.lazy\14lir.float\26lir.clipboard.actions\16lir.actions\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/lir.nvim",
    url = "https://github.com/tamago324/lir.nvim"
  },
  ["lsp-trouble.nvim"] = {
    config = { "\27LJ\2\ng\0\0\4\1\4\0\b-\0\0\0009\0\0\0005\2\2\0005\3\1\0=\3\3\2B\0\2\2:\0\1\0L\0\2\0\1¿\foptions\1\0\2\14no_hidden\2\ftabpage\3\0\1\0\1\rfiletype\fTrouble\14list_bufs+\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\fTrouble\bcmd\bvim;\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\28wincmd p | TroubleClose\bcmd\bvimŒ\4\1\0\t\0\19\0\0276\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0019\1\4\0016\2\0\0'\4\5\0B\2\2\0029\2\6\0025\4\a\0005\5\b\0=\5\t\0045\5\n\0=\5\v\4B\2\2\0016\2\2\0009\2\f\0029\3\14\0003\5\15\0003\6\16\0003\a\17\0005\b\18\0B\3\5\2=\3\r\0022\0\0ÄK\0\1\0\1\0\2\nfocus\2\20remember_height\2\0\0\0\23create_buf_toggler\23toggle_diagnostics\afn\nsigns\1\0\4\fwarning\bÔî©\nerror\bÔôô\16information\bÔëâ\thint\bÔ†µ\16action_keys\1\0\v\nclose\6q\fpreview\6p\16close_folds\azM\15open_folds\azR\vcancel\n<esc>\tnext\6j\rprevious\6k\frefresh\6R\tjump\t<cr>\16toggle_mode\6m\19toggle_preview\6P\1\0\n\vheight\3\n\17auto_preview\1\nicons\2\tmode\26workspace_diagnostics\14fold_open\bÔëº\17indent_lines\2\14auto_open\1\29use_lsp_diagnostic_signs\1\15auto_close\1\16fold_closed\bÔë†\nsetup\ftrouble\nutils\vcommon\vConfig\ruser.lib\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/lsp-trouble.nvim",
    url = "https://github.com/folke/lsp-trouble.nvim"
  },
  ["lsp_signature.nvim"] = {
    config = { "\27LJ\2\nü\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\17handler_opts\1\0\1\vborder\vsingle\1\0\4\16hint_prefix\t‚óè \14max_width\3P\15max_height\3\f\16hint_enable\1\nsetup\18lsp_signature\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/lsp_signature.nvim",
    url = "https://github.com/ray-x/lsp_signature.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/lua-dev.nvim",
    url = "https://github.com/sindrets/lua-dev.nvim"
  },
  ["lush.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/lush.nvim",
    url = "https://github.com/rktjmp/lush.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/markdown-preview.nvim",
    url = "https://github.com/iamcco/markdown-preview.nvim"
  },
  ["material.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/material.nvim",
    url = "https://github.com/sindrets/material.nvim"
  },
  neogit = {
    config = { "\27LJ\2\nÏ\5\0\0\b\0!\0/4\0\0\0006\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0005\4\4\0=\4\5\0035\4\a\0005\5\6\0=\5\b\0045\5\t\0=\5\n\0045\5\v\0=\5\f\4=\4\r\0035\4\14\0=\4\15\0035\4\17\0005\5\16\0=\5\18\4=\4\19\0035\4\21\0005\5\20\0=\5\5\4=\4\22\3B\1\2\0016\1\23\0009\1\24\0019\1\25\0019\1\26\1'\3\27\0004\4\0\0004\5\4\0005\6\28\0>\6\1\0055\6\30\0005\a\29\0>\a\1\6>\6\2\0055\6\31\0>\6\3\5B\1\4\0016\1\23\0009\1 \1=\0\1\1K\0\1\0\vplugin\1\2\2\0\rBufLeave\fpattern\21NeogitCommitView\fcommand\"setl eventignore-=CursorMoved\1\0\2\fpattern\21NeogitCommitView\fcommand\"setl eventignore+=CursorMoved\1\3\0\0\rBufEnter\rFileType\1\2\2\0\rFileType\fpattern\fNeogit*\fcommand\16setl nolist\18neogit_config\18declare_group\aau\vcommon\vConfig\rmappings\1\0\0\1\0\1\6B\16BranchPopup\rsections\vrecent\1\0\0\1\0\1\vfolded\1\17integrations\1\0\1\rdiffview\2\nsigns\thunk\1\3\0\0\5\5\titem\1\3\0\0\bÔÉö\bÔÉó\fsection\1\0\0\1\3\0\0\bÔë†\bÔëº\vstatus\1\0\1\24recent_commit_count\3\n\1\0\4\17disable_hint\2!disable_context_highlighting\1\"disable_builtin_notifications\2\18disable_signs\1\nsetup\vneogit\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/neogit",
    url = "https://github.com/TimUntersberger/neogit"
  },
  neorg = {
    cond = { 1 },
    config = { "\27LJ\2\n÷\3\0\0\a\0\27\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\25\0005\3\b\0005\4\6\0005\5\4\0005\6\3\0=\6\5\5=\5\a\4=\4\t\0034\4\0\0=\4\n\0034\4\0\0=\4\v\0034\4\0\0=\4\f\0034\4\0\0=\4\r\0035\4\17\0005\5\15\0005\6\14\0=\6\16\5=\5\a\4=\4\18\0035\4\20\0005\5\19\0=\5\a\4=\4\21\0035\4\23\0005\5\22\0=\5\a\4=\4\24\3=\3\26\2B\0\2\1K\0\1\0\tload\1\0\0\18core.gtd.base\1\0\0\1\0\1\14workspace\buni\25core.norg.completion\1\0\0\1\0\1\vengine\rnvim-cmp\21core.norg.dirman\1\0\0\15workspaces\1\0\0\1\0\1\buni\26~/Documents/uni/notes\16core.export\24core.norg.concealer core.integrations.telescope\22core.norg.qol.toc\18core.defaults\1\0\0\vconfig\1\0\0\fdisable\1\0\0\1\2\0\0\31core.norg.esupports.indent\nsetup\nneorg\frequire\0" },
    load_after = {},
    loaded = false,
    needs_bufread = true,
    only_cond = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/neorg",
    url = "https://github.com/nvim-neorg/neorg"
  },
  ["neorg-telescope"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/neorg-telescope",
    url = "https://github.com/nvim-neorg/neorg-telescope"
  },
  ["neoscroll.nvim"] = {
    config = { "\27LJ\2\nè\1\2\1\5\1\a\0\0196\1\0\0009\1\1\0019\1\2\0016\2\0\0009\2\3\2'\3\4\0=\3\2\2-\2\0\0008\2\0\2G\4\1\0A\2\0\0016\2\0\0009\2\3\2=\1\2\0026\2\0\0009\2\5\2'\4\6\0B\2\2\1K\0\1\0\0¿ do <nomodeline> WinScrolled\bcmd\ball\bopt\16eventignore\6o\bvimb\0\0\a\2\6\0\15-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0036\5\4\0009\5\5\0059\5\1\5)\6\16\0B\3\3\2\20\3\3\0+\4\2\0-\5\1\0B\0\5\1K\0\1\0\1¿\2¿\awo\bvim\bmax\tmath\vscroll\brun^\0\0\a\2\6\0\14-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0036\5\4\0009\5\5\0059\5\1\5)\6\16\0B\3\3\2+\4\2\0-\5\1\0B\0\5\1K\0\1\0\1¿\2¿\awo\bvim\bmax\tmath\vscroll\brunk\0\0\6\2\5\1\14-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0039\3\4\3)\5\0\0B\3\2\2\20\3\3\0+\4\2\0-\5\1\0\24\5\0\5B\0\5\1K\0\1\0\1¿\2¿\24nvim_win_get_height\bapi\bvim\vscroll\brun\4g\0\0\6\2\5\1\r-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0039\3\4\3)\5\0\0B\3\2\2+\4\2\0-\5\1\0\24\5\0\5B\0\5\1K\0\1\0\1¿\2¿\24nvim_win_get_height\bapi\bvim\vscroll\brun\4*\0\0\4\2\2\0\6-\0\0\0009\0\0\0'\2\1\0-\3\1\0B\0\3\1K\0\1\0\1¿\2¿\azt\brun*\0\0\4\2\2\0\6-\0\0\0009\0\0\0'\2\1\0-\3\1\0B\0\3\1K\0\1\0\1¿\2¿\azz\brun*\0\0\4\2\2\0\6-\0\0\0009\0\0\0'\2\1\0-\3\1\0B\0\3\1K\0\1\0\1¿\2¿\azb\brunä\4\1\0\b\0\28\0E6\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0014\2\0\0=\2\1\0016\1\2\0009\1\3\0019\1\1\0019\2\4\0005\4\6\0005\5\5\0=\5\a\4B\2\2\0013\2\t\0=\2\b\1)\2¥\0006\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\14\0003\a\15\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\16\0003\a\17\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\18\0003\a\19\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\20\0003\a\21\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\22\0003\a\23\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\24\0003\a\25\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\26\0003\a\27\0B\3\4\0012\0\0ÄK\0\1\0\0\azb\0\azz\0\azt\0\n<C-f>\0\n<C-b>\0\n<C-d>\0\n<C-u>\6n\bset\vkeymap\bvim\0\brun\rmappings\1\0\5\rstop_eof\2\16hide_cursor\2\20easing_function\14quadratic\22respect_scrolloff\1\25cursor_scrolls_alone\2\1\b\0\0\n<C-u>\n<C-d>\n<C-b>\n<C-f>\azt\azz\azb\nsetup\vplugin\vConfig\14neoscroll\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/neoscroll.nvim",
    url = "https://github.com/karb94/neoscroll.nvim"
  },
  nerdcommenter = {
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/nerdcommenter",
    url = "https://github.com/scrooloose/nerdcommenter"
  },
  ["null-ls.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-autopairs"] = {
    after = { "nvim-cmp" },
    config = { "\27LJ\2\nã\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\29html_break_line_filetype\1\6\0\0\thtml\bvue\20typescriptreact\vsvelte\20javascriptreact\21disable_filetype\1\0\3\30enable_check_bracket_line\1\rcheck_ts\2\22ignored_next_char\19[%w%%%'%[%\"%.]\1\2\0\0\20TelescopePrompt\nsetup\19nvim-autopairs\frequire\0" },
    loaded = true,
    only_config = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs"
  },
  ["nvim-block-paste"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-block-paste",
    url = "https://github.com/Rasukarusan/nvim-block-paste"
  },
  ["nvim-bqf"] = {
    config = { "\27LJ\2\n∆\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\fpreview\1\0\0\17border_chars\1\n\0\0\b‚îÇ\b‚îÇ\b‚îÄ\b‚îÄ\b‚îå\b‚îê\b‚îî\b‚îò\b‚ñà\1\0\5\17delay_syntax\0032\17auto_preview\1\16win_vheight\3\15\twrap\1\15win_height\3\15\nsetup\bbqf\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-bqf",
    url = "https://github.com/kevinhwang91/nvim-bqf"
  },
  ["nvim-bufferline.lua"] = {
    config = { "\27LJ\2\nk\0\3\15\1\5\0\17'\3\0\0006\4\1\0\18\6\2\0B\4\2\4H\a\tÄ6\t\2\0009\t\3\t'\v\4\0\18\f\3\0-\r\0\0008\r\a\r\18\14\b\0B\t\5\2\18\3\t\0F\a\3\3R\aı\127L\3\2\0\1¿\r%s %s %d\vformat\vstring\npairs\5ú\6\1\0\b\0\22\0!6\0\0\0009\0\1\0009\0\2\0009\0\3\0005\1\4\0006\2\5\0'\4\6\0B\2\2\0029\2\a\0025\4\16\0005\5\b\0003\6\t\0=\6\n\0055\6\v\0=\6\f\0054\6\3\0005\a\r\0>\a\1\0065\a\14\0>\a\2\6=\6\15\5=\5\17\4B\2\2\1\18\2\0\0'\4\18\0005\5\19\0B\2\3\1\18\2\0\0'\4\20\0005\5\21\0B\2\3\0012\0\0ÄK\0\1\0\1\0\1\nstyle\tbold BufferLineDiagnosticVisible\1\0\1\nstyle\tbold\25BufferLineDiagnostic\foptions\1\0\0\foffsets\1\0\3\rfiletype\18DiffviewFiles\15text_align\vcenter\ttext\19Source Control\1\0\3\rfiletype\rNvimTree\15text_align\vcenter\ttext\nFiles\20separator_style\1\3\0\0\b‚îÇ\b‚îÇ\26diagnostics_indicator\0\1\0\16\15close_icon\bÔÄç\fnumbers\tnone\18modified_icon\b‚óè\23right_trunc_marker\bÔÇ©\22buffer_close_icon\bÔôï\22left_trunc_marker\bÔÇ®\tview\fdefault\20max_name_length\3\18\22max_prefix_length\3\15\rtab_size\3\18\16diagnostics\rnvim_lsp\28show_buffer_close_icons\2\20show_close_icon\1\24persist_buffer_sort\2\25enforce_regular_tabs\1\27always_show_bufferline\2\nsetup\15bufferline\frequire\1\0\4\fwarning\bÔÅ±\nerror\bÔÅó\tinfo\bÔÅö\thint\bÔÅ™\ahi\ahl\vcommon\vConfig\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/nvim-bufferline.lua",
    url = "https://github.com/akinsho/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    config = { "\27LJ\2\n;\0\1\4\0\4\0\0066\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\20vsnip#anonymous\afn\bvim’\1\0\2\4\1\5\0\n-\2\0\0009\3\0\0018\2\3\2=\2\0\0015\2\2\0009\3\3\0009\3\4\0038\2\3\2=\2\1\1L\1\2\0\4¿\tname\vsource\1\0\n\nemoji\f[Emoji]\bgit\n[VCS]\forgmode\n[Org]\nneorg\f[Neorg]\nspell\f[Spell]\tcalc\v[Calc]\fluasnip\14[Luasnip]\rnvim_lsp\n[LSP]\tpath\v[Path]\vbuffer\r[Buffer]\tmenu\tkindq\0\1\a\1\2\1\15-\1\0\0009\1\0\1\18\3\0\0-\4\0\0009\4\1\4\18\6\0\0B\4\2\0A\1\1\2*\2\0\0\0\1\2\0X\2\2Ä+\2\1\0X\3\1Ä+\2\2\0L\2\2\0\0\0\24nvim_buf_line_count\24nvim_buf_get_offsetÄÄÄ\1à\1\1\0\t\2\a\0\0166\0\0\0009\0\1\0003\2\2\0-\3\1\0009\3\3\3-\5\1\0009\5\4\0055\a\5\0B\5\2\2-\6\1\0009\6\4\0065\b\6\0B\6\2\0A\3\1\0002\0\0ÄC\0\1\0\2¿\3¿\1\0\1\14no_hidden\2\1\0\1\vlisted\2\14list_bufs\14vec_union\0\15tbl_filter\bvim©\v\1\0\15\0@\0h6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\3\0009\2\4\0026\3\5\0009\3\6\0039\3\a\0035\4\b\0009\5\t\0\18\a\5\0009\5\n\5B\5\2\0019\5\v\0005\a\15\0005\b\r\0003\t\f\0=\t\14\b=\b\16\a9\b\17\0009\b\18\b9\b\19\b5\n\21\0009\v\17\0009\v\20\v)\r¸ˇB\v\2\2=\v\22\n9\v\17\0009\v\20\v)\r\4\0B\v\2\2=\v\23\n9\v\17\0009\v\24\vB\v\1\2=\v\25\n9\v\17\0009\v\26\vB\v\1\2=\v\27\n9\v\17\0009\v\28\v5\r\29\0009\14\30\0009\14\31\14=\14 \rB\v\2\2=\v!\nB\b\2\2=\b\17\a5\b\"\0005\t#\0=\t$\b3\t%\0=\t&\b=\b'\a5\b)\0005\t(\0=\t*\b=\b+\a4\b\t\0005\t,\0>\t\1\b5\t-\0>\t\2\b5\t.\0>\t\3\b5\t/\0>\t\4\b5\t0\0>\t\5\b5\t1\0>\t\6\b5\t2\0>\t\a\b5\t3\0005\n5\0003\v4\0=\v6\n=\n7\t>\t\b\b=\b8\aB\5\2\0019\5\t\0\18\a\5\0009\0059\5'\b:\0009\t;\1B\t\1\0A\5\2\0016\5\0\0'\a<\0B\5\2\0029\5\v\0055\a>\0005\b=\0=\b?\aB\5\2\0012\0\0ÄK\0\1\0\14filetypes\1\0\0\1\5\0\0\14gitcommit\24NeogitCommitMessage\rmarkdown\tocto\fcmp_git\20on_confirm_done\17confirm_done\aon\fsources\voption\15get_bufnrs\1\0\0\0\1\0\2\19max_item_count\3\20\tname\vbuffer\1\0\1\tname\tpath\1\0\1\tname\nspell\1\0\1\tname\bgit\1\0\1\tname\nneorg\1\0\1\tname\nvsnip\1\0\1\tname\rnvim_lsp\1\0\1\tname\rnvim_lua\vwindow\18documentation\1\0\0\1\0\3\17winhighlight0Normal:Normal,CursorLine:Visual,Search:None\vzindex\3È\a\vborder\vsingle\15formatting\vformat\0\vfields\1\4\0\0\tkind\tabbr\tmenu\1\0\1\15deprecated\2\t<CR>\rbehavior\vInsert\20ConfirmBehavior\1\0\1\vselect\1\fconfirm\n<C-e>\nclose\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\nclear\nevent\1\0\25\14Reference\n ÔíÅ \nValue\n Ô¢ü \fSnippet\n Ôóè \tEnum\n Ô©ó \tUnit\n Ô•¨ \tText\n Ôî´ \14Interface\t Ô®†\vStruct\n ÔÜ≥ \nClass\n Ô†ñ \16Constructor\n Óàè \vFolder\n Ô±Æ \rConstant\n Ôõº \rVariable\n[Óúñ]\rOperator\n Ôöî \nField\n Óúñ \15EnumMember\n ÔÖù \nColor\n Óà´ \nEvent\n ÔÉß \18TypeParameter\n<ÔûÉ>\rFunction\n Óûõ \rProperty\n ÔÇ≠ \vMethod\n Óûõ \vModule\n Ôô® \tFile\n ÔÖõ \fKeyword\n Ôùß \nutils\vcommon\vConfig\bapi\bvim\"nvim-autopairs.completion.cmp\bcmp\frequire\0" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n≥\2\0\0\4\0\v\0\0146\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\0025\3\n\0B\0\3\1K\0\1\0\1\0\t\vrgb_fn\1\vhsl_fn\1\vcss_fn\1\tmode\15background\bRGB\2\vRRGGBB\2\rRRGGBBAA\2\bcss\1\nnames\1\tsass\1\0\5\vrgb_fn\2\vhsl_fn\2\vcss_fn\2\bcss\2\nnames\2\tscss\1\0\5\vrgb_fn\2\vhsl_fn\2\vcss_fn\2\bcss\2\nnames\2\bcss\1\0\5\vrgb_fn\2\vhsl_fn\2\vcss_fn\2\bcss\2\nnames\2\1\3\0\0\6*\t!git\nsetup\14colorizer\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/sindrets/nvim-colorizer.lua"
  },
  ["nvim-jdtls"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-jdtls",
    url = "https://github.com/mfussenegger/nvim-jdtls"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-notify"] = {
    config = { "\27LJ\2\nP\0\0\4\0\4\0\f6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\0016\0\3\0006\1\0\0'\3\1\0B\1\2\2=\1\1\0K\0\1\0\bvim\nsetup\vnotify\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-notify",
    url = "https://github.com/rcarriga/nvim-notify"
  },
  ["nvim-pqf.git"] = {
    config = { "\27LJ\2\nq\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\nsigns\1\0\0\1\0\4\fwarning\bÔÅ±\nerror\bÔÅó\tinfo\bÔÅö\thint\bÔÅ™\nsetup\bpqf\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-pqf.git",
    url = "https://gitlab.com/yorickpeterse/nvim-pqf"
  },
  ["nvim-treesitter"] = {
    after = { "neorg" },
    config = { "\27LJ\2\nø\1\0\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0005\4\a\0=\4\b\3=\3\t\2B\0\2\1K\0\1\0\14highlight\fdisable\1\4\0\0\bvim\thelp\6c\1\0\1\venable\2\19ignore_install\1\2\0\0\vphpdoc\1\0\1\21ensure_installed\ball\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    only_config = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-ts-rainbow"] = {
    config = { "\27LJ\2\n”\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\frainbow\1\0\0\vcolors\1\b\0\0\f#bf616a\f#d08770\f#ebcb8b\f#a3be8c\f#88c0d0\f#5e81ac\f#b48ead\1\0\3\18extended_mode\2\venable\2\19max_file_lines\3∏\23\nsetup\28nvim-treesitter.configs\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-ts-rainbow",
    url = "https://github.com/p00f/nvim-ts-rainbow"
  },
  ["nvim-web-devicons"] = {
    after = { "lsp-trouble.nvim", "nvim-bufferline.lua", "lir.nvim", "telescope.nvim", "incline.nvim" },
    config = { "\27LJ\2\nŒ\5\0\0\5\0\30\0!6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\28\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\0035\4\14\0=\4\15\0035\4\16\0=\4\17\0035\4\18\0=\4\19\0035\4\20\0=\4\21\0035\4\22\0=\4\23\0035\4\24\0=\4\25\0035\4\26\0=\4\27\3=\3\29\2B\0\2\1K\0\1\0\roverride\1\0\1\fdefault\2\npatch\1\0\3\ncolor\f#41535b\ticon\bÓú®\tname\nPatch\20lir_folder_icon\1\0\3\ncolor\f#7ebae4\ticon\bÔêì\tname\18LirFolderNode\rmakefile\1\0\3\ncolor\f#6d8086\ticon\bÓòï\tname\rMakefile\rMakefile\1\0\3\ncolor\f#6d8086\ticon\bÓòï\tname\rMakefile\brkt\1\0\3\ncolor\f#264B8B\ticon\bÔ¨¶\tname\vRacket\bscm\1\0\3\ncolor\f#264B8B\ticon\bÔ¨¶\tname\vScheme\tlisp\1\0\3\ncolor\f#264B8B\ticon\bÔ¨¶\tname\tLisp\ael\1\0\3\ncolor\f#5D439C\ticon\bÔ¨¶\tname\nElisp\atl\1\0\3\ncolor\f#51a0cf\ticon\bÓò†\tname\tTeal\6m\1\0\3\ncolor\f#599eff\ticon\bÓòû\tname\fCModule\acs\1\0\3\ncolor\f#0d5786\ticon\bÔ†ö\tname\aCs\bxml\1\0\0\1\0\3\ncolor\f#e37933\ticon\bÓòé\tname\bXml\nsetup\22nvim-web-devicons\frequire\0" },
    loaded = true,
    only_config = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["onedarkpro.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/onedarkpro.nvim",
    url = "https://github.com/olimorris/onedarkpro.nvim"
  },
  ["oxocarbon-lua.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/oxocarbon-lua.nvim",
    url = "https://github.com/sindrets/oxocarbon-lua.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["palenight.vim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/palenight.vim",
    url = "https://github.com/Cybolic/palenight.vim"
  },
  playground = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/popup.nvim",
    url = "https://github.com/nvim-lua/popup.nvim"
  },
  ["rose-pine"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/rose-pine",
    url = "https://github.com/sindrets/rose-pine-neovim"
  },
  ["spellsitter.nvim"] = {
    config = { "\27LJ\2\nI\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\fenabled\2\nsetup\16spellsitter\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/spellsitter.nvim",
    url = "https://github.com/lewis6991/spellsitter.nvim"
  },
  ["startuptime.vim"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/startuptime.vim",
    url = "https://github.com/tweekmonster/startuptime.vim"
  },
  ["symbols-outline.nvim"] = {
    commands = { "SymbolsOutline", "SymbolsOutlineClose", "SymbolsOutlineOpen" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/symbols-outline.nvim",
    url = "https://github.com/simrat39/symbols-outline.nvim"
  },
  tabular = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/tabular",
    url = "https://github.com/godlygeek/tabular"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-media-files.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/telescope-media-files.nvim",
    url = "https://github.com/nvim-telescope/telescope-media-files.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/telescope-ui-select.nvim",
    url = "https://github.com/nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    after = { "neorg" },
    config = { "\27LJ\2\nN\0\0\6\1\4\0\t6\0\0\0009\0\1\0'\2\2\0\18\4\2\0009\2\3\2-\5\0\0B\2\3\0A\0\0\1K\0\1\0\1¿\vformat\22DiffviewOpen %s^!\bcmd\bvim¢\1\1\0\6\1\t\0\20-\0\0\0009\0\0\0B\0\1\0029\1\1\0006\2\2\0009\2\3\0029\2\4\2)\4\0\0+\5\2\0B\2\3\0016\2\2\0009\2\5\2'\4\6\0B\2\2\0016\2\2\0009\2\a\0023\4\b\0B\2\2\0012\0\0ÄK\0\1\0\1¿\0\rschedule\15stopinsert\bcmd\19nvim_win_close\bapi\bvim\nvalue\23get_selected_entryÅ\15\1\0\n\0N\1é\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0029\2\4\0025\0041\0005\5\6\0005\6\5\0=\6\a\0055\6\b\0005\a\t\0=\a\n\0065\a\v\0=\a\f\6=\6\r\0055\6\14\0=\6\15\0056\6\0\0'\b\16\0B\6\2\0029\6\17\6=\6\18\0054\6\0\0=\6\19\0056\6\0\0'\b\16\0B\6\2\0029\6\20\6=\6\21\0054\6\0\0=\6\22\0055\6\23\0=\6\24\0055\6\25\0=\6\26\0056\6\0\0'\b\27\0B\6\2\0029\6\28\0069\6\29\6=\6\30\0056\6\0\0'\b\27\0B\6\2\0029\6\31\0069\6\29\6=\6 \0056\6\0\0'\b\27\0B\6\2\0029\6!\0069\6\29\6=\6\"\0056\6\0\0'\b\27\0B\6\2\0029\6#\6=\6#\0055\6,\0005\a&\0009\b$\0009\t%\0 \b\t\b=\b'\a9\b(\0=\b)\a9\b*\0=\b+\a=\a-\0065\a.\0009\b(\0=\b)\a9\b*\0=\b+\a=\a/\6=\0060\5=\0052\0045\0054\0005\0063\0=\0065\0055\0066\0=\0067\0055\0068\0=\0069\0055\6>\0005\a=\0005\b;\0003\t:\0=\t<\b=\b-\a=\a0\6=\6?\5=\5@\0045\5B\0005\6A\0=\6C\0055\6E\0005\aD\0=\aF\6=\6G\0054\6\3\0006\a\0\0'\tH\0B\a\2\0029\aI\a4\t\0\0B\a\2\0?\a\0\0=\6J\5=\5K\4B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4M\0B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4C\0B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4G\0B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4J\0B\2\2\0012\0\0ÄK\0\1\0\vnotify\19load_extension\15extensions\14ui-select\17get_dropdown\21telescope.themes\16media_files\14filetypes\1\0\1\rfind_cmd\afd\1\b\0\0\bpng\twebp\bjpg\tjpeg\bmp4\twebm\bpdf\bfzf\1\0\0\1\0\4\nfuzzy\2\14case_mode\15smart_case\28override_generic_sorter\1\25override_file_sorter\2\fpickers\16git_commits\1\0\0\1\0\0\f<C-M-d>\1\0\0\0\15git_status\1\0\1\15expand_dir\1\14git_files\1\0\1\18results_title\1\15find_files\1\0\0\1\0\1\18results_title\1\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<c-f>\27preview_scrolling_down\n<c-b>\25preview_scrolling_up\n<c-q>\1\0\1\n<c-j>\1\16open_qflist\19send_to_qflist\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚îå\b‚îê\b‚îò\b‚îî\vborder\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\16file_sorter\19get_fuzzy_file\22telescope.sorters\17path_display\1\2\0\0\rabsolute\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\1\vmirror\1\1\0\3\20prompt_position\btop\nwidth\4\0ÄÄ†ˇ\3\19preview_cutoff\3x\22vimgrep_arguments\1\0\v\rwinblend\3\0\17entry_prefix\a  \17initial_mode\vinsert\23selection_strategy\nreset\20layout_strategy\15horizontal\19color_devicons\2\ruse_less\2\21sorting_strategy\14ascending\18prompt_prefix\n Ôë´ \20selection_caret\t‚û§ \18results_title\1\1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\14telescope\28telescope.actions.state\22telescope.actions\frequire\3ÄÄ¿ô\4\0" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["tokyonight.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/tokyonight.nvim",
    url = "https://github.com/folke/tokyonight.nvim"
  },
  ["typescript.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/typescript.nvim",
    url = "https://github.com/jose-elias-alvarez/typescript.nvim"
  },
  ["vim-abolish"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-abolish",
    url = "https://github.com/tpope/vim-abolish"
  },
  ["vim-closetag"] = {
    loaded = true,
    needs_bufread = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/vim-closetag",
    url = "https://github.com/alvan/vim-closetag"
  },
  ["vim-colors-xcode"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-colors-xcode",
    url = "https://github.com/arzg/vim-colors-xcode"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-devicons",
    url = "https://github.com/ryanoasis/vim-devicons"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-illuminate"] = {
    config = { "\27LJ\2\në\4\0\0\4\0\14\0\0216\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0024\3\0\0=\3\v\0024\3\0\0=\3\f\0024\3\0\0=\3\r\2B\0\2\1K\0\1\0%providers_regex_syntax_allowlist$providers_regex_syntax_denylist\20modes_allowlist\19modes_denylist\1\21\0\0\ant\6v\avs\6V\aVs\6\22\a\22s\6s\6S\6\19\6i\aic\aix\6R\aRc\aRx\aRv\bRvc\bRvx\6t\24filetypes_allowlist\23filetypes_denylist\1\16\0\0\fdirvish\rfugitive\aqf\14dashboard\nalpha\vpacker\17NeogitStatus\21NeogitCommitView\20TelescopePrompt\rNvimTree\fTrouble\18DiffviewFiles\24DiffviewFileHistory\fOutline\blir\14providers\1\0\2\17under_cursor\2\ndelay\3˙\1\1\4\0\0\blsp\15treesitter\nregex\14configure\15illuminate\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-illuminate",
    url = "https://github.com/RRethy/vim-illuminate"
  },
  ["vim-jsonc"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-jsonc",
    url = "https://github.com/kevinoid/vim-jsonc"
  },
  ["vim-kitty"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-kitty",
    url = "https://github.com/fladson/vim-kitty"
  },
  ["vim-log-highlighting"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-log-highlighting",
    url = "https://github.com/MTDL9/vim-log-highlighting"
  },
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-rhubarb",
    url = "https://github.com/tpope/vim-rhubarb"
  },
  ["vim-snippets"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-snippets",
    url = "https://github.com/honza/vim-snippets"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-teal"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-teal",
    url = "https://github.com/teal-language/vim-teal"
  },
  ["vim-vsnip"] = {
    loaded = true,
    needs_bufread = false,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/opt/vim-vsnip",
    url = "https://github.com/hrsh7th/vim-vsnip"
  },
  ["vim-vsnip-integ"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/vim-vsnip-integ",
    url = "https://github.com/hrsh7th/vim-vsnip-integ"
  },
  ["winshift.nvim"] = {
    config = { "\27LJ\2\n∏\3\0\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\23moving_win_options\1\0\4\16colorcolumn\5\17cursorcolumn\1\twrap\1\15cursorline\1\fkeymaps\18win_move_mode\1\0\16\6j\tdown\r<S-left>\rfar_left\6k\aup\r<S-down>\rfar_down\6l\nright\v<down>\tdown\v<left>\tleft\f<right>\nright\6L\14far_right\6J\rfar_down\6H\rfar_left\14<S-right>\14far_right\t<up>\aup\v<S-up>\vfar_up\6h\tleft\6K\vfar_up\1\0\1\21disable_defaults\1\1\0\2\21focused_hl_group\21LspReferenceRead\25highlight_moving_win\2\nsetup\rwinshift\frequire\0" },
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/winshift.nvim",
    url = "https://github.com/sindrets/winshift.nvim"
  },
  ["zenbones.nvim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/zenbones.nvim",
    url = "https://github.com/mcchrish/zenbones.nvim"
  },
  ["zoomwintab.vim"] = {
    loaded = true,
    path = "/Users/marwanfikrat/.local/share/nvim/site/pack/packer/start/zoomwintab.vim",
    url = "https://github.com/troydm/zoomwintab.vim"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: symbols-outline.nvim
time([[Setup for symbols-outline.nvim]], true)
try_loadstring("\27LJ\2\n◊\2\0\0\5\0\r\0\0176\0\0\0009\0\1\0009\0\2\0009\0\3\0006\1\4\0009\1\5\0015\2\a\0005\3\b\0=\3\t\0024\3\0\0=\3\n\2=\2\6\1\18\1\0\0'\3\v\0'\4\f\0B\1\3\1K\0\1\0\vVisual\18FocusedSymbol\18lsp_blacklist\fkeymaps\1\0\6\19focus_location\6o\18goto_location\t<Cr>\17hover_symbol\14<C-space>\18rename_symbol\6r\17code_actions\14<leader>.\nclose\6q\1\0\4\16show_guides\2\17auto_preview\1\27highlight_hovered_item\2\rposition\nright\20symbols_outline\6g\bvim\fhi_link\ahl\vcommon\vConfig\0", "setup", "symbols-outline.nvim")
time([[Setup for symbols-outline.nvim]], false)
-- Setup for: vim-vsnip
time([[Setup for vim-vsnip]], true)
try_loadstring("\27LJ\2\ng\0\0\4\0\a\0\v6\0\0\0009\0\1\0006\1\0\0009\1\3\0019\1\4\1'\3\5\0B\1\2\2'\2\6\0&\1\2\1=\1\2\0K\0\1\0\14/snippets\vconfig\fstdpath\afn\22vsnip_snippet_dir\6g\bvim\0", "setup", "vim-vsnip")
time([[Setup for vim-vsnip]], false)
time([[packadd for vim-vsnip]], true)
vim.cmd [[packadd vim-vsnip]]
time([[packadd for vim-vsnip]], false)
-- Setup for: indent-blankline.nvim
time([[Setup for indent-blankline.nvim]], true)
try_loadstring("\27LJ\2\n \a\0\0\2\0\16\0%6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0006\0\0\0009\0\1\0+\1\2\0=\1\6\0006\0\0\0009\0\1\0+\1\1\0=\1\a\0006\0\0\0009\0\1\0+\1\2\0=\1\b\0006\0\0\0009\0\1\0)\1\2\0=\1\t\0006\0\0\0009\0\1\0005\1\v\0=\1\n\0006\0\0\0009\0\1\0005\1\r\0=\1\f\0006\0\0\0009\0\1\0005\1\15\0=\1\14\0K\0\1\0\1\20\0\0\nclass\vreturn\rfunction\vmethod\b^if\v^while\16jsx_element\t^for\f^object\v^table\nblock\14arguments\17if_statement\16else_clause\16jsx_element\29jsx_self_closing_element\18try_statement\17catch_clause\21import_statement&indent_blankline_context_patterns\1\25\0\0\thelp\rstartify\14dashboard\nalpha\vpacker\17NeogitStatus\21NeogitCommitView\16NeogitPopup\18NeogitLogView\24NeogitCommitMessage\bman\18sagasignature\14sagahover\18lspsagafinder\22LspSagaCodeAction\20TelescopePrompt\rNvimTree\fTrouble\18DiffviewFiles\24DiffviewFileHistory\fOutline\flspinfo\rfugitive\tnorg&indent_blankline_filetype_exclude\1\2\0\0\rterminal%indent_blankline_buftype_exclude)indent_blankline_max_indent_increase*indent_blankline_show_current_context4indent_blankline_show_trailing_blankline_indent$indent_blankline_use_treesitter\b‚†Ä*indent_blankline_space_char_blankline\b‚ñè\26indent_blankline_char\6g\bvim\0", "setup", "indent-blankline.nvim")
time([[Setup for indent-blankline.nvim]], false)
time([[packadd for indent-blankline.nvim]], true)
vim.cmd [[packadd indent-blankline.nvim]]
time([[packadd for indent-blankline.nvim]], false)
-- Setup for: vim-closetag
time([[Setup for vim-closetag]], true)
try_loadstring("\27LJ\2\nó\1\0\0\2\0\6\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\"html,xhtml,phtml,xml,markdown\23closetag_filetypes&*.html,*.xhtml,*.phtml,*.xml,*.md\23closetag_filenames\6g\bvim\0", "setup", "vim-closetag")
time([[Setup for vim-closetag]], false)
time([[packadd for vim-closetag]], true)
vim.cmd [[packadd vim-closetag]]
time([[packadd for vim-closetag]], false)
-- Setup for: emmet-vim
time([[Setup for emmet-vim]], true)
try_loadstring("\27LJ\2\n=\0\0\2\0\4\0\0056\0\0\0009\0\1\0'\1\3\0=\1\2\0K\0\1\0\n<C-Z>\26user_emmet_leader_key\6g\bvim\0", "setup", "emmet-vim")
time([[Setup for emmet-vim]], false)
time([[packadd for emmet-vim]], true)
vim.cmd [[packadd emmet-vim]]
time([[packadd for emmet-vim]], false)
-- Setup for: firenvim
time([[Setup for firenvim]], true)
try_loadstring("\27LJ\2\nh\0\0\b\0\4\0\0165\0\0\0006\1\1\0\18\3\0\0B\1\2\4H\4\aÄ6\6\2\0009\6\3\0068\6\4\6\4\6\5\0X\6\2Ä+\6\2\0L\6\2\0F\4\3\3R\4˜\127+\1\1\0L\1\2\0\6o\bvim\npairs\1\0\2\fcolumns\3P\nlines\3\24—\2\0\0\5\4\17\0017-\0\0\0B\0\1\2\14\0\0\0X\1\tÄ6\0\0\0009\0\1\0B\0\1\2-\1\1\0!\0\1\0\25\0\0\0-\1\2\0\3\1\0\0X\0)Ä-\0\3\0\18\2\0\0009\0\2\0B\0\2\1-\0\3\0\18\2\0\0009\0\3\0B\0\2\0016\0\4\0009\0\5\0006\1\a\0009\1\b\0016\3\4\0009\3\t\0039\3\6\3)\4\f\0B\1\3\2=\1\6\0006\0\4\0009\0\n\0'\2\v\0B\0\2\0016\0\f\0009\0\r\0009\0\14\0\15\0\0\0X\1\6Ä6\0\4\0009\0\5\0006\1\f\0009\1\r\0019\1\14\1=\1\14\0006\0\4\0009\0\n\0'\2\15\0006\3\f\0009\3\r\0039\3\16\3&\2\3\2B\0\2\1K\0\1\0\0\0\2¿\0¿\1¿\tname\17colorscheme \abg\16colorscheme\vConfig\rhi clear\bcmd\6o\bmax\tmath\nlines\bopt\bvim\nclose\tstop\vhrtime\auvÄâz~\1\0\v\1\a\0\18)\0à\0196\1\0\0009\1\1\1B\1\1\0026\2\0\0009\2\2\2B\2\1\2\18\5\1\0009\3\3\1)\6d\0)\ad\0006\b\4\0009\b\5\b3\n\6\0B\b\2\0A\3\3\0012\0\0ÄK\0\1\0\0¿\0\18schedule_wrap\bvim\nstart\vhrtime\14new_timer\auvä\3\1\0\b\0\22\0\"6\0\0\0009\0\1\0005\1\4\0005\2\3\0=\2\5\0015\2\a\0005\3\6\0=\3\b\2=\2\t\1=\1\2\0003\0\n\0006\1\0\0009\1\1\0019\1\v\1\15\0\1\0X\2\16Ä6\1\0\0009\1\f\1'\2\14\0=\2\r\0016\1\15\0009\1\16\0019\1\17\0019\1\18\1'\3\2\0004\4\0\0004\5\3\0005\6\19\0003\a\20\0=\a\21\6>\6\1\5B\1\4\0012\0\0ÄK\0\1\0\rcallback\0\1\2\1\0\fUIEnter\tonce\2\18declare_group\aau\vcommon\vConfig\17monospace:h9\fguifont\bopt\24started_by_firenvim\0\18localSettings\a.*\1\0\0\1\0\5\fcmdline\vneovim\fcontent\ttext\rpriority\3\0\rselector\rtextarea\rtakeover\nnever\19globalSettings\1\0\0\1\0\1\balt\ball\20firenvim_config\6g\bvim\0", "setup", "firenvim")
time([[Setup for firenvim]], false)
time([[packadd for firenvim]], true)
vim.cmd [[packadd firenvim]]
time([[packadd for firenvim]], false)
-- Setup for: FixCursorHold.nvim
time([[Setup for FixCursorHold.nvim]], true)
try_loadstring("\27LJ\2\n7\0\0\2\0\3\0\0056\0\0\0009\0\1\0)\1˙\0=\1\2\0K\0\1\0\26cursorhold_updatetime\6g\bvim\0", "setup", "FixCursorHold.nvim")
time([[Setup for FixCursorHold.nvim]], false)
time([[packadd for FixCursorHold.nvim]], true)
vim.cmd [[packadd FixCursorHold.nvim]]
time([[packadd for FixCursorHold.nvim]], false)
-- Setup for: markdown-preview.nvim
time([[Setup for markdown-preview.nvim]], true)
try_loadstring("\27LJ\2\n⁄\4\0\0\4\0\a\0\v6\0\0\0009\0\1\0009\0\2\0'\2\3\0+\3\1\0B\0\3\0016\0\0\0009\0\4\0'\1\6\0=\1\5\0K\0\1\0\24MkdpOpenInNewWindow\21mkdp_browserfunc\6gÒ\3          function! MkdpOpenInNewWindow(url)\n            if executable(\"qutebrowser\")\n              call jobstart([ \"qutebrowser\", \"--target\", \"window\", a:url ])\n            elseif executable(\"chromium\")\n              call jobstart([ \"chromium\", \"--app=\" . a:url ])\n            elseif executable(\"firefox\")\n              call jobstart([ \"firefox\", \"--new-window\", a:url ])\n            else\n              echoerr '[MKDP] No suitable browser!'\n            endif\n          endfunction\n          \14nvim_exec\bapi\bvim\0", "setup", "markdown-preview.nvim")
time([[Setup for markdown-preview.nvim]], false)
-- Setup for: nerdcommenter
time([[Setup for nerdcommenter]], true)
try_loadstring("\27LJ\2\nW\0\0\2\0\5\0\t6\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0'\1\4\0=\1\3\0K\0\1\0\tleft\21NERDDefaultAlign\20NERDSpaceDelims\6g\bvim\0", "setup", "nerdcommenter")
time([[Setup for nerdcommenter]], false)
time([[packadd for nerdcommenter]], true)
vim.cmd [[packadd nerdcommenter]]
time([[packadd for nerdcommenter]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\nø\1\0\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0005\4\a\0=\4\b\3=\3\t\2B\0\2\1K\0\1\0\14highlight\fdisable\1\4\0\0\bvim\thelp\6c\1\0\1\venable\2\19ignore_install\1\2\0\0\vphpdoc\1\0\1\21ensure_installed\ball\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-bqf
time([[Config for nvim-bqf]], true)
try_loadstring("\27LJ\2\n∆\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\fpreview\1\0\0\17border_chars\1\n\0\0\b‚îÇ\b‚îÇ\b‚îÄ\b‚îÄ\b‚îå\b‚îê\b‚îî\b‚îò\b‚ñà\1\0\5\17delay_syntax\0032\17auto_preview\1\16win_vheight\3\15\twrap\1\15win_height\3\15\nsetup\bbqf\frequire\0", "config", "nvim-bqf")
time([[Config for nvim-bqf]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\nW\0\4\n\1\4\0\14\14\0\3\0X\4\1Ä4\3\0\0-\4\0\0=\4\0\0036\4\1\0009\4\2\0049\4\3\4\18\6\0\0\18\a\1\0\18\b\2\0\18\t\3\0B\4\5\1K\0\1\0\0¿\bset\vkeymap\bvim\vbufferD\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\0\0\rnorm! zz\bcmd\bvim\14next_hunkg\1\0\3\1\a\0\0156\0\0\0009\0\1\0009\0\2\0\15\0\0\0X\1\2Ä'\0\3\0002\0\aÄ6\0\0\0009\0\4\0003\2\5\0B\0\2\1'\0\6\0002\0\0ÄL\0\2\0L\0\2\0\1¿\r<Ignore>\0\rschedule\a]c\tdiff\awo\bvimD\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\0\0\rnorm! zz\bcmd\bvim\14prev_hunkg\1\0\3\1\a\0\0156\0\0\0009\0\1\0009\0\2\0\15\0\0\0X\1\2Ä'\0\3\0002\0\aÄ6\0\0\0009\0\4\0003\2\5\0B\0\2\1'\0\6\0002\0\0ÄL\0\2\0L\0\2\0\1¿\r<Ignore>\0\rschedule\a[c\tdiff\awo\bvimn\0\0\6\1\6\1\17-\0\0\0009\0\0\0004\2\3\0006\3\1\0009\3\2\0039\3\3\3'\5\4\0B\3\2\2>\3\1\0026\3\1\0009\3\2\0039\3\3\3'\5\5\0B\3\2\0?\3\0\0B\0\2\1K\0\1\0\1¿\6v\6.\tline\afn\bvim\15stage_hunk\5ÄÄ¿ô\4n\0\0\6\1\6\1\17-\0\0\0009\0\0\0004\2\3\0006\3\1\0009\3\2\0039\3\3\3'\5\4\0B\3\2\2>\3\1\0026\3\1\0009\3\2\0039\3\3\3'\5\5\0B\3\2\0?\3\0\0B\0\2\1K\0\1\0\1¿\6v\6.\tline\afn\bvim\15reset_hunk\5ÄÄ¿ô\0041\0\0\3\1\2\0\5-\0\0\0009\0\0\0005\2\1\0B\0\2\1K\0\1\0\1¿\1\0\1\tfull\2\15blame_lineœ\4\1\1\t\0!\0I6\1\0\0009\1\1\0019\1\2\0013\2\3\0\18\3\2\0'\5\4\0'\6\5\0003\a\6\0005\b\a\0B\3\5\1\18\3\2\0'\5\4\0'\6\b\0003\a\t\0005\b\n\0B\3\5\1\18\3\2\0'\5\4\0'\6\v\0009\a\f\1B\3\4\1\18\3\2\0'\5\4\0'\6\r\0009\a\14\1B\3\4\1\18\3\2\0'\5\15\0'\6\v\0003\a\16\0B\3\4\1\18\3\2\0'\5\15\0'\6\r\0003\a\17\0B\3\4\1\18\3\2\0'\5\4\0'\6\18\0009\a\19\1B\3\4\1\18\3\2\0'\5\4\0'\6\20\0009\a\21\1B\3\4\1\18\3\2\0'\5\4\0'\6\22\0009\a\23\1B\3\4\1\18\3\2\0'\5\4\0'\6\24\0003\a\25\0B\3\4\1\18\3\2\0'\5\4\0'\6\26\0009\a\27\1B\3\4\1\18\3\2\0'\5\4\0'\6\28\0009\a\29\1B\3\4\1\18\3\2\0005\5\30\0'\6\31\0'\a \0B\3\4\0012\0\0ÄK\0\1\0#:<C-U>Gitsigns select_hunk<CR>\aih\1\3\0\0\6o\6x\19toggle_deleted\15<leader>td\30toggle_current_line_blame\15<leader>tb\0\15<leader>hb\17preview_hunk\14<leader>d\20undo_stage_hunk\15<leader>hu\17stage_buffer\15<leader>hS\0\0\6v\15reset_hunk\15<leader>hr\15stage_hunk\15<leader>hs\1\0\1\texpr\2\0\a[c\1\0\1\texpr\2\0\a]c\6n\0\rgitsigns\vloaded\fpackageß\a\1\0\6\0#\0,6\0\0\0009\0\1\0009\0\2\0009\0\3\0006\1\4\0'\3\5\0B\1\2\0029\1\6\0015\3\18\0005\4\b\0005\5\a\0=\5\t\0045\5\n\0=\5\v\0045\5\f\0=\5\r\0045\5\14\0=\5\15\0045\5\16\0=\5\17\4=\4\19\0035\4\20\0=\4\21\0035\4\22\0=\4\23\0033\4\24\0=\4\25\3B\1\2\1\18\1\0\0'\3\26\0'\4\27\0005\5\28\0B\1\4\1\18\1\0\0'\3\29\0'\4\30\0005\5\31\0B\1\4\1\18\1\0\0'\3 \0'\4!\0005\5\"\0B\1\4\1K\0\1\0\1\0\1\fdefault\2\16diffRemoved\19GitSignsDelete\1\0\1\fdefault\2\16diffChanged\19GitSignsChange\1\0\1\fdefault\2\14diffAdded\16GitSignsAdd\14on_attach\0\14diff_opts\1\0\3\rinternal\2\14algorithm\14histogram\21indent_heuristic\2\17watch_gitdir\1\0\2\rinterval\3Ë\a\17follow_files\2\nsigns\1\0\4\vlinehl\1\20update_debounce\3d\18sign_priority\3\6\nnumhl\1\14topdelete\1\0\4\vlinehl\21GitSignsDeleteLn\ahl\19GitSignsDelete\ttext\b‚Äæ\nnumhl\21GitSignsDeleteNr\17changedelete\1\0\4\vlinehl\21GitSignsChangeLn\ahl\19GitSignsChange\ttext\b‚ñç\nnumhl\21GitSignsChangeNr\vdelete\1\0\4\vlinehl\21GitSignsDeleteLn\ahl\19GitSignsDelete\ttext\b‚ñç\nnumhl\21GitSignsDeleteNr\vchange\1\0\4\vlinehl\21GitSignsChangeLn\ahl\19GitSignsChange\ttext\b‚ñç\nnumhl\21GitSignsChangeNr\badd\1\0\0\1\0\4\vlinehl\18GitSignsAddLn\ahl\16GitSignsAdd\ttext\b‚ñç\nnumhl\18GitSignsAddNr\nsetup\rgitsigns\frequire\fhi_link\ahl\vcommon\vConfig\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: lsp_signature.nvim
time([[Config for lsp_signature.nvim]], true)
try_loadstring("\27LJ\2\nü\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\17handler_opts\1\0\1\vborder\vsingle\1\0\4\16hint_prefix\t‚óè \14max_width\3P\15max_height\3\f\16hint_enable\1\nsetup\18lsp_signature\frequire\0", "config", "lsp_signature.nvim")
time([[Config for lsp_signature.nvim]], false)
-- Config for: spellsitter.nvim
time([[Config for spellsitter.nvim]], true)
try_loadstring("\27LJ\2\nI\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\fenabled\2\nsetup\16spellsitter\frequire\0", "config", "spellsitter.nvim")
time([[Config for spellsitter.nvim]], false)
-- Config for: feline.nvim
time([[Config for feline.nvim]], true)
try_loadstring("\27LJ\2\nU\0\0\2\0\5\0\v6\0\0\0009\0\1\0009\0\2\0009\0\3\0B\0\1\0016\0\0\0009\0\1\0009\0\2\0009\0\4\0B\0\1\1K\0\1\0\nsetup\vupdate\vfeline\vplugin\vConfig\0", "config", "feline.nvim")
time([[Config for feline.nvim]], false)
-- Config for: neogit
time([[Config for neogit]], true)
try_loadstring("\27LJ\2\nÏ\5\0\0\b\0!\0/4\0\0\0006\1\0\0'\3\1\0B\1\2\0029\1\2\0015\3\3\0005\4\4\0=\4\5\0035\4\a\0005\5\6\0=\5\b\0045\5\t\0=\5\n\0045\5\v\0=\5\f\4=\4\r\0035\4\14\0=\4\15\0035\4\17\0005\5\16\0=\5\18\4=\4\19\0035\4\21\0005\5\20\0=\5\5\4=\4\22\3B\1\2\0016\1\23\0009\1\24\0019\1\25\0019\1\26\1'\3\27\0004\4\0\0004\5\4\0005\6\28\0>\6\1\0055\6\30\0005\a\29\0>\a\1\6>\6\2\0055\6\31\0>\6\3\5B\1\4\0016\1\23\0009\1 \1=\0\1\1K\0\1\0\vplugin\1\2\2\0\rBufLeave\fpattern\21NeogitCommitView\fcommand\"setl eventignore-=CursorMoved\1\0\2\fpattern\21NeogitCommitView\fcommand\"setl eventignore+=CursorMoved\1\3\0\0\rBufEnter\rFileType\1\2\2\0\rFileType\fpattern\fNeogit*\fcommand\16setl nolist\18neogit_config\18declare_group\aau\vcommon\vConfig\rmappings\1\0\0\1\0\1\6B\16BranchPopup\rsections\vrecent\1\0\0\1\0\1\vfolded\1\17integrations\1\0\1\rdiffview\2\nsigns\thunk\1\3\0\0\5\5\titem\1\3\0\0\bÔÉö\bÔÉó\fsection\1\0\0\1\3\0\0\bÔë†\bÔëº\vstatus\1\0\1\24recent_commit_count\3\n\1\0\4\17disable_hint\2!disable_context_highlighting\1\"disable_builtin_notifications\2\18disable_signs\1\nsetup\vneogit\frequire\0", "config", "neogit")
time([[Config for neogit]], false)
-- Config for: nvim-notify
time([[Config for nvim-notify]], true)
try_loadstring("\27LJ\2\nP\0\0\4\0\4\0\f6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\0016\0\3\0006\1\0\0'\3\1\0B\1\2\2=\1\1\0K\0\1\0\bvim\nsetup\vnotify\frequire\0", "config", "nvim-notify")
time([[Config for nvim-notify]], false)
-- Config for: neoscroll.nvim
time([[Config for neoscroll.nvim]], true)
try_loadstring("\27LJ\2\nè\1\2\1\5\1\a\0\0196\1\0\0009\1\1\0019\1\2\0016\2\0\0009\2\3\2'\3\4\0=\3\2\2-\2\0\0008\2\0\2G\4\1\0A\2\0\0016\2\0\0009\2\3\2=\1\2\0026\2\0\0009\2\5\2'\4\6\0B\2\2\1K\0\1\0\0¿ do <nomodeline> WinScrolled\bcmd\ball\bopt\16eventignore\6o\bvimb\0\0\a\2\6\0\15-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0036\5\4\0009\5\5\0059\5\1\5)\6\16\0B\3\3\2\20\3\3\0+\4\2\0-\5\1\0B\0\5\1K\0\1\0\1¿\2¿\awo\bvim\bmax\tmath\vscroll\brun^\0\0\a\2\6\0\14-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0036\5\4\0009\5\5\0059\5\1\5)\6\16\0B\3\3\2+\4\2\0-\5\1\0B\0\5\1K\0\1\0\1¿\2¿\awo\bvim\bmax\tmath\vscroll\brunk\0\0\6\2\5\1\14-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0039\3\4\3)\5\0\0B\3\2\2\20\3\3\0+\4\2\0-\5\1\0\24\5\0\5B\0\5\1K\0\1\0\1¿\2¿\24nvim_win_get_height\bapi\bvim\vscroll\brun\4g\0\0\6\2\5\1\r-\0\0\0009\0\0\0'\2\1\0006\3\2\0009\3\3\0039\3\4\3)\5\0\0B\3\2\2+\4\2\0-\5\1\0\24\5\0\5B\0\5\1K\0\1\0\1¿\2¿\24nvim_win_get_height\bapi\bvim\vscroll\brun\4*\0\0\4\2\2\0\6-\0\0\0009\0\0\0'\2\1\0-\3\1\0B\0\3\1K\0\1\0\1¿\2¿\azt\brun*\0\0\4\2\2\0\6-\0\0\0009\0\0\0'\2\1\0-\3\1\0B\0\3\1K\0\1\0\1¿\2¿\azz\brun*\0\0\4\2\2\0\6-\0\0\0009\0\0\0'\2\1\0-\3\1\0B\0\3\1K\0\1\0\1¿\2¿\azb\brunä\4\1\0\b\0\28\0E6\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0014\2\0\0=\2\1\0016\1\2\0009\1\3\0019\1\1\0019\2\4\0005\4\6\0005\5\5\0=\5\a\4B\2\2\0013\2\t\0=\2\b\1)\2¥\0006\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\14\0003\a\15\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\16\0003\a\17\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\18\0003\a\19\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\20\0003\a\21\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\22\0003\a\23\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\24\0003\a\25\0B\3\4\0016\3\n\0009\3\v\0039\3\f\3'\5\r\0'\6\26\0003\a\27\0B\3\4\0012\0\0ÄK\0\1\0\0\azb\0\azz\0\azt\0\n<C-f>\0\n<C-b>\0\n<C-d>\0\n<C-u>\6n\bset\vkeymap\bvim\0\brun\rmappings\1\0\5\rstop_eof\2\16hide_cursor\2\20easing_function\14quadratic\22respect_scrolloff\1\25cursor_scrolls_alone\2\1\b\0\0\n<C-u>\n<C-d>\n<C-b>\n<C-f>\azt\azz\azb\nsetup\vplugin\vConfig\14neoscroll\frequire\0", "config", "neoscroll.nvim")
time([[Config for neoscroll.nvim]], false)
-- Config for: indent-o-matic
time([[Config for indent-o-matic]], true)
try_loadstring("\27LJ\2\nt\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\1K\0\1\0\20standard_widths\1\5\0\0\3\2\3\3\3\4\3\b\1\0\1\14max_lines\3Ä\16\nsetup\19indent-o-matic\frequire\0", "config", "indent-o-matic")
time([[Config for indent-o-matic]], false)
-- Config for: winshift.nvim
time([[Config for winshift.nvim]], true)
try_loadstring("\27LJ\2\n∏\3\0\0\5\0\n\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\0025\3\b\0=\3\t\2B\0\2\1K\0\1\0\23moving_win_options\1\0\4\16colorcolumn\5\17cursorcolumn\1\twrap\1\15cursorline\1\fkeymaps\18win_move_mode\1\0\16\6j\tdown\r<S-left>\rfar_left\6k\aup\r<S-down>\rfar_down\6l\nright\v<down>\tdown\v<left>\tleft\f<right>\nright\6L\14far_right\6J\rfar_down\6H\rfar_left\14<S-right>\14far_right\t<up>\aup\v<S-up>\vfar_up\6h\tleft\6K\vfar_up\1\0\1\21disable_defaults\1\1\0\2\21focused_hl_group\21LspReferenceRead\25highlight_moving_win\2\nsetup\rwinshift\frequire\0", "config", "winshift.nvim")
time([[Config for winshift.nvim]], false)
-- Config for: nvim-autopairs
time([[Config for nvim-autopairs]], true)
try_loadstring("\27LJ\2\nã\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\29html_break_line_filetype\1\6\0\0\thtml\bvue\20typescriptreact\vsvelte\20javascriptreact\21disable_filetype\1\0\3\30enable_check_bracket_line\1\rcheck_ts\2\22ignored_next_char\19[%w%%%'%[%\"%.]\1\2\0\0\20TelescopePrompt\nsetup\19nvim-autopairs\frequire\0", "config", "nvim-autopairs")
time([[Config for nvim-autopairs]], false)
-- Config for: nvim-pqf.git
time([[Config for nvim-pqf.git]], true)
try_loadstring("\27LJ\2\nq\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\nsigns\1\0\0\1\0\4\fwarning\bÔÅ±\nerror\bÔÅó\tinfo\bÔÅö\thint\bÔÅ™\nsetup\bpqf\frequire\0", "config", "nvim-pqf.git")
time([[Config for nvim-pqf.git]], false)
-- Config for: alpha-nvim
time([[Config for alpha-nvim]], true)
try_loadstring("\27LJ\2\nÓ\1\0\0\15\2\t\1'-\0\0\0009\0\0\0)\2\0\0B\0\2\0025\1\1\0006\2\2\0009\2\3\0029\2\4\2+\3\0\0006\4\5\0\18\6\1\0B\4\2\4X\a\22Ä-\t\1\0\18\n\b\0'\v\6\0\18\f\2\0&\n\f\n8\t\n\t\14\0\t\0X\n\2Ä-\t\1\0008\t\b\t6\n\2\0009\n\a\n\18\f\t\0'\r\b\0004\14\0\0B\n\4\2\18\3\n\0\21\n\3\0\22\n\0\n\3\n\0\0X\n\1ÄL\3\2\0E\a\3\3R\aË\1274\4\0\0L\4\2\0\2¿\1¿\6\n\nsplit\6_\vipairs\15background\6o\bvim\1\3\0\0\vmajora\tnvim\24nvim_win_get_height(<\0\0\5\2\2\0\a-\0\0\0009\0\0\0-\2\1\0'\3\1\0+\4\1\0B\0\4\1K\0\1\0\1\0\3¿\vnormal\18nvim_feedkeysÆ\2\1\3\n\2\r\0\24-\3\0\0009\3\0\3\18\5\2\0B\3\2\0025\4\1\0=\0\2\0043\5\3\0=\5\4\0045\5\5\0'\6\6\0\18\b\6\0009\6\a\6\18\t\2\0B\6\3\2=\6\b\5=\5\t\0045\5\n\0>\2\2\5>\1\3\0055\6\v\0>\6\4\5=\5\f\0042\0\0ÄL\4\2\0\6¿\2¿\vkeymap\1\0\2\vsilent\2\vnowait\2\1\2\0\0\6n\topts\rshortcut\vformat\t %s \1\0\6\vcursor\3\0\ahl\20DashboardCenter\19align_shortcut\nright\16hl_shortcut\22DashboardShortCut\nwidth\3(\rposition\vcenter\ron_press\0\bval\1\0\1\ttype\vbutton\6t⁄\2\0\1\r\2\17\0+6\1\0\0009\1\1\1+\2\1\0=\2\2\0016\1\0\0009\1\1\0016\2\4\0009\2\5\0025\4\6\0'\5\a\0B\2\3\2=\2\3\0016\1\b\0-\3\0\0009\3\t\3B\1\2\4X\4\23Ä-\6\1\0009\6\n\0069\b\v\5B\6\2\0026\a\0\0009\a\f\a'\t\r\0:\n\4\6\14\0\n\0X\v\1Ä4\n\0\0005\v\14\0=\0\15\vB\a\4\2>\a\4\0066\a\0\0009\a\v\a9\a\16\a:\t\1\6:\n\2\6:\v\3\6:\f\4\6B\a\5\1E\4\3\3R\4Á\127K\0\1\0\a¿\6¿\bset\vbuffer\1\0\0\nforce\15tbl_extend\vkeymap\14vec_slice\fbuttons\vipairs\6,\1\3\0\0\27Normal:DashboardNormal%EndOfBuffer:DashboardEndOfBuffer\vconcat\ntable\nwinhl\tlist\14opt_local\bvim¨\3\0\0\a\1\21\0(-\0\0\0009\0\0\0'\2\1\0'\3\2\0005\4\3\0B\0\4\1-\0\0\0009\0\4\0'\2\5\0005\3\6\0B\0\3\1-\0\0\0009\0\0\0'\2\a\0'\3\b\0005\4\t\0B\0\4\1-\0\0\0009\0\0\0'\2\n\0'\3\v\0005\4\f\0B\0\4\1-\0\0\0009\0\4\0'\2\r\0005\3\16\0-\4\0\0009\4\14\4'\6\15\0B\4\2\2=\4\17\3B\0\3\1-\0\0\0009\0\0\0'\2\18\0'\3\19\0005\4\20\0B\0\4\1K\0\1\0\4¿\1\0\1\fdefault\2\vNumber\20DashboardFooter\afg\1\0\2\fdefault\2\bgui\17bold,reverse\vString\vget_fg\22DashboardShortCut\1\0\1\fdefault\2\fKeyword\20DashboardCenter\1\0\1\fdefault\2\tType\20DashboardHeader\1\0\3\abg\abg\afg\abg\fdefault\2\25DashboardEndOfBuffer\ahi\1\0\1\fdefault\2\vNormal\20DashboardNormal\fhi_link)\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\3\0\20workspace_filesÜ\6\1\0\b\4%\1L6\0\0\0009\0\1\0006\2\0\0009\2\2\0029\2\3\2'\4\4\0+\5\2\0B\2\3\2'\3\5\0004\4\0\0B\0\4\2-\1\0\0005\2\a\0-\3\1\0B\3\1\2=\3\b\0025\3\t\0=\3\n\2=\2\6\1-\1\0\0005\2\f\0004\3\3\0'\4\r\0:\5\2\0&\4\5\4>\4\1\3=\3\b\0025\3\14\0=\3\n\2=\2\v\1-\1\0\0004\2\b\0-\3\2\0'\5\16\0'\6\17\0'\a\18\0B\3\4\2>\3\1\2-\3\2\0'\5\19\0003\6\20\0'\a\21\0B\3\4\2>\3\2\2-\3\2\0'\5\22\0'\6\23\0'\a\24\0B\3\4\2>\3\3\2-\3\2\0'\5\25\0'\6\26\0'\a\27\0B\3\4\2>\3\4\2-\3\2\0'\5\28\0'\6\29\0'\a\30\0B\3\4\2>\3\5\2-\3\2\0'\5\31\0'\6 \0'\a!\0B\3\4\2>\3\6\2-\3\2\0'\5\"\0'\6#\0'\a$\0B\3\4\0?\3\0\0=\2\15\1K\0\1\0\a¿\b¿\t¿\5¿\6q\22<Cmd>wincmd q<CR>\14Ôôô  Quit\afm\29<Cmd>Telescope marks<CR>\22Ôë°  Jump to Mark\afw!<Cmd>Telescope live_grep<CR>\19ÔûÉ  Find Word\arf <Cmd>Telescope oldfiles<CR>\29ÔÉÖ  Recently Used Files\ags\"<Cmd>Telescope git_status<CR>\20Ôû°  Git Status\aff\0\19Ôë´  Find File\6n\18<Cmd>enew<CR>\18ÔÖõ  New File\fbuttons\1\0\2\ahl\20DashboardFooter\rposition\vcenter\tÔîó \1\0\1\ttype\ttext\vfooter\topts\1\0\2\ahl\20DashboardHeader\rposition\vcenter\bval\1\0\1\ttype\ttext\vheader\6\n\fversion\14nvim_exec\bapi\nsplit\bvim\15ÄÄ¿ô\4\29\0\1\4\1\1\0\4-\1\0\0009\3\0\0B\1\2\1K\0\1\0\n¿\bbuf\21\0\1\3\1\0\0\3-\1\0\0B\1\1\1K\0\1\0\v¿ÿ\4\1\0\20\0%\0G6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\3\0009\2\4\0026\3\5\0009\3\6\0039\3\a\0036\4\5\0009\4\6\0049\4\b\0046\5\5\0009\5\t\0056\6\5\0009\6\6\0069\6\n\0065\a\v\0004\b\0\0=\b\f\a4\b\0\0=\b\r\a4\b\0\0=\b\14\a3\b\15\0003\t\16\0003\n\17\0003\v\18\0003\f\19\0009\r\20\3'\15\21\0004\16\0\0004\17\3\0005\18\22\0003\19\23\0=\19\24\18>\18\1\0175\18\25\0003\19\26\0=\19\24\18>\18\2\17B\r\4\1\18\r\f\0B\r\1\1\18\r\v\0B\r\1\0019\r\27\0005\15\29\0005\16\28\0=\16\30\0154\16\6\0005\17\31\0>\17\1\0169\17\f\a>\17\2\0165\17 \0>\17\3\0165\17!\0005\18\"\0=\18\30\0179\18\r\a=\18#\17>\17\4\0169\17\14\a>\17\5\16=\16$\15B\r\2\0012\0\0ÄK\0\1\0\vlayout\bval\1\0\1\fspacing\3\1\1\0\1\ttype\ngroup\1\0\2\ttype\fpadding\bval\3\2\1\0\2\ttype\fpadding\bval\3\1\topts\1\0\0\1\0\1\vmargin\3\5\nsetup\0\1\2\1\0\16ColorScheme\fpattern\6*\rcallback\0\1\2\1\0\tUser\fpattern\15AlphaReady\17alpha_config\18declare_group\0\0\0\0\0\vfooter\fbuttons\vheader\1\0\0\nutils\blib\ahl\aau\vcommon\vConfig\bapi\bvim\31user.plugins.alpha.banners\nalpha\frequire\0", "config", "alpha-nvim")
time([[Config for alpha-nvim]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
try_loadstring("\27LJ\2\n≥\2\0\0\4\0\v\0\0146\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\0025\3\n\0B\0\3\1K\0\1\0\1\0\t\vrgb_fn\1\vhsl_fn\1\vcss_fn\1\tmode\15background\bRGB\2\vRRGGBB\2\rRRGGBBAA\2\bcss\1\nnames\1\tsass\1\0\5\vrgb_fn\2\vhsl_fn\2\vcss_fn\2\bcss\2\nnames\2\tscss\1\0\5\vrgb_fn\2\vhsl_fn\2\vcss_fn\2\bcss\2\nnames\2\bcss\1\0\5\vrgb_fn\2\vhsl_fn\2\vcss_fn\2\bcss\2\nnames\2\1\3\0\0\6*\t!git\nsetup\14colorizer\frequire\0", "config", "nvim-colorizer.lua")
time([[Config for nvim-colorizer.lua]], false)
-- Config for: vim-illuminate
time([[Config for vim-illuminate]], true)
try_loadstring("\27LJ\2\në\4\0\0\4\0\14\0\0216\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0024\3\0\0=\3\v\0024\3\0\0=\3\f\0024\3\0\0=\3\r\2B\0\2\1K\0\1\0%providers_regex_syntax_allowlist$providers_regex_syntax_denylist\20modes_allowlist\19modes_denylist\1\21\0\0\ant\6v\avs\6V\aVs\6\22\a\22s\6s\6S\6\19\6i\aic\aix\6R\aRc\aRx\aRv\bRvc\bRvx\6t\24filetypes_allowlist\23filetypes_denylist\1\16\0\0\fdirvish\rfugitive\aqf\14dashboard\nalpha\vpacker\17NeogitStatus\21NeogitCommitView\20TelescopePrompt\rNvimTree\fTrouble\18DiffviewFiles\24DiffviewFileHistory\fOutline\blir\14providers\1\0\2\17under_cursor\2\ndelay\3˙\1\1\4\0\0\blsp\15treesitter\nregex\14configure\15illuminate\frequire\0", "config", "vim-illuminate")
time([[Config for vim-illuminate]], false)
-- Config for: nvim-ts-rainbow
time([[Config for nvim-ts-rainbow]], true)
try_loadstring("\27LJ\2\n”\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0005\4\4\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\frainbow\1\0\0\vcolors\1\b\0\0\f#bf616a\f#d08770\f#ebcb8b\f#a3be8c\f#88c0d0\f#5e81ac\f#b48ead\1\0\3\18extended_mode\2\venable\2\19max_file_lines\3∏\23\nsetup\28nvim-treesitter.configs\frequire\0", "config", "nvim-ts-rainbow")
time([[Config for nvim-ts-rainbow]], false)
-- Config for: diffview.nvim
time([[Config for diffview.nvim]], true)
try_loadstring("\27LJ\2\n‰\2\0\0\6\2\r\0'-\0\0\0009\0\0\0-\2\1\0'\3\1\0B\0\3\1-\0\0\0009\0\0\0-\2\1\0'\3\2\0B\0\3\1-\0\1\0009\0\3\0009\0\4\0-\1\0\0009\1\6\1-\3\1\0009\3\3\0039\3\4\0039\3\5\0035\4\b\0005\5\a\0=\5\t\4B\1\3\2=\1\5\0-\0\1\0009\0\3\0009\0\4\0-\1\0\0009\1\6\1-\3\1\0009\3\3\0039\3\4\0039\3\n\0035\4\f\0005\5\v\0=\5\t\4B\1\3\2=\1\n\0K\0\1\0\0\0\0¿\1\0\0\1\3\0\0\23DiffChange:DiffAdd\25DiffText:DiffAddText\6b\nwinhl\1\0\0\1\3\0\0\31DiffChange:DiffAddAsDelete\28DiffText:DiffDeleteText\21tbl_union_extend\6a\ndiff2\fwinopts\20winopts.diff2.b\20winopts.diff2.a\15tbl_ensureM\1\1\a\1\4\0\v3\1\0\0009\2\1\0\18\4\2\0009\2\2\2'\5\3\0\18\6\1\0B\2\4\1\18\2\1\0B\2\1\0012\0\0ÄK\0\1\0\1¿\16post_layout\aon\femitter\0ì\1\0\1\5\1\6\0\18-\1\0\0009\1\0\1)\3\0\0)\4\1\0B\1\3\0016\1\1\0009\1\2\0019\1\3\1\18\3\0\0B\1\2\2)\2ƒ\t\3\2\1\0X\1\4Ä6\1\1\0009\1\4\1'\3\5\0B\1\2\1K\0\1\0\1¿\27IndentBlanklineDisable\bcmd\24nvim_buf_line_count\bapi\bvim\15set_cursorˇ\b\1\0\t\0;\0S6\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0019\1\4\0014\2\0\0006\3\0\0'\5\5\0B\3\2\0029\3\6\0035\5\a\0005\6\b\0=\6\t\0055\6\n\0=\6\v\0055\6\f\0=\6\r\0055\6\15\0005\a\14\0=\a\16\6=\6\17\0055\6\18\0005\a\19\0=\a\20\0065\a\21\0=\a\22\6=\6\23\0055\6\29\0005\a\25\0005\b\24\0=\b\26\a5\b\27\0=\b\28\a=\a\30\0065\a\31\0=\a\22\6=\6 \0055\6!\0004\a\0\0=\a\22\6=\6\"\0055\6#\0004\a\0\0=\a$\0064\a\0\0=\a%\6=\6&\0055\6(\0003\a'\0=\a)\0063\a*\0=\a+\6=\6,\0055\0062\0005\a.\0009\b-\0=\b/\a9\b0\0=\b1\a=\a\17\0065\a4\0009\b3\0=\b5\a9\b0\0=\b6\a9\b-\0=\b/\a=\a\23\0065\a7\0009\b3\0=\b5\a9\b-\0=\b/\a=\a \6=\0068\5B\3\2\0016\0039\0009\3\2\0039\3:\3=\2\5\0032\0\0ÄK\0\1\0\vplugin\a_G\fkeymaps\1\0\1\6?0<Cmd>h diffview-maps-file-history-panel<CR>\6s\t<cr>\1\0\1\6?(<Cmd>h diffview-maps-file-panel<CR>\16focus_entry\1\0\0\6-\23toggle_stage_entry\agf\1\0\0\19goto_file_edit\nhooks\18diff_buf_read\0\16view_opened\1\0\0\0\17default_args\24DiffviewFileHistory\17DiffviewOpen\1\0\0\21commit_log_panel\1\0\0\23file_history_panel\1\0\2\vheight\3\16\rposition\vbottom\16log_options\1\0\0\15multi_file\1\0\1\16diff_merges\17first-parent\16single_file\1\0\0\1\0\1\16diff_merges\rcombined\15file_panel\15win_config\1\0\2\nwidth\3#\rposition\tleft\17tree_options\1\0\2\20folder_statuses\16only_folded\17flatten_dirs\2\1\0\1\18listing_style\ttree\tview\15merge_tool\1\0\0\1\0\2\24disable_diagnostics\2\vlayout\16diff3_mixed\nsigns\1\0\2\14fold_open\bÔëº\16fold_closed\bÔë†\nicons\1\0\2\16folder_open\bÓóæ\18folder_closed\bÓóø\fgit_cmd\1\2\0\0\bgit\1\0\3\14use_icons\2\18diff_binaries\1\21enhanced_diff_hl\2\nsetup\rdiffview\nutils\vcommon\vConfig\21diffview.actions\frequire\0", "config", "diffview.nvim")
time([[Config for diffview.nvim]], false)
-- Config for: nvim-web-devicons
time([[Config for nvim-web-devicons]], true)
try_loadstring("\27LJ\2\nŒ\5\0\0\5\0\30\0!6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\28\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\0035\4\14\0=\4\15\0035\4\16\0=\4\17\0035\4\18\0=\4\19\0035\4\20\0=\4\21\0035\4\22\0=\4\23\0035\4\24\0=\4\25\0035\4\26\0=\4\27\3=\3\29\2B\0\2\1K\0\1\0\roverride\1\0\1\fdefault\2\npatch\1\0\3\ncolor\f#41535b\ticon\bÓú®\tname\nPatch\20lir_folder_icon\1\0\3\ncolor\f#7ebae4\ticon\bÔêì\tname\18LirFolderNode\rmakefile\1\0\3\ncolor\f#6d8086\ticon\bÓòï\tname\rMakefile\rMakefile\1\0\3\ncolor\f#6d8086\ticon\bÓòï\tname\rMakefile\brkt\1\0\3\ncolor\f#264B8B\ticon\bÔ¨¶\tname\vRacket\bscm\1\0\3\ncolor\f#264B8B\ticon\bÔ¨¶\tname\vScheme\tlisp\1\0\3\ncolor\f#264B8B\ticon\bÔ¨¶\tname\tLisp\ael\1\0\3\ncolor\f#5D439C\ticon\bÔ¨¶\tname\nElisp\atl\1\0\3\ncolor\f#51a0cf\ticon\bÓò†\tname\tTeal\6m\1\0\3\ncolor\f#599eff\ticon\bÓòû\tname\fCModule\acs\1\0\3\ncolor\f#0d5786\ticon\bÔ†ö\tname\aCs\bxml\1\0\0\1\0\3\ncolor\f#e37933\ticon\bÓòé\tname\bXml\nsetup\22nvim-web-devicons\frequire\0", "config", "nvim-web-devicons")
time([[Config for nvim-web-devicons]], false)
-- Conditional loads
time([[Conditional loading of neorg]], true)
  require("packer.load")({"neorg"}, {}, _G.packer_plugins)
time([[Conditional loading of neorg]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd lsp-trouble.nvim ]]

-- Config for: lsp-trouble.nvim
try_loadstring("\27LJ\2\ng\0\0\4\1\4\0\b-\0\0\0009\0\0\0005\2\2\0005\3\1\0=\3\3\2B\0\2\2:\0\1\0L\0\2\0\1¿\foptions\1\0\2\14no_hidden\2\ftabpage\3\0\1\0\1\rfiletype\fTrouble\14list_bufs+\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\fTrouble\bcmd\bvim;\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\28wincmd p | TroubleClose\bcmd\bvimŒ\4\1\0\t\0\19\0\0276\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0019\1\4\0016\2\0\0'\4\5\0B\2\2\0029\2\6\0025\4\a\0005\5\b\0=\5\t\0045\5\n\0=\5\v\4B\2\2\0016\2\2\0009\2\f\0029\3\14\0003\5\15\0003\6\16\0003\a\17\0005\b\18\0B\3\5\2=\3\r\0022\0\0ÄK\0\1\0\1\0\2\nfocus\2\20remember_height\2\0\0\0\23create_buf_toggler\23toggle_diagnostics\afn\nsigns\1\0\4\fwarning\bÔî©\nerror\bÔôô\16information\bÔëâ\thint\bÔ†µ\16action_keys\1\0\v\nclose\6q\fpreview\6p\16close_folds\azM\15open_folds\azR\vcancel\n<esc>\tnext\6j\rprevious\6k\frefresh\6R\tjump\t<cr>\16toggle_mode\6m\19toggle_preview\6P\1\0\n\vheight\3\n\17auto_preview\1\nicons\2\tmode\26workspace_diagnostics\14fold_open\bÔëº\17indent_lines\2\14auto_open\1\29use_lsp_diagnostic_signs\1\15auto_close\1\16fold_closed\bÔë†\nsetup\ftrouble\nutils\vcommon\vConfig\ruser.lib\frequire\0", "config", "lsp-trouble.nvim")

vim.cmd [[ packadd incline.nvim ]]

-- Config for: incline.nvim
try_loadstring("\27LJ\2\n“\5\0\1\14\4\31\1z6\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\0026\2\4\0\18\4\2\0009\2\5\2\18\5\1\0B\2\3\2\a\2\6\0X\3\2Ä'\3\a\0X\4\1Ä\18\3\2\0+\4\0\0\21\5\3\0-\6\0\0\22\6\0\6\1\6\5\0X\5\aÄ'\5\b\0\18\b\3\0009\6\t\3-\t\0\0\20\t\t\0B\6\3\2&\3\6\0056\5\0\0009\5\n\0059\6\3\0008\5\6\0059\5\v\5\a\5\f\0X\5\2Ä'\2\r\0X\5\6Ä6\5\4\0\18\a\5\0009\5\14\5\18\b\1\0B\5\3\2\18\4\5\0006\5\15\0006\a\0\0009\a\16\a9\b\3\0008\a\b\a9\a\17\aB\5\2\2\a\5\18\0X\5\fÄ6\5\0\0009\5\16\0059\6\3\0008\5\6\0055\6\19\0006\a\4\0\18\t\a\0009\a\15\a\18\n\1\0B\a\3\2=\a\20\6=\6\17\0056\5\0\0009\5\16\0059\6\3\0008\5\6\0059\5\17\5,\6\a\0009\b\20\5\a\b\21\0X\b\aÄ-\b\1\0009\b\22\b'\n\23\0B\b\2\3\18\a\t\0\18\6\b\0X\b\bÄ-\b\1\0009\b\22\b\18\n\2\0\18\v\4\0005\f\24\0B\b\4\3\18\a\t\0\18\6\b\0-\b\2\0009\b\25\b4\n\3\0005\v\27\0\18\f\6\0'\r\26\0&\f\r\f>\f\1\v-\f\3\0\15\0\f\0X\r\2Ä\f\f\a\0X\f\1Ä+\f\0\0=\f\28\v>\v\1\n4\v\3\0004\f\3\0>\3\1\f>\f\1\v6\f\0\0009\f\n\f9\r\3\0008\f\r\f9\f\29\f\15\0\f\0X\r\5Ä4\f\3\0005\r\30\0>\r\1\f\14\0\f\0X\r\1Ä+\f\0\0D\b\4\0\3¿\0¿\1¿\2¿\1\2\0\0\t [+]\rmodified\nguifg\1\0\0\6 \rvec_join\1\0\1\fdefault\2\20lir_folder_icon\19get_icon_color\14directory\nftype\1\0\0\bnil\18incline_state\6b\ttype\14extension\ash\rterminal\fbuftype\abo\bsub\a¬´\14[No Name]\5\rbasename\apl\bbuf\22nvim_buf_get_name\bapi\bvim\2≈\a\1\0\n\0+\00046\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0019\1\4\1+\2\1\0)\0032\0006\4\0\0'\6\5\0B\4\2\0029\4\6\0045\6\b\0003\a\a\0=\a\t\0065\a\n\0=\a\v\0065\a\f\0=\a\r\0065\a\15\0005\b\14\0=\b\16\a=\a\17\0065\a\18\0004\b\0\0=\b\19\a5\b\20\0=\b\21\a=\a\22\0065\a\28\0005\b\24\0005\t\23\0=\t\25\b5\t\26\0=\t\27\b=\b\29\a5\b\30\0=\b\31\a5\b \0=\b!\a5\b\"\0=\b#\a5\b%\0005\t$\0=\t&\b5\t'\0=\t(\b=\b)\a=\a*\6B\4\2\0012\0\0ÄK\0\1\0\vwindow\17winhighlight\rinactive\1\0\3\vSearch\tNone\vNormal\20InclineNormalNC\16EndOfBuffer\tNone\vactive\1\0\0\1\0\3\vSearch\tNone\vNormal\18InclineNormal\16EndOfBuffer\tNone\14placement\1\0\2\15horizontal\nright\rvertical\btop\fpadding\1\0\2\tleft\3\2\nright\3\2\foptions\1\0\3\rwinblend\3\20\15signcolumn\ano\twrap\1\vmargin\1\0\3\17padding_char\6 \vzindex\3\n\nwidth\bfit\rvertical\1\0\2\vbottom\3\0\btop\3\1\15horizontal\1\0\0\1\0\2\tleft\3\0\nright\3\1\vignore\14filetypes\1\a\0\0\18fugitiveblame\18DiffviewFiles\24DiffviewFileHistory\26DiffviewFHOptionPanel\fOutline\14dashboard\rbuftypes\1\0\3\18floating_wins\2\rwintypes\fspecial\21unlisted_buffers\1\14highlight\vgroups\1\0\0\1\0\2\20InclineNormalNC\tNONE\18InclineNormal\tNONE\thide\1\0\3\ronly_win\2\16focused_win\1\15cursorline\2\23debounce_threshold\1\0\2\vrising\3\0\ffalling\0032\vrender\1\0\0\0\nsetup\fincline\nutils\vcommon\vConfig\22nvim-web-devicons\frequire\0", "config", "incline.nvim")

vim.cmd [[ packadd telescope.nvim ]]

-- Config for: telescope.nvim
try_loadstring("\27LJ\2\nN\0\0\6\1\4\0\t6\0\0\0009\0\1\0'\2\2\0\18\4\2\0009\2\3\2-\5\0\0B\2\3\0A\0\0\1K\0\1\0\1¿\vformat\22DiffviewOpen %s^!\bcmd\bvim¢\1\1\0\6\1\t\0\20-\0\0\0009\0\0\0B\0\1\0029\1\1\0006\2\2\0009\2\3\0029\2\4\2)\4\0\0+\5\2\0B\2\3\0016\2\2\0009\2\5\2'\4\6\0B\2\2\0016\2\2\0009\2\a\0023\4\b\0B\2\2\0012\0\0ÄK\0\1\0\1¿\0\rschedule\15stopinsert\bcmd\19nvim_win_close\bapi\bvim\nvalue\23get_selected_entryÅ\15\1\0\n\0N\1é\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0029\2\4\0025\0041\0005\5\6\0005\6\5\0=\6\a\0055\6\b\0005\a\t\0=\a\n\0065\a\v\0=\a\f\6=\6\r\0055\6\14\0=\6\15\0056\6\0\0'\b\16\0B\6\2\0029\6\17\6=\6\18\0054\6\0\0=\6\19\0056\6\0\0'\b\16\0B\6\2\0029\6\20\6=\6\21\0054\6\0\0=\6\22\0055\6\23\0=\6\24\0055\6\25\0=\6\26\0056\6\0\0'\b\27\0B\6\2\0029\6\28\0069\6\29\6=\6\30\0056\6\0\0'\b\27\0B\6\2\0029\6\31\0069\6\29\6=\6 \0056\6\0\0'\b\27\0B\6\2\0029\6!\0069\6\29\6=\6\"\0056\6\0\0'\b\27\0B\6\2\0029\6#\6=\6#\0055\6,\0005\a&\0009\b$\0009\t%\0 \b\t\b=\b'\a9\b(\0=\b)\a9\b*\0=\b+\a=\a-\0065\a.\0009\b(\0=\b)\a9\b*\0=\b+\a=\a/\6=\0060\5=\0052\0045\0054\0005\0063\0=\0065\0055\0066\0=\0067\0055\0068\0=\0069\0055\6>\0005\a=\0005\b;\0003\t:\0=\t<\b=\b-\a=\a0\6=\6?\5=\5@\0045\5B\0005\6A\0=\6C\0055\6E\0005\aD\0=\aF\6=\6G\0054\6\3\0006\a\0\0'\tH\0B\a\2\0029\aI\a4\t\0\0B\a\2\0?\a\0\0=\6J\5=\5K\4B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4M\0B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4C\0B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4G\0B\2\2\0016\2\0\0'\4\3\0B\2\2\0029\2L\2'\4J\0B\2\2\0012\0\0ÄK\0\1\0\vnotify\19load_extension\15extensions\14ui-select\17get_dropdown\21telescope.themes\16media_files\14filetypes\1\0\1\rfind_cmd\afd\1\b\0\0\bpng\twebp\bjpg\tjpeg\bmp4\twebm\bpdf\bfzf\1\0\0\1\0\4\nfuzzy\2\14case_mode\15smart_case\28override_generic_sorter\1\25override_file_sorter\2\fpickers\16git_commits\1\0\0\1\0\0\f<C-M-d>\1\0\0\0\15git_status\1\0\1\15expand_dir\1\14git_files\1\0\1\18results_title\1\15find_files\1\0\0\1\0\1\18results_title\1\rdefaults\1\0\0\rmappings\6n\1\0\0\6i\1\0\0\n<c-f>\27preview_scrolling_down\n<c-b>\25preview_scrolling_up\n<c-q>\1\0\1\n<c-j>\1\16open_qflist\19send_to_qflist\27buffer_previewer_maker\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\fset_env\1\0\1\14COLORTERM\14truecolor\16borderchars\1\t\0\0\b‚îÄ\b‚îÇ\b‚îÄ\b‚îÇ\b‚îå\b‚îê\b‚îò\b‚îî\vborder\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\16file_sorter\19get_fuzzy_file\22telescope.sorters\17path_display\1\2\0\0\rabsolute\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\1\vmirror\1\1\0\3\20prompt_position\btop\nwidth\4\0ÄÄ†ˇ\3\19preview_cutoff\3x\22vimgrep_arguments\1\0\v\rwinblend\3\0\17entry_prefix\a  \17initial_mode\vinsert\23selection_strategy\nreset\20layout_strategy\15horizontal\19color_devicons\2\ruse_less\2\21sorting_strategy\14ascending\18prompt_prefix\n Ôë´ \20selection_caret\t‚û§ \18results_title\1\1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\nsetup\14telescope\28telescope.actions.state\22telescope.actions\frequire\3ÄÄ¿ô\4\0", "config", "telescope.nvim")

vim.cmd [[ packadd lir.nvim ]]

-- Config for: lir.nvim
try_loadstring("\27LJ\2\nS\0\1\a\0\5\0\v6\1\0\0009\1\1\1'\3\2\0006\4\0\0009\4\3\0049\4\4\4\18\6\0\0B\4\2\2&\3\4\3B\1\2\1K\0\1\0\16fnameescape\afn\rnoau cd \bcmd\bvim≠\1\0\1\n\3\6\0\27-\1\0\0009\1\0\1B\1\1\2-\2\1\0\18\4\2\0009\2\1\2\18\5\0\0009\6\2\1B\2\4\2\18\5\1\0009\3\3\1-\6\1\0\18\b\6\0009\6\4\6\18\t\2\0B\6\3\2:\6\1\6B\3\3\2\15\0\3\0X\4\6Ä-\4\2\0009\4\5\4)\6\0\0\18\a\3\0)\b\0\0B\4\4\1K\0\1\0\4¿\a¿\b¿\15set_cursor\fexplode\findexof\bdir\rrelative\16get_contexty\0\0\6\1\6\0\0166\0\0\0009\0\1\0009\0\2\0)\2\0\0B\0\2\0026\1\0\0009\1\3\1'\3\4\0B\1\2\1-\1\0\0009\1\5\1)\3\0\0:\4\1\0)\5\0\0B\1\4\1K\0\1\0\b¿\15set_cursor\tedit\bcmd\24nvim_win_get_cursor\bapi\bvim≥\3\0\1\v\t\15\0G-\1\0\0-\3\1\0B\1\2\1-\1\2\0009\1\0\1B\1\1\1\n\0\0\0X\1\3Ä-\1\3\0\5\0\1\0X\1\1ÄK\0\1\0006\1\1\0009\1\2\1\18\3\0\0B\1\2\2\15\0\1\0X\2\nÄ9\2\3\1\a\2\4\0X\2\aÄ-\2\4\0\18\4\2\0009\2\5\2\18\5\0\0-\6\3\0B\2\4\2\18\0\2\0-\2\2\0009\2\6\2-\4\5\0B\2\2\2\15\0\2\0X\3\6Ä6\3\a\0009\3\b\0039\3\t\3+\5\1\0\18\6\2\0B\3\3\0016\3\1\0009\3\n\3-\5\4\0\18\a\5\0009\5\5\5-\b\6\0009\b\v\b-\t\3\0B\5\4\2-\6\4\0\18\b\6\0009\6\5\6-\t\6\0009\t\v\t\18\n\0\0B\6\4\0A\3\1\2-\4\a\0009\4\f\4B\4\1\1\14\0\3\0X\4\5Ä-\4\2\0009\4\r\4'\6\14\0B\4\2\1K\0\1\0-\4\b\0\18\6\0\0B\4\2\1K\0\1\0\2\0\3¿\3\0\2¿\1\0\4¿\0¿\4\0\5\0\19Rename failed!\berr\vreload\bdir\14fs_rename\18remove_buffer\blib\vConfig\21find_file_buffer\tjoin\14directory\ttype\ffs_stat\auv\17clear_promptÜ\2\1\0\n\6\18\0 -\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\0026\2\2\0009\2\3\0029\4\4\1-\5\1\0009\5\5\5'\6\6\0&\5\6\5'\6\a\0B\2\4\0026\3\b\0009\3\t\3B\3\1\0029\4\n\1-\5\2\0009\a\v\0B\5\2\1-\5\3\0009\5\f\5'\a\r\0005\b\14\0=\2\15\b3\t\16\0=\t\17\bB\5\3\0012\0\0ÄK\0\1\0\4¿\a¿\v¿\b¿\0¿\f¿\rcallback\0\fdefault\1\0\1\15completion\tfile\vMove: \ninput\bdir\rfullpath\bcwd\auv\5\6$\bsep\nvalue\tgsub\vstring\fcurrent\16get_contextq\0\1\a\3\5\0\r-\1\0\0-\2\1\0-\3\2\0009\3\0\3\18\5\0\0005\6\1\0B\3\3\2<\3\2\0016\1\2\0009\1\3\1-\3\0\0'\4\4\0D\1\3\0\5¿\4Ä\1\0\6 \vconcat\ntable\1\0\1\23only_if_whitespace\2\14str_quoteÀ\1\1\3\r\2\v\0\31-\3\0\0009\3\0\3\18\5\1\0\18\6\2\0B\3\3\0036\5\1\0009\5\2\5)\a\1\0\18\b\4\0B\5\3\2\18\4\5\0-\5\1\0009\5\3\5\18\a\3\0)\b\1\0\18\t\4\0B\5\4\0026\6\4\0009\6\5\0063\b\6\0006\t\4\0009\t\a\t9\t\b\t8\v\4\3\14\0\v\0X\f\1Ä'\v\t\0'\f\n\0B\t\3\0002\0\0ÄC\6\1\0\3\0\2\0\tfile\5\18getcompletion\afn\0\ftbl_map\bvim\14vec_slice\bmax\tmath\17scan_sh_argsÿ\5\0\1\17\a\28\1{-\1\0\0-\3\1\0B\1\2\1-\1\2\0009\1\0\1B\1\1\1\14\0\0\0X\1\1ÄK\0\1\0-\1\3\0009\1\1\1\18\3\0\0\21\4\0\0B\1\3\2,\2\3\0006\4\2\0\18\6\1\0B\4\2\4X\aXÄ-\t\4\0\18\v\t\0009\t\3\t\18\f\b\0-\r\5\0009\r\4\rB\t\4\2\18\2\t\0006\t\5\0009\t\6\t\18\v\b\0'\f\a\0B\t\3\2\15\0\t\0X\n\3Ä\18\t\2\0'\n\a\0&\2\n\t\18\v\2\0009\t\b\2'\f\t\0B\t\3\2\18\3\t\0-\t\4\0\18\v\t\0009\t\n\t\18\f\2\0B\t\3\2\14\0\t\0X\t:Ä\15\0\3\0X\t Ä-\t\4\0\18\v\t\0009\t\v\t\18\f\3\0B\t\3\2\14\0\t\0X\t\25Ä6\t\f\0006\v\5\0009\v\r\v9\v\14\v\18\f\3\0'\r\15\0B\t\4\3\15\0\t\0X\v\2Ä\b\n\0\0X\v\14Ä-\v\2\0009\v\16\v5\r\17\0006\14\18\0\18\16\n\0B\14\2\2\a\14\19\0X\14\2Ä\f\14\n\0X\14\1Ä+\14\0\0>\14\2\rB\v\2\1K\0\1\0\18\t\3\0'\n\a\0&\t\n\t\4\t\2\0X\t\19Ä6\t\20\0009\t\21\t\18\v\2\0'\f\22\0)\r§\1B\t\4\2\14\0\t\0X\n\aÄ-\n\2\0009\n\16\n'\f\23\0\18\r\2\0&\f\r\fB\n\2\1K\0\1\0006\n\20\0009\n\24\n\18\f\t\0B\n\2\1E\a\3\3R\a¶\1276\4\5\0009\4\25\4'\6\26\0006\a\5\0009\a\r\a9\a\27\a\18\t\3\0B\a\2\2&\6\a\6B\4\2\1-\4\6\0\18\6\2\0B\4\2\1K\0\1\0\1\0\1¿\2\0\3\0\4\0\0¿\5\0\16fnameescape\ae \bcmd\rfs_close\28Could not create file: \6w\ffs_open\auv\vstring\ttype\1\2\0\0\27Failed to create path!\berr\6p\nmkdir\afn\npcall\vis_dir\rreadable\n(.*)/\nmatch\6/\rendswith\bvim\bdir\rabsolute\vipairs\17scan_sh_args\17clear_prompt\2®\1\1\0\a\6\v\0\20-\0\0\0009\0\0\0B\0\1\0026\1\1\0009\1\2\1B\1\1\2-\2\1\0009\4\3\0B\2\2\1-\2\2\0009\2\4\2'\4\5\0005\5\a\0003\6\6\0=\6\b\0053\6\t\0=\6\n\5B\2\3\0012\0\0ÄK\0\1\0\4¿\v¿\b¿\6¿\a¿\f¿\rcallback\0\15completion\1\0\0\0\19Create paths: \ninput\bdir\bcwd\auv\16get_contextç\2\0\0\n\4\v\1\"-\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\2-\2\1\0009\2\2\2\18\4\0\0'\5\3\0B\2\3\2\14\0\2\0X\3\1ÄK\0\1\0-\3\1\0009\3\4\0035\5\5\0009\6\6\1>\6\3\5\18\6\2\0B\3\3\4\b\4\0\0X\6\aÄ-\6\2\0009\6\a\0069\6\b\6'\b\t\0\18\t\5\0&\b\t\bB\6\2\1-\6\3\0009\6\n\6B\6\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to stage path: \nerror\bgit\rfullpath\1\3\0\0\bgit\badd\16system_list\17git.toplevel\15tbl_access\fcurrent\16get_context\0Ù\1\0\0\t\4\n\1\31-\0\0\0009\0\0\0B\0\1\2-\1\1\0009\1\1\1\18\3\0\0'\4\2\0B\1\3\2\14\0\1\0X\2\1ÄK\0\1\0-\2\1\0009\2\3\0025\4\4\0009\5\5\0>\5\3\4\18\5\1\0B\2\3\4\b\3\0\0X\5\aÄ-\5\2\0009\5\6\0059\5\a\5'\a\b\0\18\b\4\0&\a\b\aB\5\2\1-\5\3\0009\5\t\5B\5\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to stage path: \nerror\bgit\bdir\1\3\0\0\bgit\badd\16system_list\17git.toplevel\15tbl_access\16get_context\0í\2\0\0\n\4\v\1\"-\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\2-\2\1\0009\2\2\2\18\4\0\0'\5\3\0B\2\3\2\14\0\2\0X\3\1ÄK\0\1\0-\3\1\0009\3\4\0035\5\5\0009\6\6\1>\6\4\5\18\6\2\0B\3\3\4\b\4\0\0X\6\aÄ-\6\2\0009\6\a\0069\6\b\6'\b\t\0\18\t\5\0&\b\t\bB\6\2\1-\6\3\0009\6\n\6B\6\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to reset path: \nerror\bgit\rfullpath\1\4\0\0\bgit\nreset\a--\16system_list\17git.toplevel\15tbl_access\fcurrent\16get_context\0˘\1\0\0\t\4\n\1\31-\0\0\0009\0\0\0B\0\1\2-\1\1\0009\1\1\1\18\3\0\0'\4\2\0B\1\3\2\14\0\1\0X\2\1ÄK\0\1\0-\2\1\0009\2\3\0025\4\4\0009\5\5\0>\5\4\4\18\5\1\0B\2\3\4\b\3\0\0X\5\aÄ-\5\2\0009\5\6\0059\5\a\5'\a\b\0\18\b\4\0&\a\b\aB\5\2\1-\5\3\0009\5\t\5B\5\1\1K\0\1\0\4¿\b¿\t¿\0¿\vreload\27Failed to reset path: \nerror\bgit\bdir\1\4\0\0\bgit\nreset\a--\16system_list\17git.toplevel\15tbl_access\16get_context\0Â\1\0\0\b\3\b\0%-\0\0\0009\0\0\0B\0\1\2\18\3\0\0009\1\1\0B\1\2\2-\2\1\0009\2\2\2\18\4\1\0'\5\3\0B\2\3\2\15\0\2\0X\3\aÄ\18\5\2\0009\3\4\2)\6\2\0)\a\2\0B\3\4\2\6\3\5\0X\3\4Ä-\3\2\0009\3\6\3B\3\1\1X\3\fÄ\15\0\2\0X\3\nÄ\18\5\2\0009\3\4\2)\6\1\0)\a\1\0B\3\4\2\15\0\3\0X\4\3Ä-\3\2\0009\3\a\3B\3\1\1K\0\1\0\4¿\b¿\0¿\14git_reset\14git_stage\6 \bsub\15git.status\15tbl_access\fcurrent\16get_context|\0\0\3\0\b\0\0156\0\0\0009\0\1\0009\0\2\0+\2\2\0B\0\2\0016\0\3\0009\0\4\0009\0\5\0\15\0\0\0X\1\4Ä6\0\3\0009\0\6\0'\2\a\0B\0\2\1K\0\1\0\rwincmd q\bcmd\17lir_is_float\6w\bvim\18remove_buffer\blib\vConfigE\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\5¿\fnorm! j\bcmd\bvim\16toggle_markE\0\0\3\1\4\0\b-\0\0\0009\0\0\0B\0\1\0016\0\1\0009\0\2\0'\2\3\0B\0\2\1K\0\1\0\5¿\fnorm! k\bcmd\bvim\16toggle_mark \0\0\1\0\1\0\0025\0\0\0L\0\2\0\1\0\1\vborder\vsingleö\2\0\1\t\1\t\0007-\1\0\0\18\3\1\0009\1\0\1-\4\0\0\18\6\4\0009\4\1\4\f\a\0\0X\a\1Ä'\a\2\0B\4\3\0A\1\1\2-\2\0\0\18\4\2\0009\2\3\2\18\5\1\0B\2\3\2\14\0\2\0X\3\23Ä-\2\0\0\18\4\2\0009\2\3\2-\5\0\0\18\a\5\0009\5\4\5\18\b\1\0B\5\3\2\14\0\5\0X\6\1Ä'\5\5\0B\2\3\2\14\0\2\0X\2\tÄ-\2\0\0\18\4\2\0009\2\0\0026\5\6\0009\5\a\5B\5\1\0A\2\1\2\18\1\2\0X\2\rÄ-\2\0\0\18\4\2\0009\2\b\2\18\5\1\0B\2\3\2\14\0\2\0X\2\6Ä-\2\0\0\18\4\2\0009\2\4\2\18\5\1\0B\2\3\2\18\1\2\0L\1\2\0\a¿\vis_dir\bcwd\auv\5\vparent\rreadable\6%\15vim_expand\rabsoluteW\0\1\t\1\5\0\r6\1\0\0009\1\1\1'\3\2\0006\4\0\0009\4\3\0049\4\4\4-\6\0\0\18\b\0\0B\6\2\0A\4\0\2&\3\4\3B\1\2\1K\0\1\0\r¿\16fnameescape\afn\ae \bcmd\bvimt\0\1\t\2\3\0\20+\1\0\0\15\0\0\0X\2\nÄ-\2\0\0\18\4\2\0009\2\0\2-\5\0\0\18\a\5\0009\5\1\5\18\b\0\0B\5\3\0A\2\1\2\18\1\2\0-\2\1\0009\2\2\2\f\4\1\0X\4\1Ä+\4\0\0B\2\2\1K\0\1\0\a¿\2¿\tinit\15vim_expand\rabsolute:\0\1\6\2\1\0\n-\1\0\0009\1\0\1-\3\1\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä+\3\0\0B\1\2\1K\0\1\0\2¿\r¿\vtoggleL\0\1\4\1\3\0\r-\1\0\0009\1\0\0019\3\1\0:\3\1\3\6\3\2\0X\3\4Ä9\3\1\0:\3\1\3\14\0\3\0X\4\1Ä+\3\0\0B\1\2\1K\0\1\0\n¿\5\nfargs\fexploreO\0\1\4\1\3\0\r-\1\0\0009\1\0\0019\3\1\0:\3\1\3\6\3\2\0X\3\4Ä9\3\1\0:\3\1\3\14\0\3\0X\4\1Ä+\3\0\0B\1\2\1K\0\1\0\n¿\5\nfargs\15open_floatô\n\1\0\19\0f\0î\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\0\0'\4\3\0B\2\2\0026\3\0\0'\5\4\0B\3\2\0026\4\0\0'\6\5\0B\4\2\0026\5\0\0'\a\6\0B\5\2\0029\6\0\3'\b\a\0B\6\2\0026\a\b\0009\a\t\a9\a\n\a9\a\v\a6\b\b\0009\b\t\b9\b\n\b6\t\b\0009\t\t\t9\t\f\t4\n\0\0003\v\r\0003\f\14\0003\r\16\0=\r\15\0003\r\18\0=\r\17\0003\r\20\0=\r\19\0003\r\22\0=\r\21\0003\r\24\0=\r\23\0003\r\26\0=\r\25\0003\r\28\0=\r\27\0003\r\30\0=\r\29\0006\r\0\0'\15\5\0B\r\2\0029\r\31\r5\15 \0005\16!\0009\17\15\0=\17\"\0169\17#\0=\17$\0169\17#\0=\17%\0169\17#\0=\17&\0169\17'\0=\17(\0169\17)\0=\17*\0169\17+\0=\17,\0169\17-\0=\17.\0169\17-\0=\17/\0163\0170\0=\0171\0169\0172\0=\0173\0169\17\19\0=\0174\0169\17\17\0=\0175\0169\0176\0=\0177\0169\0178\0=\0179\0169\17:\0=\17;\0169\17<\0=\17=\0169\17>\5=\17?\0163\17@\0=\17A\0163\17B\0=\17C\0169\17D\1=\17E\0169\17F\1=\17G\0169\17H\1=\17I\0169\17\29\0=\17J\0169\17\23\0=\17K\0169\17\25\0=\17L\0169\17\27\0=\17M\16=\16N\0155\16O\0003\17P\0=\17Q\16=\16R\15B\r\2\0016\r\0\0'\15S\0B\r\2\0029\r\31\r5\15T\0B\r\2\0013\rU\0003\14W\0=\14V\n3\14Y\0=\14X\n3\14[\0=\14Z\n6\14\\\0009\14]\0149\14^\14'\16_\0003\17`\0005\18a\0B\14\4\0016\14\\\0009\14]\0149\14^\14'\16b\0003\17c\0005\18d\0B\14\4\0016\14\b\0009\14e\14=\n\5\0142\0\0ÄK\0\1\0\vplugin\1\0\3\bbar\2\nnargs\6?\rcomplete\bdir\0\rLirFloat\1\0\3\bbar\2\nnargs\6?\rcomplete\bdir\0\15LirExplore\29nvim_create_user_command\bapi\bvim\0\17toggle_float\0\15open_float\0\fexplore\0\1\0\1\17show_ignored\2\19lir.git_status\nfloat\rwin_opts\0\1\0\1\rwinblend\3\0\rmappings\6U\6u\6S\6s\6p\npaste\6x\bcut\6y\tcopy\6K\0\6J\0\6t\16toggle_mark\6d\vdelete\n<C-h>\23toggle_show_hidden\agy\14yank_path\n<C-]>\acd\6m\6a\6e\fnewfile\6q\0\6h\6-\aup\n<C-t>\ftabedit\n<C-v>\vvsplit\n<C-s>\nsplit\6l\6o\t<CR>\tedit\6R\1\0\0\1\0\3\22show_hidden_files\2\20devicons_enable\2\16hide_cursor\2\nsetup\0\21git_toggle_stage\0\18git_reset_all\0\14git_reset\0\18git_stage_all\0\14git_stage\0\17create_paths\0\tmove\0\vreload\0\0\vnotify\apl\nutils\vcommon\vConfig\24diffview.arg_parser\21lir.mark.actions\blir\14user.lazy\14lir.float\26lir.clipboard.actions\16lir.actions\frequire\0", "config", "lir.nvim")

vim.cmd [[ packadd nvim-bufferline.lua ]]

-- Config for: nvim-bufferline.lua
try_loadstring("\27LJ\2\nk\0\3\15\1\5\0\17'\3\0\0006\4\1\0\18\6\2\0B\4\2\4H\a\tÄ6\t\2\0009\t\3\t'\v\4\0\18\f\3\0-\r\0\0008\r\a\r\18\14\b\0B\t\5\2\18\3\t\0F\a\3\3R\aı\127L\3\2\0\1¿\r%s %s %d\vformat\vstring\npairs\5ú\6\1\0\b\0\22\0!6\0\0\0009\0\1\0009\0\2\0009\0\3\0005\1\4\0006\2\5\0'\4\6\0B\2\2\0029\2\a\0025\4\16\0005\5\b\0003\6\t\0=\6\n\0055\6\v\0=\6\f\0054\6\3\0005\a\r\0>\a\1\0065\a\14\0>\a\2\6=\6\15\5=\5\17\4B\2\2\1\18\2\0\0'\4\18\0005\5\19\0B\2\3\1\18\2\0\0'\4\20\0005\5\21\0B\2\3\0012\0\0ÄK\0\1\0\1\0\1\nstyle\tbold BufferLineDiagnosticVisible\1\0\1\nstyle\tbold\25BufferLineDiagnostic\foptions\1\0\0\foffsets\1\0\3\rfiletype\18DiffviewFiles\15text_align\vcenter\ttext\19Source Control\1\0\3\rfiletype\rNvimTree\15text_align\vcenter\ttext\nFiles\20separator_style\1\3\0\0\b‚îÇ\b‚îÇ\26diagnostics_indicator\0\1\0\16\15close_icon\bÔÄç\fnumbers\tnone\18modified_icon\b‚óè\23right_trunc_marker\bÔÇ©\22buffer_close_icon\bÔôï\22left_trunc_marker\bÔÇ®\tview\fdefault\20max_name_length\3\18\22max_prefix_length\3\15\rtab_size\3\18\16diagnostics\rnvim_lsp\28show_buffer_close_icons\2\20show_close_icon\1\24persist_buffer_sort\2\25enforce_regular_tabs\1\27always_show_bufferline\2\nsetup\15bufferline\frequire\1\0\4\fwarning\bÔÅ±\nerror\bÔÅó\tinfo\bÔÅö\thint\bÔÅ™\ahi\ahl\vcommon\vConfig\0", "config", "nvim-bufferline.lua")

vim.cmd [[ packadd nvim-cmp ]]

-- Config for: nvim-cmp
try_loadstring("\27LJ\2\n;\0\1\4\0\4\0\0066\1\0\0009\1\1\0019\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\20vsnip#anonymous\afn\bvim’\1\0\2\4\1\5\0\n-\2\0\0009\3\0\0018\2\3\2=\2\0\0015\2\2\0009\3\3\0009\3\4\0038\2\3\2=\2\1\1L\1\2\0\4¿\tname\vsource\1\0\n\nemoji\f[Emoji]\bgit\n[VCS]\forgmode\n[Org]\nneorg\f[Neorg]\nspell\f[Spell]\tcalc\v[Calc]\fluasnip\14[Luasnip]\rnvim_lsp\n[LSP]\tpath\v[Path]\vbuffer\r[Buffer]\tmenu\tkindq\0\1\a\1\2\1\15-\1\0\0009\1\0\1\18\3\0\0-\4\0\0009\4\1\4\18\6\0\0B\4\2\0A\1\1\2*\2\0\0\0\1\2\0X\2\2Ä+\2\1\0X\3\1Ä+\2\2\0L\2\2\0\0\0\24nvim_buf_line_count\24nvim_buf_get_offsetÄÄÄ\1à\1\1\0\t\2\a\0\0166\0\0\0009\0\1\0003\2\2\0-\3\1\0009\3\3\3-\5\1\0009\5\4\0055\a\5\0B\5\2\2-\6\1\0009\6\4\0065\b\6\0B\6\2\0A\3\1\0002\0\0ÄC\0\1\0\2¿\3¿\1\0\1\14no_hidden\2\1\0\1\vlisted\2\14list_bufs\14vec_union\0\15tbl_filter\bvim©\v\1\0\15\0@\0h6\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\0026\2\3\0009\2\4\0026\3\5\0009\3\6\0039\3\a\0035\4\b\0009\5\t\0\18\a\5\0009\5\n\5B\5\2\0019\5\v\0005\a\15\0005\b\r\0003\t\f\0=\t\14\b=\b\16\a9\b\17\0009\b\18\b9\b\19\b5\n\21\0009\v\17\0009\v\20\v)\r¸ˇB\v\2\2=\v\22\n9\v\17\0009\v\20\v)\r\4\0B\v\2\2=\v\23\n9\v\17\0009\v\24\vB\v\1\2=\v\25\n9\v\17\0009\v\26\vB\v\1\2=\v\27\n9\v\17\0009\v\28\v5\r\29\0009\14\30\0009\14\31\14=\14 \rB\v\2\2=\v!\nB\b\2\2=\b\17\a5\b\"\0005\t#\0=\t$\b3\t%\0=\t&\b=\b'\a5\b)\0005\t(\0=\t*\b=\b+\a4\b\t\0005\t,\0>\t\1\b5\t-\0>\t\2\b5\t.\0>\t\3\b5\t/\0>\t\4\b5\t0\0>\t\5\b5\t1\0>\t\6\b5\t2\0>\t\a\b5\t3\0005\n5\0003\v4\0=\v6\n=\n7\t>\t\b\b=\b8\aB\5\2\0019\5\t\0\18\a\5\0009\0059\5'\b:\0009\t;\1B\t\1\0A\5\2\0016\5\0\0'\a<\0B\5\2\0029\5\v\0055\a>\0005\b=\0=\b?\aB\5\2\0012\0\0ÄK\0\1\0\14filetypes\1\0\0\1\5\0\0\14gitcommit\24NeogitCommitMessage\rmarkdown\tocto\fcmp_git\20on_confirm_done\17confirm_done\aon\fsources\voption\15get_bufnrs\1\0\0\0\1\0\2\19max_item_count\3\20\tname\vbuffer\1\0\1\tname\tpath\1\0\1\tname\nspell\1\0\1\tname\bgit\1\0\1\tname\nneorg\1\0\1\tname\nvsnip\1\0\1\tname\rnvim_lsp\1\0\1\tname\rnvim_lua\vwindow\18documentation\1\0\0\1\0\3\17winhighlight0Normal:Normal,CursorLine:Visual,Search:None\vzindex\3È\a\vborder\vsingle\15formatting\vformat\0\vfields\1\4\0\0\tkind\tabbr\tmenu\1\0\1\15deprecated\2\t<CR>\rbehavior\vInsert\20ConfirmBehavior\1\0\1\vselect\1\fconfirm\n<C-e>\nclose\14<C-Space>\rcomplete\n<C-f>\n<C-b>\1\0\0\16scroll_docs\vinsert\vpreset\fmapping\fsnippet\1\0\0\vexpand\1\0\0\0\nsetup\nclear\nevent\1\0\25\14Reference\n ÔíÅ \nValue\n Ô¢ü \fSnippet\n Ôóè \tEnum\n Ô©ó \tUnit\n Ô•¨ \tText\n Ôî´ \14Interface\t Ô®†\vStruct\n ÔÜ≥ \nClass\n Ô†ñ \16Constructor\n Óàè \vFolder\n Ô±Æ \rConstant\n Ôõº \rVariable\n[Óúñ]\rOperator\n Ôöî \nField\n Óúñ \15EnumMember\n ÔÖù \nColor\n Óà´ \nEvent\n ÔÉß \18TypeParameter\n<ÔûÉ>\rFunction\n Óûõ \rProperty\n ÔÇ≠ \vMethod\n Óûõ \vModule\n Ôô® \tFile\n ÔÖõ \fKeyword\n Ôùß \nutils\vcommon\vConfig\bapi\bvim\"nvim-autopairs.completion.cmp\bcmp\frequire\0", "config", "nvim-cmp")

time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'startuptime.vim'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutline lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutline", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutlineOpen lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutlineOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutlineClose lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutlineClose", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
