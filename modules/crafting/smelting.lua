local ticking_blocks = require "utility/ticking_blocks";

local function get_burntime(itemid)
  local itemprops = item.properties[itemid];
  if not itemprops then return nil end;
  return itemprops["not_crafting:fuel_burn_time"];
end
