local mp = require "shared/utils/not_utils".multiplayer;
local recipe_engine = require "shared/recipe/engine";
local base_utils = require "base:util";


function on_interact(x, y, z, pid)
  local data = require "sync_data";
  local craft_item = unpack(data);

  local val = mp.as_server(function(server, mode)
    local pinvid, slot = player.get_inventory(pid);
    local itemid, _ = inventory.get(pinvid, slot);
    if itemid == craft_item then
      local invid = inventory.get_block(x, y, z);
      local blockid = block.get(x, y, z);

      local grid = recipe_engine.get_grid(invid, { 9 });
      local slots, recipe = recipe_engine.resolve_grid(blockid, grid);

      if slots and recipe then
        recipe_engine.take_items(invid, slots);
        inventory.set(invid, 9, 0, 0);

        local ent = base_utils.drop(
          vec3.add({ x, y + 1, z }, 0.5),
          recipe.result.id,
          recipe.result.count
        )

        if mode == "standalone" then
          ent.rigidbody:set_vel(vec3.spherical_rand(3));
        end

        return true;
      end
    end
  end)
  if val then return val end;

  return mp.as_client(function(client, mode)
    hud.open_block(x, y, z);
    return true;
  end)
end
