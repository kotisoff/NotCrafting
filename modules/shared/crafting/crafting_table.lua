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

---@param pid int
---@param blockid int
---@param result_slot int|nil
---@param invid int
---@param slot int
function module.handle_share(pid, blockid, result_slot, invid, slot)
  local item_id, count = inventory.get(invid, slot);
  local pinvid = player.get_inventory(pid);

  local data = {
    invsize = inventory.size(pinvid),
    stacksize = item.stack_size(item_id)
  }

  if slot ~= result_slot then
    if inventory.can_add_item(item_id, count, pinvid, data) then
      inventory.move(invid, slot, pinvid);
    end
  else
    while module.check_result(invid, blockid, slot, item_id) and inventory.can_add_item(item_id, count, pinvid, data) do
      module.take_items(invid, blockid, result_slot);
      inventory.add(pinvid, item_id, count);
    end
  end

  module.update_result(invid, blockid, result_slot);
end

return module;
