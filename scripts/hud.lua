local nc_events = require "shared/core/nc_events"

function on_hud_open(playerid)
  nc_events.emit("hud_open", playerid);
end
