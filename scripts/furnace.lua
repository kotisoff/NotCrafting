local blockid = block.index("not_crafting:furnace");

function on_block_tick(x, y, z, tps)
end

function on_interact(x, y, z, pid)
  hud.open_block(x, y, z)
  return true
end
