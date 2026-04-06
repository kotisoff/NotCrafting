local nc_events = require "shared/core/nc_events";
local require_folder = require "shared/utils/require_folder";
local logger = require "shared/core/logger";

local recipe_engine = require "shared/recipe/engine";

nc_events.on("first_tick", function()
  logger:println("I", "Loading recipe types...");

  ---@type { id: str, check: function }[]
  local recipe_types = require_folder "shared/recipe/recipe_types";
  local keys = {};

  for _, value in ipairs(recipe_types) do
    table.insert(keys, value.id);
  end

  local addon_craft_types = setmetatable({}, {
    __index = {
      add = function(id, check)
        if type(id) == "string" and type(check) == "function" then
          if table.has(keys, id) then
            return logger:logger("E", string.format("Recipe type with '%s' id already exists!", id))
          end

          table.insert(recipe_types, { id = id, check = check });
        end
      end
    }
  })
  events.emit("not_crafting:load_recipe_types", addon_craft_types);

  for _, recipe_type in ipairs(recipe_types) do
    recipe_engine.add_recipe_type(recipe_type.id, recipe_type.check);
  end;

  logger:print();
  logger:println("I", "Recipe types loading done.");

  recipe_engine.reload_recipes();
end)
