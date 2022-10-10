return function ()
  local npairs = require("nvim-autopairs")
  local Rule = require("nvim-autopairs.rule")
  local cond = require("nvim-autopairs.conds")

  npairs.setup({
    disable_filetype = { "TelescopePrompt" },
    break_line_filetype = nil, -- mean all file type
    html_break_line_filetype = {
      "html" ,
      "vue" ,
      "typescriptreact" ,
      "svelte" ,
      "javascriptreact"
    },
    ignored_next_char = "[%w%%%'%[%\"%.]",
    enable_check_bracket_line = false,
    check_ts = true,
  })

  local function get_rules(start)
    local t = npairs.get_rule(start)

    if not t then
      return {}
    elseif t.start_pair then
      return { t }
    else
      return t
    end
  end

  npairs.add_rules({
    Rule("$", "$",{ "tex", "latex", "norg" })
        -- don't move right when repeat character
        :with_move(cond.none())
        -- disable adding a newline when you press <cr>
        :with_cr(cond.none()),
    -- Superscript
    Rule("^", "^",{ "norg" })
        :with_move(cond.none())
        :with_cr(cond.none()),
    Rule("/", "/",{ "norg" })
        :with_move(cond.none())
        :with_cr(cond.none()),
    Rule("_", "_",{ "norg" })
        :with_move(cond.none())
        :with_cr(cond.none()),
  })

  get_rules("'")[1].not_filetypes = { "scheme", "lisp", "racket" }
  get_rules("`")[1].not_filetypes = { "scheme", "lisp", "racket" }
end
