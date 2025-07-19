local resource = require "shared/utils/resource_func";

local module = {};
module.id = resource("crafting_shapeless");

---@param grid { id: int, count: int }[]
---@param recipe not_crafting.class.recipe
function module.check(grid, recipe)
  local ingredients = recipe.ingredients;

  local grid_copy = table.copy(grid);
  local found_slots = {};

  for _, ingredient in ipairs(ingredients) do
    local found = false;

    for slot, grid_item in ipairs(grid_copy) do
      if grid_item.id == ingredient.item then
        found = true;
        table.insert(found_slots, slot);
        table.remove(grid_copy, slot);
        break;
      end
    end

    if not found then return nil end;
  end

  return found_slots;
end

return module;
