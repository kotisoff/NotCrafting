local config = require "shared/core/config";

local module = {};

local cache = {};
local processors = {};
local defaults = {};

--Converts keys from kebab-case to snake_case
local function kebab_to_snake(table)
  local t = {};
  for key, value in pairs(table) do
    local new_key = string.replace(key, "-", "_");
    t[new_key] = value;
  end

  return t;
end
-- ======================craft=data=========================

---@alias nc.types.recipe_type "not_crafting:crafting_shaped" | "not_crafting:crafting_shapeless" | "not_crafting:smelting" | str

---@class nc.types.craft_data
---@field recipe_types nc.types.recipe_type[]
---@field result_slot? int

cache.craft_data = {};

---@type nc.types.craft_data
defaults.craft_data = {
  recipe_types = {}
}

---@return nc.types.craft_data
function processors.craft_data(block_id)
  if cache.craft_data[block_id] then
    return table.deep_copy(cache.craft_data[block_id]);
  end

  local props = block.properties[block_id] or {};

  local data = kebab_to_snake(props[config.properties.craft_data] or {});

  ---@type nc.types.craft_data
  data = table.merge(data, defaults.craft_data);

  cache.craft_data[block_id] = data;

  return table.deep_copy(data);
end

-- ========================module===========================

module.craft_data = processors.craft_data;

return module;
