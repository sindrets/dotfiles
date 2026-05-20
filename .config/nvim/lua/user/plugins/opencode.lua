return function()
  local lz = require("user.lazy")
  local snacks_term = lz.require("snacks.terminal") ---@module "snacks.terminal"

  local opencode_cmd = "opencode --port"
  local terminal_opts = {
    win = {
      position = "right",
      enter = false,
      title = {},
      wo = {
        signcolumn = "no",
        winbar = "",
        winfixwidth = true
      },
      on_win = function(win)
        vim.schedule(function() vim.cmd.wincmd("=") end)
        -- Set up keymaps and cleanup for an arbitrary terminal
        require("opencode.terminal").setup(win.win)
      end,
    },
  }
  vim.g.opencode_opts = {
    server = {
      start = function() snacks_term.open(opencode_cmd, terminal_opts) end,
      stop = function() snacks_term.get(opencode_cmd, terminal_opts):close() end,
      toggle = function()
        snacks_term.toggle(
          opencode_cmd,
          pb.deep_extend(terminal_opts, { win = { enter = true } })
        )
      end,
    },
  }

  -- Recommended/example keymaps
  -- vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
  -- vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Select opencode…" })
  vim.keymap.set(
    { "n" },
    "<leader>ac",
    function() require("opencode").toggle() end,
    { desc = "Toggle opencode" }
  )
  vim.keymap.set(
    { "x" },
    "<leader>ap",
    function() return require("opencode").operator("@this ") end,
    { desc = "Add range to opencode", expr = true }
  )
  -- vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
  --
  -- vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
  -- vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })
  --
  -- -- You may want these if you use the opinionated `<C-a>` and `<C-x>` keymaps above — otherwise consider `<leader>o…` (and remove terminal mode from the `toggle` keymap)
  -- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
  -- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
end
