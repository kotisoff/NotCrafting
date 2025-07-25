local nu = require "shared/utils/not_utils";
local mp = nu.multiplayer;
local ntags = nu.tags;
local packets = require "shared/utils/declarations/packets"
local cl = mp.api.client;
local resource = require "shared/utils/resource_func";

events.on(resource("use_on_block"), function(itemid, x, y, z, pid)
  local tags = ntags.get_tags_by_itemid(itemid);
  if table.has(tags, "not_crafting:craft_item") then
    cl.events.send("not_crafting", packets.item_use_on_block, cl.bson.serialize({
      itemid, pid, x, y, z
    }))
  end
end)
