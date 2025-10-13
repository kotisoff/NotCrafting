local pack_id = require "constants".pack_id;
local mp = require "shared/utils/not_utils".multiplayer.api.client
local packets = require "shared/utils/declarations/packets"
local module = {};

function module.open_block(x, y, z)
  mp.events.send(pack_id, packets.open_block_inventory, mp.bson.serialize({ x, y, z }));
end

mp.events.on(pack_id, packets.open_block_inventory, function(bytes)
  local pos = mp.bson.deserialize(bytes);

  hud.open_block(unpack(pos));
end)

return module;
