return function()
  vim.g.firenvim_config = {
    globalSettings = {
      alt = "all",
    },
    localSettings = {
      [".*"] = {
        cmdline = "neovim",
        content = "text",
        priority = 0,
        selector = "textarea",
        takeover = "never",
      },
    }
  }

  local function is_initialized()
    -- TODO: Just checking 'lines' and 'columns' is not reliable. Firenvim
    -- might resize to exactly these dimensions. Should try to find some
    -- additional indicators.
    local options = {
      lines = 24,
      columns = 80,
    }
    for k, v in pairs(options) do
      if vim.o[k] ~= v then
        return true
      end
    end
    return false
  end

  if vim.g.started_by_firenvim then
    vim.opt.guifont = "monospace:h10"

    Config.common.au.declare_group("firenvim_config", {}, {
      {
        "UIEnter",
        {
          once = true,
          callback = function()
            local max_duration = 5000
            local timer = uv.new_timer()
            local last = uv.hrtime()

            timer:start(100, 100, vim.schedule_wrap(function()
              if is_initialized() or (uv.hrtime() - last) / 1000000 >= max_duration then
                timer:stop()
                timer:close()
                vim.opt.lines = math.max(vim.o.lines, 12)
                vim.cmd("hi clear")
                if Config.colorscheme.bg then
                  vim.opt.bg = Config.colorscheme.bg
                end
                vim.cmd("colorscheme " .. Config.colorscheme.name)
              end
            end))
          end,
        },
      },
    })
  end
end
