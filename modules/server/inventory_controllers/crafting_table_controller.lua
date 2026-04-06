local engine = require "shared/recipe/engine"

local result_slot = 9
---@type int
local blockid = nil;

local function check_grid(invid)
  local grid = engine.get_grid(invid, { result_slot })
  return engine.resolve_grid(blockid, grid);
end

local function update_result(invid)
  local _, recipe = check_grid(invid);

  if recipe then
    inventory.set(invid, result_slot, recipe.result.id, recipe.result.count)
  end
end

local function check_result(invid, slot, result_item)
  local _, recipe = check_grid(invid);
  return recipe and recipe.result.id == result_item;
end

function on_open(player, invid, x, y, z)
  blockid = block.get(x, y, z);

  update_result(invid);
end

---@param nplayer neutron.class.player
---@param invid int
---@param slot int
---@param action voxelcore.events.inventory_interact.action
---@param mode voxelcore.events.inventory_interact.mode
function on_update(nplayer, invid, slot, action, mode)
  if slot == result_slot and action == 1 then -- TAKE
    if mode == 1 then                         -- RMB
      local pinvid = player.get_inventory(nplayer.pid);
      inventory.move(invid, slot, pinvid);
    end

    local slots = check_grid(invid);

    if slots then
      engine.take_items(invid, slots);
    end
  end

  update_result(invid);
end

function on_share(nplayer, invid, slot, item_id)
  local _, count = inventory.get(invid, slot);
  local pinvid = player.get_inventory(nplayer.pid);

  local data = {
    invsize = inventory.size(pinvid),
    stacksize = item.stack_size(item_id)
  }

  if slot ~= result_slot then
    if inventory.can_add_item(item_id, count, pinvid, data) then
      inventory.move(invid, slot, pinvid);
    end
  else
    while check_result(invid, slot, item_id) and inventory.can_add_item(item_id, count, pinvid, data) do
      inventory.move(invid, slot, pinvid);
    end
  end

  update_result(invid);
end
