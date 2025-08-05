local mp = require "shared/utils/not_utils".multiplayer.api.client;
local engine = require "shared/recipe/engine";

local module = {};

module.get_grid = engine.get_grid;
module.resolve_grid = engine.resolve_grid;

function module.validate_craft(action)

end

return module;
