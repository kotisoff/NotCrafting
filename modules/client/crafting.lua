local engine = require "shared/recipe/engine";

local module = {};

function module.check_grid(blockid, invid, ignored_slots)
  local grid = engine.get_grid(invid, ignored_slots);
end
