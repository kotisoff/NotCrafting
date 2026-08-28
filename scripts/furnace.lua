local mp = require "shared/utils/not_utils".multiplayer;

local controller = nil;

function on_interact(x, y, z, pid)
  mp.as_server(function(server, mode)
    if not controller then
      controller = server.sandbox.inventories.create_controller(
        "not_crafting:modules/server/inventory_controllers/furnace_controller.lua"
      );
      server.sandbox.inventories.set_controller(block.get(x, y, z), controller);
    end

    local _player = server.sandbox.players.get_by_pid(pid) --[[@as neutron.class.player]]

    server.sandbox.inventories.open_block(_player, { x, y, z });
  end)
end
