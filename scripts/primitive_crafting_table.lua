local mp                   = require "shared/utils/not_utils".multiplayer;
local craft_with_craftitem = require "server/hooks/craft_with_craftitem"
local syncing              = require "client/syncing"

function on_interact(x, y, z, pid)
  local val = mp.as_server(function(server, mode)
    return craft_with_craftitem({ x, y, z }, pid, nil, nil, mode);
  end)
  if val then return val end;

  return mp.as_client(function(client, mode)
    syncing.open_block(x, y, z);
    return true;
  end)
end
