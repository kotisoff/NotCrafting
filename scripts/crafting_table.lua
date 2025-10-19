local mp                   = require "shared/utils/not_utils".multiplayer;
local craft_with_craftitem = require "server/hooks/craft_with_craftitem"
local syncing              = require "client/syncing"
local data                 = require "sync_data";

function on_interact(x, y, z, pid)
  local val = craft_with_craftitem({ x, y, z }, pid, { 9 }, 9);
  if val then return val end;

  return mp.as_client(function(client, mode)
    local craft_item = unpack(data.get());

    local itemid = inventory.get(player.get_inventory(pid));
    if itemid ~= craft_item then
      syncing.open_block(x, y, z);
    end;

    return true;
  end)
end
