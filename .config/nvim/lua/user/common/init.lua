local lazy = require("user.lazy")

return {
  au = lazy.require("user.common.au"), ---@module "user.common.au"
  color = lazy.require("user.common.color"), ---@module "user.common.color"
  hl = lazy.require("user.common.hl"), ---@module "user.common.hl"
  utils = lazy.require("user.common.utils"), ---@module "user.common.utils"
  notify = lazy.require("user.common.notify"), ---@module "user.common.notify"
  loop = lazy.require("user.common.loop"), ---@module "user.common.loop"
}
