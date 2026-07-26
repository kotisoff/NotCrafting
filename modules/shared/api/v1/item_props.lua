local config = require "shared/core/config";

local module = {};

local cache = {};
local processors = {};
local defaults = {};

-- =======================burn=time=========================

cache.burn_time = {};

---@return int | nil burn_time nil = not fuel
function processors.burn_time(item_id)
  if cache.burn_time[item_id] ~= nil then
    if cache.burn_time[item_id] < 0 then
      return nil;
    end

    return cache.burn_time[item_id];
  end

  local props = item.properties[item_id] or {};
  local burn_time = props[config.properties.burn_time];

  cache.burn_time[item_id] = burn_time or -1;

  return burn_time;
end

-- ========================module===========================

module.burn_time = processors.burn_time;

return module;
