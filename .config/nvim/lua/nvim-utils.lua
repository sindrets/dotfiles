local M = {}

function M.within_range(outer, inner)
  local o1y = outer.start.line
  local o1x = outer.start.character
  local o2y = outer['end'].line
  local o2x = outer['end'].character
  assert(o1y <= o2y, "Start must be before end: " .. vim.inspect(outer))

  local i1y = inner.start.line
  local i1x = inner.start.character
  local i2y = inner['end'].line
  local i2x = inner['end'].character
  assert(i1y <= i2y, "Start must be before end: " .. vim.inspect(inner))

  if o1y < i1y then
    if o2y > i2y then
      return true
    end
    return o2y == i2y and o2x >= i2x
  elseif o1y == i1y then
    if o2y > i2y then
      return true
    else
      return o2y == i2y and o1x <= i1x and o2x >= i2x
    end
  else
    return false
  end
end

function M.get_diagnostics_for_range(bufnr, range)
  local diagnostics = vim.lsp.diagnostic.get(bufnr)
  if not diagnostics then return {} end
  local line_diagnostics = {}
  for _, diagnostic in ipairs(diagnostics) do
    if M.within_range(diagnostic.range, range) then
      table.insert(line_diagnostics, diagnostic)
    end
  end
  if #line_diagnostics == 0 then
    -- If there is no diagnostics at the cursor position,
    -- see if there is at least something on the same line
    for _, diagnostic in ipairs(diagnostics) do
      if diagnostic.range.start.line == range.start.line then
        table.insert(line_diagnostics, diagnostic)
      end
    end
  end
  return line_diagnostics
end

function M.lsp_organize_imports()
  local context = { source = { organizeImports = true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  local method = "textDocument/codeAction"
  local timeout = 1000 -- ms

  local resp = vim.lsp.buf_request_sync(0, method, params, timeout)
  if not resp then return end

  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if resp[client.id] then
      local result = resp[client.id].result
      if not result or not result[1] then return end

      local edit = result[1].edit
      vim.lsp.util.apply_workspace_edit(edit)
    end
  end
end

function M.right_pad_string(s, min_size, fill)
  local result = s
  if not fill then fill = " " end

  while #result < min_size do
    result = result .. fill
  end

  return result
end

function M.left_pad_string(s, min_size, fill)
  local result = s
  if not fill then fill = " " end

  while #result < min_size do
    result = fill .. result
  end

  return result
end

function M.center_pad_string(s, min_size, fill)
  local result = s
  if not fill then fill = " " end

  while #result < min_size do
    if #result % 2 == 0 then
      result = result .. fill
    else
      result = fill .. result
    end
  end

  return result
end

function M.get_git_branch()
  if vim.bo.filetype == 'help' then return end
  local current_file = vim.fn.expand('%:p')
  local current_dir

  -- If file is a symlinks
  if vim.fn.getftype(current_file) == 'link' then
    local real_file = vim.fn.resolve(current_file)
    current_dir = vim.fn.fnamemodify(real_file,':h')
  else
    current_dir = vim.fn.expand('%:p:h')
  end

  local _,gitbranch_pwd = pcall(vim.api.nvim_buf_get_var, 0, 'utils_gitbranch_pwd')
  local _,gitbranch_path = pcall(vim.api.nvim_buf_get_var, 0, 'utils_gitbranch_path')
  if gitbranch_path and gitbranch_pwd then
    if current_dir:find(gitbranch_path, 1, true) and string.len(gitbranch_pwd) ~= 0 then
      return  gitbranch_pwd
    end
  end

  local git_dir = require("galaxyline.provider_vcs").get_git_dir(current_dir)
  if not git_dir then return end

  local branch_name = io.popen('git branch --show-current'):read("*a")
  if #branch_name > 0 then branch_name = branch_name:sub(0, #branch_name - 1) end -- remove newline

  if #branch_name == 0 then
    -- assume detached head
    branch_name = io.popen(
      'sh -c \"git branch --remote --verbose --no-abbrev --contains | head -n1 | '
      .. 'sed -Erne \'s/^\\s*([^\\s]*? -> )?(\\w+\\/\\w+).*$/\\2/p\'\"'
    ):read("*a")

    if #branch_name > 0 then
      branch_name = "remotes/" .. branch_name:sub(0, #branch_name - 1)
    end
  end

  -- The function get_git_dir should return the root git path with '.git'
  -- appended to it. Otherwise if a different gitdir is set this substitution
  -- doesn't change the root.
  local git_root = git_dir:gsub('/.git/?$','')

  if #git_root > 0 then
    vim.api.nvim_buf_set_var(0,'utils_gitbranch_path', git_root)
  end

  if #branch_name > 0 then
    vim.api.nvim_buf_set_var(0,'utils_gitbranch_pwd', branch_name)
    return branch_name
  end

  return ""
end

return M
