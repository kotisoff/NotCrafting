local pack_id = require "constants".pack_id;
local mp = require "shared/utils/not_utils".multiplayer.api.server;
local packets = require "shared/utils/declarations/packets"

mp.events.on(pack_id, packets.open_block_inventory, function(client, bytes)
  local _pos = mp.bson.deserialize(bytes);
  local pos = { x = _pos[1], y = _pos[2], z = _pos[3] };

  mp.sandbox.blocks.sync_inventory(pos, client);
  mp.events.tell(pack_id, packets.open_block_inventory, client, bytes);
end)
