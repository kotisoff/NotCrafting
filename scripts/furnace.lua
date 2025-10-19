local mp = require "shared/utils/not_utils".multiplayer;
local syncing = require "client/syncing"

function on_interact(x, y, z, pid)
  return mp.as_client(function(client, mode)
    syncing.open_block(x, y, z);
    return true;
  end)
end
