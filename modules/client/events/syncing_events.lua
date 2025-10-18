local pack_id = require "constants".pack_id;
local mp = require "shared/utils/not_utils".multiplayer.api.client
local packets = require "shared/utils/declarations/packets"

mp.events.on(pack_id, packets.open_block_inventory, function(bytes)
  local pos = mp.bson.deserialize(bytes);

  hud.open_block(unpack(pos));
end)
