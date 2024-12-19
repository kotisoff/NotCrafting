local ticking_blocks = require "utility/ticking_blocks";

local PACK_ID = PACK_ID or "not_crafting"; local function resource(name) return PACK_ID .. ":" .. name end

function on_interact(x, y, z, pid)
  hud.open_block(x, y, z)
  return true
end

function on_random_update(x, y, z)
  ticking_blocks.add({ x, y, z }, block.get(x, y, z));
end
