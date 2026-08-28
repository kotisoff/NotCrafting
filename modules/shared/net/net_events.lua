local mp = require "shared/utils/not_utils".multiplayer;

local pack_id = require "shared/core/constants".pack_id;

local packets = {
  recipes = tohex(1)
}

local client = {};
local server = {};

mp.as_client(function(api, mode)
  local net_events = api.events;

  ---@param event str
  ---@param bytes bytearray
  function client.send(event, bytes)
    return net_events.send(pack_id, event, bytes);
  end

  ---@param event str
  ---@param func fun(bytes: bytearray)
  function client.on(event, func)
    return net_events.on(pack_id, event, func);
  end
end)

mp.as_server(function(api, mode)
  local net_events = api.events;

  ---@param event str
  ---@param bytes bytearray
  function server.echo(event, bytes)
    return net_events.echo(pack_id, event, bytes);
  end

  ---@param event str
  ---@param func fun(client: neutron.class.client, bytes: bytearray)
  function server.on(event, func)
    return net_events.on(pack_id, event, func);
  end

  ---@param event str
  ---@param client neutron.class.client
  ---@param bytes bytearray
  function server.tell(event, client, bytes)
    return net_events.tell(pack_id, event, client, bytes);
  end
end)

return {
  client = client,
  server = server,
  packets = packets
};
