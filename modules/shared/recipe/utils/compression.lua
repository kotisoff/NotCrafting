local loader = require "shared/recipe/loader";

local module = {};

---@param grid not_crafting.class.grid
---@return [ [int, int, int][], int ]
function module.compress_grid(grid)
  local t_grid = {
    {},
    #grid
  };

  for slot, g_item in ipairs(grid) do
    if g_item.id > 0 then
      table.insert(t_grid[1], { g_item.id, g_item.count, slot });
    end
  end

  return t_grid;
end

---@param comp_grid [ [int, int, int][], int ]
function module.decompress_grid(comp_grid)
  local data, size = unpack(comp_grid);

  local grid = {};

  for slot = 1, size do
    local g_item;
    for _, value in ipairs(data) do
      local id, count, _slot = unpack(value);
      if slot == _slot then
        g_item = {
          id = id,
          count = count
        };
      end
    end

    table.insert(grid, g_item or { id = 0, count = 0 });
  end

  return grid;
end

-- ==================recipes=compression====================

---@param recipe not_crafting.class.recipe
function module.compress_recipe(recipe)
  recipe.type = nil;

  return recipe;
end

---@param recipe not_crafting.class.recipe
---@param type str
function module.decompress_recipe(recipe, type)
  recipe.type = type;

  return recipe;
end

---@return table
function module.compress_recipes()
  local compressed = {};
  for key, recipes in pairs(loader.recipes) do
    compressed[key] = {};
    local temp = compressed[key];
    for _, recipe in ipairs(recipes) do
      local comp = module.compress_recipe(recipe);
      table.insert(temp, comp);
    end
  end

  return compressed
end

---@param compressed table
function module.decompress_recipes(compressed)
  local decompressed = {};
  for key, recipes in pairs(compressed) do
    decompressed[key] = {};
    local temp = decompressed[key];
    for _, recipe in ipairs(recipes) do
      local decomp = module.decompress_recipe(recipe, key);
      table.insert(temp, decomp);
    end
  end

  return decompressed;
end

return module;
