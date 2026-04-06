local net_events = require "shared/net/net_events"
local logger     = require "shared/core/logger"
local sync       = require "shared/recipe/sync"

net_events.client.on(net_events.packets.recipes, function(bytes)
  logger:println("I",
    string.format("Got %s bytes of recipes", #bytes)
  );

  sync.decompress(bytes);
end)
