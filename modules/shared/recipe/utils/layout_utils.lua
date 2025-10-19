local recipe_engine = require "shared/recipe/engine";
local mp = require "shared/utils/not_utils".multiplayer.api.client;

local module = {};

function module.init_funcs(blockid, getpos)
  local funcs = {};

  function funcs.check_grid(invid, slot)
    local grid = recipe_engine.get_grid(invid, { slot or 9 });
    return recipe_engine.resolve_grid(blockid, grid);
  end

  function funcs.check_result(invid, slot, result_item)
    local _, recipe = funcs.check_grid(invid, slot);
    return recipe and recipe.result.id == result_item;
  end

  function funcs.update_slot(invid, slot)
    local itemid, count = inventory.get(invid, slot);
    mp.sandbox.blocks.sync_slot(getpos(), { slot_id = slot, item_id = itemid, item_count = count });
  end

  return funcs;
end

---@param blockid int
---@param getpos fun(): { x: number, y: number, z: number }
---@param result_slot int | nil
function module.init_crafting_table(blockid, getpos, result_slot)
  local funcs = module.init_funcs(blockid, getpos);

  local grid = {};

  function grid.update(invid, slot)
    if slot then
      funcs.update_slot(invid, slot);
    end

    if result_slot then
      local _, recipe = funcs.check_grid(invid);

      if recipe then
        inventory.set(invid, result_slot, recipe.result.id, recipe.result.count);
      else
        inventory.set(invid, result_slot, 0, 0);
      end
    end
  end

  function grid.share(invid, slot)
    local pid = hud.get_player();
    local itemid, count = inventory.get(invid, slot);
    local pinvid = player.get_inventory(pid);

    if inventory.can_add_item(itemid, count, pinvid) then
      inventory.add(pinvid, itemid, count);
      inventory.set(invid, slot, 0, 0);
    end
  end

  local result = {};

  function result.update(invid, slot)
    local itemid = inventory.get(invid, slot);
    if itemid ~= 0 then return end;

    local slots = funcs.check_grid(invid);

    if slots then
      recipe_engine.take_items(invid, slots);
      grid.update(invid);
    end
  end

  function result.share(invid, slot)
    local pid = hud.get_player();
    local itemid, count = inventory.get(invid, slot);
    local pinvid = player.get_inventory(pid);

    local data = {
      invsize = inventory.size(pinvid),
      stacksize = item.stack_size(itemid)
    }

    while funcs.check_result(invid, slot, itemid) and inventory.can_add_item(itemid, count, pinvid, data) do
      inventory.add(pinvid, itemid, count);
      inventory.set(invid, slot, 0, 0);
      result.update(invid, slot);
    end
  end

  return {
    funcs = funcs,
    grid = grid,
    result = result
  }
end

return module;
