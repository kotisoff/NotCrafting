require "utils"
local recipe_engine = require "recipe/engine";

local function check_grid(invid, slot)
  return recipe_engine.check_crafting_grid(invid, { slot or 9 }, { "shaped", "shapeless" });
end

function update_grid(invid)
  local recipe = check_grid(invid) or {};
  if recipe["name"] then
    inventory.set(invid, 9, recipe.result.id, recipe.result.count);
  else
    inventory.set(invid, 9, 0, 0)
  end
end

function update_result(invid, slot)
  local itemid = inventory.get(invid, slot);
  if itemid ~= 0 then return end;

  local _, found_items = check_grid(invid);

  if found_items then
    recipe_engine.take_items(invid, found_items);
    inventory.set(invid, 9, 0, 0)
    update_grid(invid);
  end
end

function share_func_result(invid, slot)
  local itemid, count = inventory.get(invid, slot);

  local function check()
    local recipe = check_grid(invid, slot);
    return recipe and recipe.result.id == itemid
  end

  while check() do
    local pinvid = player.get_inventory();
    inventory.add(pinvid, itemid, count);
    inventory.set(invid, slot, 0, 0)
    update_result(invid, slot);
  end
end

function share_func(invid, slot)
  local itemid, count = inventory.get(invid, slot);

  local pinvid = player.get_inventory();
  inventory.add(pinvid, itemid, count);
  inventory.set(invid, slot, 0, 0);
end
