local PACK_ID = PACK_ID or "not_crafting"; local function resource(name) return PACK_ID .. ":" .. name end

function on_interact(x, y, z, pid)
  hud.open_block(x, y, z)
  return true
end
