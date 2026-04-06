local nc_events = require "shared/core/nc_events";
local logger = require "shared/core/logger";
local mp = require "shared/utils/not_utils".multiplayer;

if mp.api.server then
  logger:println("I", "Включаем серверную часть мода");
  require "server/init"
end

if mp.api.client then
  logger:println("I", "Включаем клиентскую часть мода");
  require "client/init"
end

nc_events.on("first_tick", function()
  logger:println("I", string.format("NotCrafting is running in %s mode.", mp.mode));
end)
