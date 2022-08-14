local api = vim.api

local M = {}

---@class AucmdCallbackSpec
---@field id integer Aucmd ID.
---@field event string
---@field group integer?
---@field match string Expanded value of `<amatch>`
---@field buf integer Expanded value of `<abuf>`.
---@field file string Expand value of `<afile>`.

---@class AucmdSpec
---@field [1] string|string[]
---@field group string|integer
---@field pattern string|string[]
---@field buffer integer
---@field desc string
---@field callback fun(state: AucmdCallbackSpec)
---@field command string
---@field once boolean
---@field nested boolean

---Declare an autocommand group.
---@param name string
---@param opts { clear: boolean } Augroup options.
---@param aucmds AucmdSpec[]
---@return integer group_id
function M.declare_group(name, opts, aucmds)
  local id = api.nvim_create_augroup(name, opts)
  for _, aucmd in ipairs(aucmds) do
    local auopts = vim.tbl_extend("force", aucmd, { group = id }) --[[@as table ]]
    auopts[1] = nil
    api.nvim_create_autocmd(aucmd[1], auopts)
  end
  return id
end

return M
