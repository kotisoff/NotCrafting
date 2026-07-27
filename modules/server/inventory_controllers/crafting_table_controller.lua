local crafting_table = require "shared/crafting/crafting_table"
local block_props    = require "shared/api/v1/block_props"
local standalone_ui  = require "shared/crafting/standalone_ui"

---@type int
local blockid        = nil;
---@type int
local result_slot    = nil;

function on_open(player, invid, x, y, z)
  blockid = block.get(x, y, z);
  result_slot = block_props.craft_data(blockid).result_slot;

  crafting_table.update_result(invid, blockid, result_slot);
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

    return crafting_table.take_and_update(invid, blockid, slot);
  end

  crafting_table.update_result(invid, blockid, result_slot);
end

function on_share(nplayer, invid, slot, item_id)
  standalone_ui.chonky_share_handler(nplayer.pid, blockid, result_slot, invid, slot);
end
