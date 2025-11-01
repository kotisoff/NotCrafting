local mp            = require "shared/utils/not_utils".multiplayer;
local data          = require "sync_data";
local recipe_engine = require "shared/recipe/engine";

---@type voxelcore.modules.base.util
local base_utils    = require "base:util";

---@param pos vec3
---@param pid int
---@param ignored_slots int[] | nil
---@param result_slot int | nil
return function(pos, pid, ignored_slots, result_slot)
  local pinvid, slot = player.get_inventory(pid);
  local selected_item = inventory.get(pinvid, slot);

  local craft_item = unpack(data.get());

  if selected_item == craft_item then
    mp.as_server(function(server, mode)
      local invid = inventory.get_block(unpack(pos));
      local blockid = block.get(unpack(pos));

      local grid = recipe_engine.get_grid(invid, ignored_slots);
      local slots, recipe = recipe_engine.resolve_grid(blockid, grid);

      if slots and recipe then
        local sound = block.get_sound(blockid, "stepsSound");
        local x, y, z = unpack(pos);

        audio.play_sound(sound, x, y, z, 1, 1);

        recipe_engine.take_items(invid, slots);
        if result_slot then inventory.set(invid, result_slot, 0, 0) end;

        local ent = base_utils.drop(
          vec3.add(pos, { 0.5, 1.5, 0.5 }),
          recipe.result.id,
          recipe.result.count
        );

        if mode == "standalone" then
          ent.rigidbody:set_vel(vec3.spherical_rand(3));
        end
      end
    end)

    return true;
  end
end
