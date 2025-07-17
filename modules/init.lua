local mp = require "shared/utils/not_utils".multiplayer;
local resource = require "shared/utils/resource_func";

if mp.api.server then
  require "server/init"
end

if mp.api.client then
  require "client/init"
end
