local loader      = require "shared/recipe/loader";
local engine      = require "shared/recipe/engine";
local compression = require "shared/recipe/utils/compression"
local packid      = require "constants".pack_id;
local packets     = require "shared/utils/declarations/packets"
local not_utils   = require "shared/utils/not_utils"
local mp          = not_utils.multiplayer;
local nc_events   = require "shared/utils/nc_events"
local log         = require "logger";


nc_events.on("first_tick", function()
  mp.as_server(function(server, mode)
    engine.reload_recipes();

    if mode == "standalone" then return end;

    log:println("I", "Compressing recipes...");

    ---@type bytearray
    local compressed_recipes = compression.compress_recipes();

    local bytes = bjson.tobytes(compressed_recipes, true);
    local length = #bytes;

    ---@param client neutron.class.client
    events.on("server:client_connected", function(client)
      server.events.tell(packid, packets.fetch_recipes, client, bytes);
      log:println("I",
        string.format("Sent %s bytes of recipes to %s(%s).", length, client.player.username, client.player.pid))
    end)
  end)
end)

nc_events.on("hud_open", function()
  mp.as_client(function(client)
    client.events.on(packid, packets.fetch_recipes, function(bytes)
      log:println("I", string.format("Received %s bytes of recipes.", #bytes));
      local data = bjson.frombytes(bytes);
      loader.recipes = compression.decompress_recipes(data);
    end)
  end)
end)
