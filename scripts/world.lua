local function resource(name) return PACK_ID .. ":" .. name end

local first_tick = true;
function on_world_open()
  first_tick = true;
end

function on_world_tick(tps)
  if first_tick then
    events.emit(resource("first_tick"))
    first_tick = false;
  end

  events.emit(resource("world_tick"))
end
