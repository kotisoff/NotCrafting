local PACK_ID = "not_crafting";

---@return string
return function(name)
  return PACK_ID .. ":" .. name;
end
