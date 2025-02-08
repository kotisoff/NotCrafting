local function resource(name) return PACK_ID .. ":" .. name end

local recipe_engine = require "recipe/engine";
local not_utils = require "utility/utils";

-- FURNACE DATA

local function get_burntime(itemid)
  local itemprops = item.properties[itemid];
  if not itemprops then return nil end;
  return itemprops["not_crafting:fuel_burn_time"];
end

local temp = {
  furnaces = {},
  data = {}
}

local furnaceSpeed = 2;

local function getFurnaceKey(pos)
  for key, value in pairs(temp.furnaces) do
    if table.concat(value, "_") == table.concat(pos, "_") then
      return key
    end
  end
  return nil;
end

local function getFurnaceKeyByInv(invid)
  for key, value in pairs(temp.data) do
    if value[1] == invid then
      return key
    end
  end
end

local function removeFurnaceTick(pos)
  local key = getFurnaceKey(pos);

  local wrapid = temp.data[key][5];
  if wrapid then
    gfx.blockwraps.unwrap(wrapid)
  end

  table.remove(temp.furnaces, key);
  table.remove(temp.data, key);
end

local function check_grid(invid)
  return recipe_engine.check_crafting_grid(invid, { 1, 2 }, { "smelting" });
end

local current_block = nil;

local function change_furnace_model(x, y, z, state)
  local key = getFurnaceKey({ x, y, z });
  local data = temp.data[key];

  local wrapid = data[5];
  if (state and wrapid) or (not state and not wrapid) then
    return false;
  end

  if state then
    data[5] = gfx.blockwraps.wrap({ x, y, z }, "wraps/furnace_fire");
  else
    gfx.blockwraps.unwrap(wrapid);
    data[5] = nil;
  end

  return true;
end

-- HUD

function on_open(invid, x, y, z)
  local pos = { x, y, z };
  if not getFurnaceKeyByInv(invid) then
    table.insert(temp.furnaces, pos)
    -- invid, { current_burntime, fuel_burntime }, { current_smelttime, item_smelttime }, experience, wrapid
    table.insert(temp.data, { invid, { 0, -1 }, { 0, 0 }, 0, nil });
  end
  current_block = { invid, pos, getFurnaceKey(pos) };
end

function on_close(invid)
  current_block = nil;
end

function share_func(invid, slot)
  local itemid, count = inventory.get(invid, slot);

  local pid = hud.get_player();
  local pinvid = player.get_inventory(pid);
  inventory.add(pinvid, itemid, count);
  inventory.set(invid, slot, 0, 0);
end

function update_result(invid, slot)
  local key = getFurnaceKeyByInv(invid);
  local data = temp.data[key];
  local pos = temp.furnaces[key];

  if pack.is_installed("not_survival") then
    local api = require("not_survival:api");
    local exp_points = data[4];
    if exp_points > 0 then
      api.exp.give(hud.get_player(), exp_points);
      data[4] = 0;
    end
  end
end

-- TICKING

local function isFurnace(x, y, z)
  local blck = block.name(block.get(x, y, z));
  return blck == resource("furnace");
end

local function update_burn_time_indicator()
  if not current_block then return end;

  local data = temp.data[current_block[3]];
  local burn = data[2];
  local burntime = burn[1];
  local maxburntime = burn[2];

  local width = 50 - (burntime / maxburntime * 50);
  document.burntime.size = { width, 5 }
  document.burntime.visible = burntime > 0 and maxburntime > 0;
end

local function update_smelt_time_indicator()
  if not current_block then return end;

  local data = temp.data[current_block[3]];
  local smelting = data[3];
  local smelttime = smelting[1];
  local maxsmelttime = smelting[2];

  local width = (smelttime / maxsmelttime * 40);
  document.smelttime.size = { width, 5 }
  document.smelttime.visible = smelttime > 0;
end

events.on(resource("world_tick"), function()
  for key, pos in pairs(temp.furnaces) do
    if isFurnace(unpack(pos)) then
      local data = temp.data[key];

      local invid = data[1];
      local burn = data[2];

      local fuelid, fuelcount = inventory.get(invid, 1);
      local itemburntime = get_burntime(fuelid);
      local burntime = burn[1];
      local maxburntime = burn[2];

      local is_smelting = false;

      local recipe = check_grid(invid);

      -- Fuel drain
      if recipe then
        if burntime == maxburntime or (itemburntime and maxburntime == -1) then
          inventory.set(invid, 1, fuelid, fuelcount - 1);
          burn[1] = furnaceSpeed;
          burn[2] = itemburntime
          is_smelting = true;
        end
      end

      if maxburntime > burntime then
        burn[1] = burntime + furnaceSpeed;
        is_smelting = true;
      elseif not is_smelting then
        burn[1] = 0;
      end

      if maxburntime == burntime then
        burn[2] = -1;
      end

      local x, y, z = unpack(pos);
      change_furnace_model(x, y, z, is_smelting);

      -- Smelting
      recipe = recipe or {};

      local smelting = data[3];
      local item_smelttime = recipe.cookingtime;

      local cur_smelting = smelting[1];

      if recipe.result then
        smelting[2] = item_smelttime;

        if is_smelting then
          local resid, rescount = inventory.get(invid, 2);

          if item_smelttime > cur_smelting then
            if (resid == recipe.result.id or resid == 0)
                and rescount < (64 - recipe.result.count) then
              smelting[1] = cur_smelting + furnaceSpeed;
            end
          else
            local itemid, itemcount = inventory.get(invid, 0);
            inventory.set(invid, 0, itemid, itemcount - 1);

            inventory.set(invid, 2, recipe.result.id, rescount + recipe.result.count)

            data[4] = data[4] + (recipe.experience or 0);

            smelting[1] = furnaceSpeed;
          end
        else
          smelting[1] = 0;
        end
      else
        smelting[1] = 0;
        smelting[2] = -1;
      end
    else
      removeFurnaceTick(pos);
    end
  end

  update_burn_time_indicator();
  update_smelt_time_indicator();
end)
