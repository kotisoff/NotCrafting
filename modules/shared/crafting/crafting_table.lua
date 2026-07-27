local engine = require "shared/recipe/engine"

local module = {};

function module.find_recipe(invid, blockid, result_slot)
  return engine.resolve_grid(blockid, engine.get_grid(invid, { result_slot }))
end

---@param invid int
---@param blockid int
---@param result_slot int|nil
function module.update_result(invid, blockid, result_slot)
  if result_slot == nil then return end;

  local _, recipe = engine.resolve_grid(blockid, engine.get_grid(invid, { result_slot }));

  if recipe then
    inventory.set(invid, result_slot, recipe.result.id, recipe.result.count);
  else
    inventory.set(invid, result_slot, 0, 0);
  end
end

---@param invid int
---@param blockid int
---@param result_slot int|nil
function module.take_items(invid, blockid, result_slot)
  local grid = engine.get_grid(invid, { result_slot });
  local slots, recipe = engine.resolve_grid(blockid, grid);

  if slots then
    engine.take_items(invid, slots);
  end

  return slots, recipe;
end

---@param invid int
---@param blockid int
---@param result_slot int|nil
function module.take_and_update(invid, blockid, result_slot)
  local slots, recipe = module.take_items(invid, blockid, result_slot);
  module.update_result(invid, blockid, result_slot);

  return slots, recipe;
end

---@param invid int
---@param blockid int
---@param result_slot int|nil
function module.check_result(invid, blockid, result_slot, result_item)
  local _, recipe = module.find_recipe(invid, blockid, result_slot);

  return recipe and recipe.result.id == result_item;
end

return module;
