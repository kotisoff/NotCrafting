local mp            = require "shared/utils/not_utils".multiplayer;
local recipe_engine = require "shared/recipe/engine";

---@type voxelcore.modules.base.util
local base_utils    = require "base:util";

---@param pos vec3
---@param pid int
---@param slot_options { ignore?: int[], result?: int } | nil
return function(pos, pid, slot_options)
  local pinvid, slot = player.get_inventory(pid);
  local selected_item = inventory.get(pinvid, slot);

  slot_options = slot_options or {};
  local ignore = slot_options.ignore;
  local result = slot_options.result;

  if recipe_engine.is_crafting_item(selected_item) then
    local invid = inventory.get_block(unpack(pos));
    local blockid = block.get(unpack(pos));

    local grid = recipe_engine.get_grid(invid, ignore);
    local slots, recipe = recipe_engine.resolve_grid(blockid, grid);

    if slots and recipe then
      local sound = block.get_sound(blockid, "stepsSound");
      local x, y, z = unpack(pos);

      audio.play_sound(sound, x, y, z, 1, 1);

      recipe_engine.take_items(invid, slots);
      if result then inventory.set(invid, result, 0, 0) end;

      local ent = base_utils.drop(
        vec3.add(pos, { 0.5, 1.5, 0.5 }),
        recipe.result.id,
        recipe.result.count
      );

      if mp.mode == "standalone" then
        ent.rigidbody:set_vel(vec3.spherical_rand(3));
      end
    end

    return true;
  end
  return false;
end
