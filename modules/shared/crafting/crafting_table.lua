local engine = require "shared/recipe/engine"

local module = {};

function module.update_result(invid, blockid, result_slot)
  local _, recipe = engine.resolve_grid(blockid, engine.get_grid(invid, { result_slot }));

  if recipe then
    inventory.set(invid, result_slot, recipe.result.id, recipe.result.count);
  else
    inventory.set(invid, result_slot, 0, 0);
  end
end

function module.take_result(invid, blockid, result_slot)
  local grid = engine.get_grid(invid, { result_slot });
  local slots, recipe = engine.resolve_grid(blockid, grid);

  if slots then
    engine.take_items(invid, slots);
  end

  return slots, recipe;
end

function module.take_and_update(invid, blockid, result_slot)
  local slots, recipe = module.take_result(invid, blockid, result_slot);
  module.update_result(invid, blockid, result_slot);

  return slots, recipe;
end

function module.take_and_check(invid, blockid, result_slot, result_item)
  local _, recipe = module.take_result(invid, blockid, result_slot);

  return recipe and recipe.result.id == result_item;
end

return module;
