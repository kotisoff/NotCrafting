local PACK_ID = require "constants".pack_id;

---@param name string|nil
---@return string id Identifier with name or packid if name is nil.
return function(name)
  if name then
    return string.format("%s:%s", PACK_ID, name);
  else
    return PACK_ID;
  end
end
