local mp = require "shared/utils/not_utils".multiplayer;

require "sync_data";

if mp.api.server then
  require "server/init"
end

if mp.api.client then
  require "client/init"
end
