local ticking_blocks = require "shared/utils/ticking_blocks";
local blockid = block.index("not_crafting:furnace");

function on_interact(x, y, z, pid)
  ticking_blocks.add({ x, y, z });
  hud.open_block(x, y, z)
  return true
end

ticking_blocks.on_tick(blockid, function(pos)
end)
