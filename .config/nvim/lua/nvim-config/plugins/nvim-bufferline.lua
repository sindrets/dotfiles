return function ()
  local symbol_map = {
    error = "",
    warning = "",
    info = "",
    hint = "",
  }

  require('bufferline').setup({
    options = {
      view = "default",
      numbers = "none",
      buffer_close_icon= '',
      modified_icon = '●',
      close_icon = '',
      left_trunc_marker = '',
      right_trunc_marker = '',
      max_name_length = 18,
      max_prefix_length = 15, -- prefix used when a buffer is deduplicated
      tab_size = 18,
      diagnostics = "nvim_lsp",
      ---@diagnostic disable-next-line: unused-local
      diagnostics_indicator = function(total_count, level, diagnostics_dict)
        local s = ""
        for kind, count in pairs(diagnostics_dict) do
          s = string.format("%s %s %d", s, symbol_map[kind], count)
        end
        return s
      end,
      show_buffer_close_icons = true,
      show_close_icon = false,
      persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
      -- can also be a table containing 2 custom separators
      -- [focused and unfocused]. eg: { '|', '|' }
      separator_style = { "▏", "▕" },
      -- separator_style = "thin",        --  "slant" | "thick" | "thin" | { 'any', 'any' },
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      -- sort_by = 'extension' | 'relative_directory' | 'directory' | function(buffer_a, buffer_b)
        --   -- add custom logic
        --   return buffer_a.modified > buffer_b.modified
        -- end
        offsets = {
          {
            filetype = "NvimTree",
            text = "Files",
            text_align = "center"
          },
          {
            filetype = "DiffviewFiles",
            text = "Source Control",
            text_align = "center"
          },
        },
      },
    })

  vim.api.nvim_exec([[
    hi! BufferLineDiagnostic gui=bold
    hi! BufferLineDiagnosticVisible gui=bold
  ]], false)
end
