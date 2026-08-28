local mp = require "shared/utils/not_utils".multiplayer;
local primitive_craft = require "server/hooks/primitive_craft"

function on_interact(x, y, z, pid)
  mp.as_server(function(server, mode)
    local crafted = primitive_craft({ x, y, z }, pid);
    if crafted then return crafted end;

    local _player = server.sandbox.players.get_by_pid(pid) --[[@as neutron.class.player]]

    server.sandbox.inventories.open_block(_player, { x, y, z });
  end)
end
