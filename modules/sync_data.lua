local nu             = require "shared/utils/not_utils";
local mp             = nu.multiplayer;
local resource       = require "shared/utils/resource_func"
local simpleitemtags = require "shared/utils/simpleitemtags"
local packets        = require "shared/utils/declarations/packets"
local log            = require "logger"

require "shared/recipe/engine"; -- syncing is already done in recipe engine script.

---@type [ int ]
local data = {};


events.on(resource("first_tick"), function()
  log.println("I", "Syncing data");
  mp.as_server(function(server, mode)
    local craft_item = item.index("base:bazalt_breaker");
    if simpleitemtags then
      craft_item = (simpleitemtags.get_items_by_tags("not_crafting:craft_item") or { craft_item })[1];
    end

    data = {
      craft_item
    };

    ---@param client neutron.class.client
    events.on("server:client_connected", function(client)
      server.events.tell(resource(), packets.sync_data, client, server.bson.serialize(data));
    end)
  end)

  mp.as_client(function(client, mode)
    client.events.on(resource(), packets.sync_data, function(bytes)
      data = client.bson.deserialize(bytes);
    end)
  end)
end)

return data;
