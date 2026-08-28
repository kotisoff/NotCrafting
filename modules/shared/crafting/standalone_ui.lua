local crafting_table = require "shared/crafting/crafting_table"

local module = {};

---@param src { blockid: int, result_slot?: int }
function module.create_handlers(src)
  return {
    grid = {
      update = function(invid, slot)
        crafting_table.update_result(invid, src.blockid, src.result_slot)
      end,
      share = function(invid, slot)
        module.chonky_share_handler(hud.get_player(), src.blockid, src.result_slot, invid, slot);
      end
    },
    result = {
      update = function(invid, slot)
        crafting_table.take_and_update(invid, src.blockid, slot)
      end,
      share = function(invid, slot)
        crafting_table.handle_share(hud.get_player(), src.blockid, src.result_slot, invid, slot);
      end
    }
  }
end

return module;
