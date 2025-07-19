require "utility/utils";
local recipe_engine = require "shared/recipe/engine";
local base_utils = require "base:util";

local craft_item = "not_survival:flint";

function on_interact(x, y, z, pid)
  local pinvid, slot = player.get_inventory(pid);
  local itemid, _ = inventory.get(pinvid, slot);
  if itemid == item.index(craft_item) then
    local invid = inventory.get_block(x, y, z);
    local recipe, found_items = recipe_engine.check_crafting_grid(invid, { 9 }, { "shaped", "shapeless" });
    if recipe then
      recipe_engine.take_items(invid, found_items);
      inventory.set(invid, 9, 0, 0);

      base_utils.drop(
        vec3.add({ x, y + 1, z }, 0.5),
        recipe.result.id,
        recipe.result.count
      ).rigidbody:set_vel(vec3.spherical_rand(3));

      return true;
    end
  end
  hud.open_block(x, y, z)
  return true
end
