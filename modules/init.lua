local mp = require "shared/utils/not_utils".multiplayer;

require "shared/recipe/engine";

if mp.api.server then
  require "server/init"
end

if mp.api.client then
  require "client/init"
end
