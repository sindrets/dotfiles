return function ()
  local remap = vim.api.nvim_set_keymap
  local npairs = require('nvim-autopairs')
  _G.CompeConfig = {}

  require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
      path = true,
      buffer = true,
      calc = true,
      spell = true,
      nvim_lsp = true,
      nvim_lua = true,
      vsnip = true,
      ultisnips = true,
      luasnip = true,
    };
  }

  vim.g.completion_confirm_key = ""

  function CompeConfig.compe_completion_confirm ()
    if vim.fn.pumvisible() ~= 0  then
      return vim.fn["compe#confirm"]({ keys = '<CR>', select = true })
    else
      return npairs.autopairs_cr()
    end
  end

  remap('i' , '<CR>','v:lua.CompeConfig.compe_completion_confirm()', { expr = true, noremap = true })
end
