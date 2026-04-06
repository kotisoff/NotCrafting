local mp = require "shared/utils/not_utils".multiplayer;
local primitive_craft = require "server/hooks/primitive_craft"

local controller = nil;

function on_interact(x, y, z, pid)
  mp.as_server(function(server, mode)
    local crafted = primitive_craft({ x, y, z }, pid, { ignore = { 9 }, result = 9 });
    if crafted then return crafted end;

    if not controller then
      controller = server.sandbox.inventories.create_controller(
        "not_crafting:modules/server/inventory_controllers/crafting_table_controller.lua"
      );
      server.sandbox.inventories.set_controller(block.get(x, y, z), controller);
    end

    local _player = server.sandbox.players.get_by_pid(pid) --[[@as neutron.class.player]]

    server.sandbox.inventories.open_block(_player, { x, y, z });
  end)
end
