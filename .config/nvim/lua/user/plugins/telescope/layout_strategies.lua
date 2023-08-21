local layout_strategies = require("telescope.pickers.layout_strategies")
local resolve = require "telescope.config.resolve"
local p_window = require "telescope.pickers.window"

local function get_border_size(opts)
  if opts.window.border == false then
    return 0
  end

  return 1
end

local function calc_tabline(max_lines)
  local tbln = (vim.o.showtabline == 2) or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
  if tbln then
    max_lines = max_lines - 1
  end
  return max_lines, tbln
end

--- Helper function for capping over/undersized width/height, and calculating spacing
---@param cur_size number: size to be capped
---@param max_size any: the maximum size, e.g. max_lines or max_columns
---@param bs number: the size of the border
---@param w_num number: the maximum number of windows of the picker in the given direction
---@param b_num number: the number of border rows/column in the given direction (when border enabled)
---@param s_num number: the number of gaps in the given direction (when border disabled)
local function calc_size_and_spacing(cur_size, max_size, bs, w_num, b_num, s_num)
  local spacing = s_num * (1 - bs) + b_num * bs
  cur_size = math.min(cur_size, max_size)
  cur_size = math.max(cur_size, w_num + spacing)
  return cur_size, spacing
end

---@param strategy_config table: table with keys for each option for a strategy
---@return table: table with keys for each option (for this strategy) and with keys for each layout_strategy
local get_valid_configuration_keys = function(strategy_config)
  local valid_configuration_keys = {
    -- TEMP: There are a few keys we should say are valid to start with.
    preview_cutoff = true,
    prompt_position = true,
  }

  for key in pairs(strategy_config) do
    valid_configuration_keys[key] = true
  end

  for name in pairs(layout_strategies) do
    valid_configuration_keys[name] = true
  end

  return valid_configuration_keys
end

local adjust_pos = function(pos, ...)
  for _, opts in ipairs { ... } do
    opts.col = opts.col and opts.col + pos[1]
    opts.line = opts.line and opts.line + pos[2]
  end
end

---@param strategy_name string: the name of the layout_strategy we are validating for
---@param configuration table: table with keys for each option available
---@param values table: table containing all of the non-default options we want to set
---@param default_layout_config? table: table with the default values to configure layouts
---@return table: table containing the combined options (defaults and non-defaults)
local function validate_layout_config(strategy_name, configuration, values, default_layout_config)
  assert(strategy_name, "It is required to have a strategy name for validation.")
  local valid_configuration_keys = get_valid_configuration_keys(configuration)

  -- If no default_layout_config provided, check Telescope's config values
  default_layout_config = vim.F.if_nil(default_layout_config, require("telescope.config").values.layout_config)
  ---@cast default_layout_config -?

  local result = {}
  local get_value = function(k)
    -- skip "private" items
    if string.sub(k, 1, 1) == "_" then
      return
    end

    local val
    -- Prioritise options that are specific to this strategy
    if values[strategy_name] ~= nil and values[strategy_name][k] ~= nil then
      val = values[strategy_name][k]
    end

    -- Handle nested layout config values
    if layout_strategies[k] and strategy_name ~= k and type(val) == "table" then
      val = vim.tbl_deep_extend("force", default_layout_config[k], val)
    end

    if val == nil and values[k] ~= nil then
      val = values[k]
    end

    if val == nil then
      if default_layout_config[strategy_name] ~= nil and default_layout_config[strategy_name][k] ~= nil then
        val = default_layout_config[strategy_name][k]
      else
        val = default_layout_config[k]
      end
    end

    return val
  end

  -- Always set the values passed first.
  for k in pairs(values) do
    if not valid_configuration_keys[k] then
      -- TODO: At some point we'll move to error here,
      --    but it's a bit annoying to just straight up crash everyone's stuff.
      vim.api.nvim_err_writeln(
        string.format(
          "Unsupported layout_config key for the %s strategy: %s\n%s",
          strategy_name,
          k,
          vim.inspect(values)
        )
      )
    end

    result[k] = get_value(k)
  end

  -- And then set other valid keys via "inheritance" style extension
  for k in pairs(valid_configuration_keys) do
    if result[k] == nil then
      result[k] = get_value(k)
    end
  end

  return result
end

---@param name string: the name to be assigned to the layout
---@param layout_config table: table where keys are the available options for the layout
---@param layout function: function with signature
---          function(self, max_columns, max_lines, layout_config): table
---        the returned table is the sizing and location information for the parts of the picker
---@return function: wrapped function that inputs a validated layout_config into the `layout` function
local function make_documented_layout(name, layout_config, layout)
  -- Save configuration data to be used by documentation
  layout_strategies._configurations[name] = layout_config

  -- Return new function that always validates configuration
  local ret = function(self, max_columns, max_lines, override_layout)
    return layout(
      self,
      max_columns,
      max_lines,
      validate_layout_config(
        name,
        layout_config,
        vim.tbl_deep_extend("keep", vim.F.if_nil(override_layout, {}), vim.F.if_nil(self.layout_config, {}))
      )
    )
  end

  layout_strategies[name] = ret

  return ret
