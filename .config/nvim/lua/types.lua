-- this code seems weird, but it hints the lsp server to merge the required
-- packages in the vim global variable
vim = require("vim.shared")
vim = require("vim.uri")
vim = require("vim.inspect")

-- let sumneko know where the sources are for the global vim runtime
vim.lsp = require("vim.lsp")
vim.treesitter = require("vim.treesitter")
vim.highlight = require("vim.highlight")
