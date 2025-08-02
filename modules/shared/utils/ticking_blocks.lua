local resource = require "shared/utils/resource_func";

local module = {};

---@type fun(pos: vec3)[][]
local handlers = {};
---@type vec3[][]
local blocks = {};

---@param blockid int
---@param pos vec3
---@return bool
function module.has(blockid, pos)
  for _, _pos in pairs(blocks[blockid] or {}) do
    if vec3.equals(_pos, pos) then return true end;
  end
  return false;
end

---@param pos vec3
function module.add(pos)
  local blockid = block.get(unpack(pos));

  if not module.has(blockid, pos) then
    blocks[blockid] = blocks[blockid] or {};
    table.insert(blocks[blockid], pos);
  end
end

---@param pos vec3
function module.remove(pos)
  for _, positions in pairs(blocks) do
    local index = table.index(positions, pos);
    if index ~= -1 then
      return table.remove(positions, index)
    end
  end
end

---@param func fun(pos: vec3)
function module.on_tick(blockid, func)
  handlers[blockid] = handlers[blockid] or {};
  table.insert(handlers[blockid], func);
end

events.on(resource("world_tick"), function()
  for blockid, funcs in pairs(handlers) do
    for _, pos in pairs(blocks[blockid] or {}) do
      local _blockid = block.get(unpack(pos))
      if _blockid == blockid then
        for _, func in ipairs(funcs) do
          func(pos);
        end
      else
        module.remove(pos);
      end
    end
  end
end)

return module;
