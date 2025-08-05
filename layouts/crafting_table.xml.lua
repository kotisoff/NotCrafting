---@diagnostic disable: duplicate-set-field
local crafting = require "client/crafting";
local syncing = require "client/syncing";
local mp = require "shared/utils/not_utils".multiplayer.api.client;

local pos = { x = nil, y = nil, z = nil };
local blockid = block.index("not_crafting:crafting_table");

function on_open(invid, x, y, z)
  pos = { x = x, y = y, z = z };
  syncing.sync_inventory(x, y, z);
end

-- =========================funcs===========================

local function check_grid(invid, slot)
  local grid = crafting.get_grid(invid, { slot or 9 });
  return crafting.resolve_grid(blockid, grid);
end

local function check_result(invid, slot, result_item)
  local _, recipe = check_grid(invid, slot);
  return recipe and recipe.result.id == result_item;
end

local function update_slot(invid, slot)
  local itemid, count = inventory.get(invid, slot);
  mp.sandbox.blocks.sync_slot(pos, { slot_id = slot, item_id = itemid, item_count = count });
end

-- ======================grid=slots=========================

grid = {};

function grid.update(invid, slot)
  if slot then
    update_slot(invid, slot);
  end

  local _, recipe = check_grid(invid);
  if recipe then
    inventory.set(invid, 9, recipe.result.id, recipe.result.count);
  else
    inventory.set(invid, 9, 0, 0);
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

-- ======================result=slot========================

result = {};

function result.update(invid, slot)
  local itemid = inventory.get(invid, slot);
  if itemid ~= 0 then return end;

  local slots = check_grid(invid);

  if slots then
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

  while check_result(invid, slot, itemid) and inventory.can_add_item(itemid, count, pinvid, data) do
    inventory.add(pinvid, itemid, count);
    inventory.set(invid, slot, 0, 0);
    update_result(invid, slot);
  end
end
