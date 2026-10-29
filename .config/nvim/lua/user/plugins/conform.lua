return function()
  local lz = require("user.lazy")
  local conform = require("conform")

  local Path = lz.require("imminent.fs.Path") ---@module "imminent.fs.Path"

  local pb = Config.common.pb

  --- Ordered list of formatters. Pick first available.
  local function ol(...)
    return pb.assign(pb.concat(...), { stop_after_first = true })
  end

  local biome_or_prettier = ol("biome", "prettierd", "prettier")

  conform.formatters.prettier = {
    append_args = function()
      return {
        "--plugin",
        Path.from("~/.local/lib/node_modules/prettier-plugin-astro/dist/index.js")
          :absolute()
          :tostring(),
      }
    end,
  }

  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform will run multiple formatters sequentially
      python = { "ruff_organize_imports", "ruff_format" },
      -- Use a sub-list to run only the first available formatter
      javascript = biome_or_prettier,
      javascriptreact = biome_or_prettier,
      typescript = biome_or_prettier,
      typescriptreact = biome_or_prettier,
      astro = biome_or_prettier,
      css = biome_or_prettier,
      scss = biome_or_prettier,
      sass = biome_or_prettier,
      html = biome_or_prettier,
      markdown = biome_or_prettier,
      json = { "jq" },
      jsonc = { "deno_fmt" },
      rust = { "rustfmt" },
      c = { "clang-format" },
      bash = { "shuck" },
      sh = { "shuck" },
      zsh = { "shuck" },
      go = { "gofumpt" },
      templ = { "templ" },
    },
  })

  vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

  Config.common.au.declare_group("user.conform.nvim", {}, {
    {
      "LspAttach",
      callback = function()
        vim.opt_local.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    }
  })
end
