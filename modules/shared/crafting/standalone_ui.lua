local crafting_table = require "shared/crafting/crafting_table"

local module = {};

function module.chonky_share_handler(pid, blockid, result_slot, invid, slot)
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
    while crafting_table.check_result(invid, blockid, slot, item_id) and inventory.can_add_item(item_id, count, pinvid, data) do
      crafting_table.take_items(invid, blockid, result_slot);
      inventory.add(pinvid, item_id, count);
    end
  end

  crafting_table.update_result(invid, blockid, result_slot);
end

function module.create_handlers(lazy_blockid, lazy_result_slot)
  return {
    grid = {
      update = function(invid, slot)
        crafting_table.update_result(invid, lazy_blockid(), lazy_result_slot())
      end,
      share = function(invid, slot)
        module.chonky_share_handler(hud.get_player(), lazy_blockid(), lazy_result_slot(), invid, slot);
      end
    },
    result = {
      update = function(invid, slot)
        crafting_table.take_and_update(invid, lazy_blockid(), slot)
      end,
      share = function(invid, slot)
        module.chonky_share_handler(hud.get_player(), lazy_blockid(), lazy_result_slot(), invid, slot);
      end
    }
  }
end

return module;
