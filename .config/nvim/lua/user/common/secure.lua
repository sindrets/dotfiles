--- @namespace user.common.secure

--- @class Secure
local secure = {}

--- Writes provided {trust} table to trust database at
--- $XDG_STATE_HOME/nvim/trust.
---
--- @param trust table<string, string> Trust table to write
local function write_trust(trust)
  vim.validate('trust', trust, 'table')
  local f = assert(io.open(vim.fn.stdpath('state') .. '/trust', 'w'))

  local t = {} --- @type string[]
  for p, h in pairs(trust) do
    t[#t + 1] = string.format('%s %s\n', h, p)
  end
  f:write(table.concat(t))
  f:close()
end

--- If {fullpath} is a file, read the contents of {fullpath} (or the contents of {bufnr}
--- if given) and returns the contents and a hash of the contents.
---
--- If {fullpath} is a directory, then nothing is read from the filesystem, and
--- `contents = true` and `hash = "directory"` is returned instead.
---
--- @param fullpath (string) Path to a file or directory to read.
--- @param bufnr (number?) The number of the buffer.
--- @return string|boolean? contents the contents of the file, or true if it's a directory
--- @return string? hash the hash of the contents, or "directory" if it's a directory
local function compute_hash(fullpath, bufnr)
  local contents ---@type string|boolean?
  local hash ---@type string
  if vim.fn.isdirectory(fullpath) == 1 then
    return true, 'directory'
  end

  if bufnr then
    local newline = vim.bo[bufnr].fileformat == 'unix' and '\n' or '\r\n'
    contents =
      table.concat(vim.api.nvim_buf_get_lines(bufnr --[[@as integer]], 0, -1, false), newline)
    if vim.bo[bufnr].endofline then
      contents = contents .. newline
    end
  else
    do
      local f = io.open(fullpath, 'r')
      if not f then
        return nil, nil
      end
      contents = f:read('*a')
      f:close()
    end

    if not contents then
      return nil, nil
    end
  end

  hash = vim.fn.sha256(contents)

  return contents, hash
end

--- Reads trust database from $XDG_STATE_HOME/nvim/trust.
---
--- @return table<string, string> Contents of trust database, if it exists. Empty table otherwise.
function secure.read_trust()
  local db = {} ---@type table<string, string>
  local f = io.open(vim.fn.stdpath('state') .. '/trust', 'r')
  if f then
    local contents = f:read('*a')
    if contents then
      for line in vim.gsplit(contents, '\n') do
        local hash, file = string.match(line, '^(%S+) (.+)$')
        if hash and file then
          db[file] = hash
        end
      end
    end
    f:close()
  end

  return db
end

--- @param path string
--- @param action "allow"|"deny"|"remove"
function secure.update_trust(path, action)
  local db = secure.read_trust()
  local fullpath = Path.from_str(path):unwrap():absolute():tostring()

  if action == "allow" then
    local _, hash = compute_hash(fullpath)
    db[fullpath] = hash
  elseif action == "deny" then
    db[fullpath] = "!"
  elseif action == "remove" then
    db[fullpath] = nil
  end

  write_trust(db)
end

--- @param file string|int # Path or bufnr
function secure.is_trusted(file)
  local Path = Config.common.utils.Path

  local db = secure.read_trust()
  local path --- @type imminent.fs.Path

  if type(file) == "number" then
    local bufname = vim.api.nvim_buf_get_name(file)
    if bufname == "" then return false end
    path = Path.from(bufname):absolute()
  else
    path = Path.from(file):absolute()
  end

  if db[path:tostring()] == "!" or not path:is_readable():block_on() then
    return false
  end

  local _, hash = compute_hash(path:tostring())

  if db[path:tostring()] == hash then
    return true
  end

  return false
end

--- Like `vim.secure.read()`, but with better handling to ensure the prompt
--- message stays visible.
---
--- @param path string
--- @return string?
function secure.read(path)
  local async = require("imminent")

  if secure.is_trusted(path) then
    return async.fs.read_file(path):block_on():unwrap()
  end

  local Path = Config.common.utils.Path
  local utils = Config.common.utils
  local notify = Config.common.notify

  local ok, resp = pcall(
    utils.input_char,
    string.format("Request to read '%s'...\n[i]gnore, (v)iew, (d)eny, (a)llow: ", path),
    {
      filter = "[ivda\r\27]",
      loop = true,
      prompt_hl = "DiagnosticInfo",
    }
  )

  if not ok then
    -- Likely `<C-c>`, fallback to 'ignore'
    return nil
  end

  if resp == "d" then
    vim.secure.trust({ action = "deny", path = path })
    return nil
  elseif resp == "a" then
    local fullpath = Path.from_str(path):unwrap():absolute()

    if not fullpath:is_readable():block_on() then
      notify.error(string.format("The path is not a readable file: '%s'", path))
      return nil
    end

    secure.update_trust(fullpath:tostring(), "allow")

    return async.fs.read_file(fullpath):block_on():unwrap()
  elseif resp == "v" then
    vim.cmd.sview(path)
  end

  -- "i", "\r", "\27" all default to "ignore"
  return nil
end

return secure
