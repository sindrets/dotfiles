local lspconfig = require("lspconfig")
local configs = require("lspconfig/configs") -- Make sure this is a slash (as theres some metamagic happening behind the scenes)
if not lspconfig.teal then
   configs.teal = {
      default_config = {
         cmd = {
            "teal-language-server",
            -- "logging=on", use this to enable logging in /tmp/teal-language-server.log
         },
         filetypes = { "teal" };
         root_dir = lspconfig.util.root_pattern("tlconfig.lua", ".git"),
         settings = {};
      },
   }
end
lspconfig.teal.setup(LspGetDefaultConfig())
