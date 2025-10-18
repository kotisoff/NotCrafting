local loader         = require "shared/recipe/loader";
local require_folder = require "shared/utils/require_folder";
local nc_events      = require "shared/utils/nc_events"
local log            = require "logger";


---@alias not_crafting.class.grid {id: int, count: int}[]

local module = {
  ---@type table<str, (fun(grid: not_crafting.class.grid, recipe: not_crafting.class.recipe): table<int, int> | nil)>
  engines = {}
};

---@param check fun(grid: not_crafting.class.grid, recipe: not_crafting.class.recipe): table<int, int> | nil
function module.add_recipe_type(identifier, check)
  module.engines[identifier] = check;
end

function module.reload_recipes() loader.reload(module.engines) end

---@param craftblockid int
---@param grid not_crafting.class.grid
---@return table<int, int> | nil, not_crafting.class.recipe | nil
function module.resolve_grid(craftblockid, grid)
  local props = block.properties[craftblockid];
  ---@type { recipe_types: str[] }
  local prop = (props["not_crafting:crafting_block_data"] or {});
  local recipe_types = prop.recipe_types;

  if not recipe_types then return nil end;

  for _, recipe_type in ipairs(recipe_types) do
    local recipes = loader.recipes[recipe_type];
    local engine = module.engines[recipe_type];

    if not engine then goto continue end

    for _, recipe in ipairs(recipes) do
      local slots = engine(grid, recipe);
      if slots then return slots, recipe end;
    end

    ::continue::
  end

  return nil;
end

---@param invid int
---@param slots table<int, int>
function module.take_items(invid, slots)
  for slot, count in pairs(slots) do
    inventory.decrement(invid, slot - 1, count or 1); -- "or 1" потому что я себе не доверяю сука.
  end
end

---@param invid int
---@param ignored_slots int[] | nil
---@return not_crafting.class.grid
function module.get_grid(invid, ignored_slots)
  local grid = {};
  local invsize = inventory.size(invid);

  for i = 0, invsize - 1 do
    if not ignored_slots or not table.has(ignored_slots, i) then
      local itemid, count = inventory.get(invid, i);
      table.insert(grid, { id = itemid, count = count })
    end
  end

  return grid;
end

-- =========================init============================

nc_events.on("first_tick", function()
  log.println("I", "Loading recipe types...");

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
            return log.log("E", string.format("Recipe type with '%s' id already exists!", id))
          end

          table.insert(recipe_types, { id = id, check = check });
        end
      end
    }
  })
  events.emit("not_crafting:load_recipe_types", addon_craft_types);

  for _, recipe_type in ipairs(recipe_types) do
    module.add_recipe_type(recipe_type.id, recipe_type.check);
  end;

  log.print();
  log.println("I", "Recipe types loading done.");
end)

return module;
