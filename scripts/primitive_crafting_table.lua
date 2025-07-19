local recipe_engine = require "shared/recipe/engine";
local base_utils = require "base:util";

local craft_item = pack.is_installed("not_survival") and "not_survival:flint" or "base:bazalt_breaker";

function on_interact(x, y, z, pid)
  local pinvid, slot = player.get_inventory(pid);
  local itemid, _ = inventory.get(pinvid, slot);
  if itemid == item.index(craft_item) then
    local invid = inventory.get_block(x, y, z);
    local blockid = block.get(x, y, z);

    local grid = recipe_engine.get_grid(invid);
    local slots, recipe = recipe_engine.resolve_grid(blockid, grid);

    if recipe then
      local sound = block.materials[block.material(blockid)].stepsSound;
      audio.play_sound(sound, x, y, z, 1, 1);

      recipe_engine.take_items(invid, slots);

      local entity = base_utils.drop(
        vec3.add({ x, y + 1, z }, 0.5),
        recipe.result.id,
        recipe.result.count
      );
      entity.rigidbody:set_vel(vec3.spherical_rand(3));

      return true;
    end
  end
  hud.open_block(x, y, z);
  return true;
end
