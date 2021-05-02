require'bufferline'.setup{
  options = {
    view = "default",
    numbers = "none",
    number_style = "superscript",
    mappings = false,
    buffer_close_icon= '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is deduplicated
    tab_size = 18,
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level, diagnostics_dict)
      local s = ""
      for e, n in pairs(diagnostics_dict) do
        local sym = ""
        if e == "error" then
          sym = "  "
        elseif e == "warning" then
          sym = "  "
        elseif e == "info" then
          sym = "  "
        elseif e == "other" then
          sym = "  "
        end
        s = s .. sym .. n
      end
      return s
    end,
    show_buffer_close_icons = true,
    show_close_icon = false,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "slant",        --  "slant" | "thick" | "thin" | { 'any', 'any' },
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    -- sort_by = 'extension' | 'relative_directory' | 'directory' | function(buffer_a, buffer_b)
    --   -- add custom logic
    --   return buffer_a.modified > buffer_b.modified
    -- end
  }
}
