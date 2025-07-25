local packets = require "shared/utils/declarations/packets"
local nu = require "shared/utils/not_utils";
local mp = nu.multiplayer.api.server;
local ntags = nu.tags;

mp.events.on("not_crafting", packets.item_use_on_block, function(client, bytes)
  local args = mp.bson.deserialize(bytes);
  local itemid, pid, x, y, z = unpack(args);

  local tags = ntags.get_tags_by_itemid(itemid);
  if table.has(tags, "not_crafting:craft_item") then
    if block.get(x, y, z) == block.index("base:wood") then
      block.place(x, y, z, block.index("not_crafting:primitive_crafting_table"), pid)
      local inv, slot = player.get_inventory(pid)
      inventory.decrement(inv, slot, 1)
    end
  end
end)
