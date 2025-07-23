local mp = require "shared/utils/not_utils".multiplayer;
local packets = require "shared/utils/declarations/packets"
local cl = mp.api.client;
local resource = require "shared/utils/resource_func";

---@type simpleitemtags.api
local simpleitemtags = require "simpleitemtags:init";

events.on(resource("use_on_block"), function(itemid, x, y, z, pid)
  local tags = simpleitemtags.get_tags_by_itemid(itemid);
  if table.has(tags, "not_crafting:craft_item") then
    cl.events.send("not_crafting", packets.item_use_on_block, cl.bson.serialize({
      itemid, pid, x, y, z
    }))
  end
end)
