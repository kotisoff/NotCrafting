local resource = require "shared/utils/resource_func";

local module = {};
module.id = resource("smelting");

---@param grid not_crafting.class.grid
---@param recipe not_crafting.class.recipe
function module.check(grid, recipe)
  local ingredient = recipe.ingredient

  for slot, grid_item in ipairs(grid) do
    if grid_item.id == ingredient.item then
      return { slot }
    end
  end

  return nil;
end

return module;
