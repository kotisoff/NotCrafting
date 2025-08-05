local packid = "not_crafting";
local mp = require "shared/utils/not_utils".multiplayer.api.client
local packets = require "shared/utils/declarations/packets"
local module = {};

function module.sync_inventory(x, y, z)
  mp.events.send(packid, packets.sync_inventory, mp.bson.serialize({ x, y, z }));
end

return module;
