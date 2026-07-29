local crafting_table = require "shared/crafting/crafting_table"
local block_props    = require "shared/api/v1/block_props"

local module         = {};

---@type table<int, { blockid: int, result_slot?: int }>
local store          = {};

---@return int blockid, int|nil result_slot
local function get_data(invid)
  local data = store[invid];

  return data.blockid, data.result_slot;
end

---@param nplayer neutron.class.player
---@param invid int
---@param x int
---@param y int
---@param z int
function module.on_open(nplayer, invid, x, y, z)
  local blockid = block.get(x, y, z);
  local result_slot = block_props.craft_data(blockid).result_slot;

  store[invid] = {
    blockid = blockid,
    result_slot = result_slot
  }

  crafting_table.update_result(invid, blockid, result_slot);
end

---@param nplayer int
---@param invid int
function module.on_close(nplayer, invid)
  store[invid] = nil;
end

---@param nplayer neutron.class.player
---@param invid int
---@param slot int
---@param action voxelcore.events.inventory_interact.action
---@param mode voxelcore.events.inventory_interact.mode
function module.on_update(nplayer, invid, slot, action, mode)
  local blockid, result_slot = get_data(invid);

  if slot == result_slot and action == 1 then -- TAKE
    if mode == 1 then                         -- RMB
      local pinvid = player.get_inventory(nplayer.pid);
      inventory.move(invid, slot, pinvid);
    end

    return crafting_table.take_and_update(invid, blockid, slot);
  end

  crafting_table.update_result(invid, blockid, result_slot);
end

---@param nplayer neutron.class.player
---@param invid int
---@param slot int
---@param item_id int
function module.on_share(nplayer, invid, slot, item_id)
  local blockid, result_slot = get_data(invid);

  crafting_table.handle_share(nplayer.pid, blockid, result_slot, invid, slot);
end

return module;
