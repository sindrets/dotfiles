--- @brief
---
--- https://github.com/EmmyLuaLs/emmylua-analyzer-rust
---
--- Emmylua Analyzer Rust. Language Server for Lua.
---
--- `emmylua_ls` can be installed using `cargo` by following the instructions[here]
--- (https://github.com/EmmyLuaLs/emmylua-analyzer-rust?tab=readme-ov-file#install).
---
--- The default `cmd` assumes that the `emmylua_ls` binary can be found in `$PATH`.
--- It might require you to provide cargo binaries installation path in it.

--- @type vim.lsp.Config
return {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.emmyrc.json',
    '.luacheckrc',
    '.git',
  },
  workspace_required = false,
  single_file_support = true,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      codeAction = {
        insertSpace = true,
      },
      strict = {
        typeCall = true,
        arrayIndex = false,
        metaOverrideFileDefine = true,
      },
      diagnostics = {
        enable = true,
        disable = {
          "unnecessary-if",
          "unnecessary-assert",
        },
        severity = {
          ["param-type-mismatch"] = "error",
          ["return-type-mismatch"] = "error",
          ["assign-type-mismatch"] = "error",
          ["type-not-found"] = "error",
        },
      },
      hint = {
        enable = true,
        paramHint = false,
        indexHint = false,
        localHint = true,
        overrideHint = true,
        metaCallHint = true,
      },
    },
  },
}
