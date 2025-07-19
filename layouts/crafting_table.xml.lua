local recipe_engine = require "shared/recipe/engine";

local function check_grid(invid, slot)
  local grid = recipe_engine.get_grid(invid, { slot or 9 });
  local blockid = block.index("not_crafting:crafting_table");

  return recipe_engine.resolve_grid(blockid, grid);
end

function update_grid(invid)
  local _, recipe = check_grid(invid);
  if recipe then
    inventory.set(invid, 9, recipe.result.id, recipe.result.count);
  else
    inventory.set(invid, 9, 0, 0);
  end
end

function update_result(invid, slot)
  local itemid = inventory.get(invid, slot);
  if itemid ~= 0 then return end;

  local slots = check_grid(invid);

  if slots then
    recipe_engine.take_items(invid, slots);
    update_grid(invid);
  end
end

local function check_result(invid, slot, result_item)
  local _, recipe = check_grid(invid, slot);
  return recipe and recipe.result.id == result_item
end

function share_func_result(invid, slot)
  local pid = hud.get_player();
  local itemid, count = inventory.get(invid, slot);
  local pinvid = player.get_inventory(pid);

  local data = {
    invsize = inventory.size(pinvid),
    stacksize = item.stack_size(itemid)
  }

  while check_result(invid, slot, itemid) and inventory.can_add_item(itemid, count, pinvid, data) do
    inventory.add(pinvid, itemid, count);
    inventory.set(invid, slot, 0, 0);
    update_result(invid, slot);
  end
end

function share_func(invid, slot)
  local pid = hud.get_player();
  local itemid, count = inventory.get(invid, slot);
  local pinvid = player.get_inventory(pid);

  if inventory.can_add_item(itemid, count, pinvid) then
    inventory.add(pinvid, itemid, count);
    inventory.set(invid, slot, 0, 0);
  end
end
