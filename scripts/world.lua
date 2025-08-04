require "init";
local nc_events = require "shared/utils/nc_events"

local first_tick = true;
function on_world_open()
  first_tick = true;
end

function on_world_tick(tps)
  if first_tick then
    nc_events.emit("first_tick");
    first_tick = false;
  end

  nc_events.emit("world_tick");
end

function on_world_quit()
  events.remove_by_prefix(PACK_ID);
end
