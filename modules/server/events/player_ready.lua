local mp         = require "shared/utils/not_utils".multiplayer;
local nc_events  = require "shared/core/nc_events";
local logger     = require "shared/core/logger";
local net_events = require "shared/net/net_events";
local sync       = require "shared/recipe/sync"

---@param client neutron.class.client
nc_events.on("player_ready", function(client)
  if mp.mode ~= "standalone" then
    local bytes = sync.bytes;

    net_events.server.tell(net_events.packets.recipes, client, bytes);
    logger:println("I",
      string.format("Sent %s bytes of recipes to %s(%s)", #bytes, client.player.username, client.player.pid)
    );
  end

  -- print(string.format("Игрок %s(%d) присоединился", client.player.username, client.player.pid))
end)
