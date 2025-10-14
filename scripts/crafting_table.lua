local mp = require "shared/utils/not_utils".multiplayer;
local syncing = require "client/syncing"
local craft_with_craftitem = require "server/hooks/craft_with_craftitem"

function on_interact(x, y, z, pid)
  local val = mp.as_server(function(server, mode)
    return craft_with_craftitem({ x, y, z }, pid, { 9 }, 9, mode);
  end)
  if val then return val end;

  return mp.as_client(function(client, mode)
    syncing.open_block(x, y, z);
    return true;
  end)
end
