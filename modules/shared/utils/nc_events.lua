local module = {};

local function format_event(event)
  return string.format("%s:%s", "not_crafting", event);
end

---@alias eventlist "first_tick" | "world_tick" | "hud_open"

---@param event eventlist
function module.emit(event, ...)
  return events.emit(format_event(event), ...);
end

---@param event eventlist
---@param func fun(...): any
function module.on(event, func)
  return events.on(format_event(event), func);
end

return module;
