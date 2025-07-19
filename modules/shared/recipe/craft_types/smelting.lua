local resource = require "shared/utils/resource_func";

local module = {};
module.id = resource("smelting");

---@param grid { id: int, count: int }[]
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
