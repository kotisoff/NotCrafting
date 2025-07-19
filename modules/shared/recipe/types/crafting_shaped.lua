local resource = require "shared/utils/resource_func";

local module = {};
module.id = resource("crafting_shaped");

---@param blockpos vec3
function module.check(blockpos)
  local blockid = block.get(unpack(blockpos));
end