end

-- List of options that are shared by more than one layout.
local shared_options = {
  width = { "How wide to make Telescope's entire layout", "See |resolver.resolve_width()|" },
  height = { "How tall to make Telescope's entire layout", "See |resolver.resolve_height()|" },
  mirror = "Flip the location of the results/prompt and preview windows",
  scroll_speed = "The number of lines to scroll through the previewer",
  prompt_position = { "Where to place prompt window.", "Available Values: 'bottom', 'top'" },
  anchor = { "Which edge/corner to pin the picker to", "See |resolver.resolve_anchor_pos()|" },
}

local M = {}

M.vertical_bottom_pane = make_documented_layout(
  "vertical_bottom_pane",
  shared_options,
  function(self, max_columns, max_lines, layout_config)
    local initial_options = p_window.get_initial_window_options(self)
    local results = initial_options.results
    local prompt = initial_options.prompt
    local preview = initial_options.preview

    local tbln
    max_lines, tbln = calc_tabline(max_lines)

    local height = vim.F.if_nil(
      resolve.resolve_height(layout_config.height)(self, max_columns, max_lines),
      25
    )
    if
      type(layout_config.height) == "table" and type(layout_config.height.padding) == "number"
    then
      -- Since bottom_pane only has padding at the top, we only need half as much padding in total
      -- This doesn't match the vim help for `resolve.resolve_height`, but it matches expectations
      height = math.floor((max_lines + height) / 2)
    end

    local bs = get_border_size(self)

    -- Cap over/undersized height
    local w_space
    height, w_space = calc_size_and_spacing(height, max_lines, bs, 3, 3, 0)
    local width = max_columns

    -- Width
    prompt.width = width - 2 * bs
    results.width = width - 2 * bs
    preview.width = width - 2 * bs

    -- Height
    prompt.height = 1
    if self.previewer and max_lines >= layout_config.preview_cutoff then
      -- Cap over/undersized width (with preview)
      -- height, w_space = calc_size_and_spacing(max_lines, max_lines, bs, 2, 4, 0)

      preview.height = resolve.resolve_height(
        vim.F.if_nil(layout_config.preview_height, 0.5)
      )(self, max_columns, height - (prompt.height + bs) - 1)
      results.height = height - preview.height - w_space - 1
    else
      results.height = height - prompt.height - bs + 1
      preview.height = 0
    end

    -- Line
    if layout_config.prompt_position == "top" then
      prompt.line = max_lines - height + bs + 1
      results.line = prompt.line + 1
      preview.line = results.line + results.height + bs
      if type(results.title) == "string" then
        results.title = { { pos = "S", text = results.title } }
      end
      if type(preview.title) == "string" then
        preview.title = { { pos = "S", text = preview.title } }
      end
      if results.border == true then
        results.border = { 0, 1, 0, 1 }
      end
    elseif layout_config.prompt_position == "bottom" then
      results.line = max_lines - height - (1 + bs) + 1
      preview.line = results.line + results.height + bs
      prompt.line = max_lines - bs
      if type(prompt.title) == "string" then
        prompt.title = { { pos = "S", text = prompt.title } }
      end
      if results.border == true then
        results.border = { 1, 1, 0, 1 }
      end
    else
      error(string.format("Unknown prompt_position: %s\n%s", self.window.prompt_position, vim.inspect(layout_config)))
    end

    -- Col
    prompt.col = 0 -- centered
    results.col = prompt.col + bs + 1
    preview.col = prompt.col + bs + 1

    if tbln then
      prompt.line = prompt.line + 1
      results.line = results.line + 1
      preview.line = preview.line + 1
    end

    return {
      preview = self.previewer and preview.height > 0 and preview,
      prompt = prompt,
      results = results,
    }
  end
)

M.flex_bottom_pane = make_documented_layout(
  "flex_bottom_pane",
  shared_options,
  function(self, max_columns, max_lines, layout_config)
    local flip_columns = vim.F.if_nil(layout_config.flip_columns, 160)
    local flip_lines = vim.F.if_nil(layout_config.flip_lines, 20)

    if max_columns < flip_columns then
      self.__flex_strategy = "vertical"
      self.layout_config.flip_columns = nil
      self.layout_config.flip_lines = nil
      return layout_strategies.vertical_bottom_pane(self, max_columns, max_lines, layout_config.vertical)
    else
      self.__flex_strategy = "horizontal"
      self.layout_config.flip_columns = nil
      self.layout_config.flip_lines = nil
      return layout_strategies.bottom_pane(self, max_columns, max_lines, layout_config.horizontal)
    end
  end
)

return M
