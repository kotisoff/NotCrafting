local resource = require "shared/utils/resource_func";

local module = {};
module.id = resource("crafting_shapeless");

---@param grid not_crafting.class.grid
---@param recipe not_crafting.class.recipe
function module.check(grid, recipe)
  local ingredients = recipe.ingredients;

  ---@type { id: int, count: int, slot: int }[]
  local items = {};
  ---@type not_crafting.class.grid
  local grid_copy = table.copy(grid);

  for slot, grid_item in pairs(grid_copy) do
    if grid_item.id ~= 0 then
      table.insert(items, { id = grid_item.id, count = grid_item.count, slot = slot });
    end
  end

  local found_slots = {};

  for _, ingredient in ipairs(ingredients) do
    local found = false;

    for index, grid_item in ipairs(items) do
      if grid_item.id == ingredient.item then
        found = true;
        table.insert(found_slots, grid_item.slot);
        table.remove(items, index);
        break;
      end
    end

    if not found then return nil end;
  end

  return found_slots;
end

return module;
