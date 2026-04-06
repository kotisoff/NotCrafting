local nc_events = require "shared/core/nc_events"
local engine    = require "shared/recipe/engine";

nc_events.on("first_tick", function()
  engine.reload_recipes();
end)
