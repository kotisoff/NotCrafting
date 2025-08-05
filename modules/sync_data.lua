local nu        = require "shared/utils/not_utils";
local tags      = nu.tags;
local nc_events = require "shared/utils/nc_events"
local mp        = nu.multiplayer;
local packets   = require "shared/utils/declarations/packets"
local log       = require "logger"

local packid    = "not_crafting";

require "shared/recipe/engine"; -- syncing is already done in recipe engine script.

---@type [ int ]
local data = {};

nc_events.on("first_tick", function()
  log.println("I", "Syncing data");
  mp.as_server(function(server, mode)
    local craft_item = item.index("base:bazalt_breaker");
    if tags then
      craft_item = (tags.get_items_by_tags("not_crafting:craft_item") or { craft_item })[1];
    end

    data = {
      craft_item
    };

    ---@param client neutron.class.client
    events.on("server:client_connected", function(client)
      server.events.tell(packid, packets.sync_data, client, server.bson.serialize(data));
    end)
  end)

  mp.as_client(function(client, mode)
    client.events.on(packid, packets.sync_data, function(bytes)
      data = client.bson.deserialize(bytes);
    end)
  end)
end)


return data;
